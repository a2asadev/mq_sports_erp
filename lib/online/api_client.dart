import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/online/api_error_text.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/online/token_store.dart';

/// A JSON object as the API returns it.
typedef JsonMap = Map<String, dynamic>;

/// What the API answered: the HTTP status and the decoded JSON body (null for
/// an empty body, for example after a delete).
class ApiResponse {
  const ApiResponse(this.status, this.body);

  final int status;
  final Object? body;

  JsonMap get asMap {
    final Object? value = body;
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  List<Object?> get asList {
    final Object? value = body;
    return value is List<Object?> ? value : <Object?>[];
  }
}

/// Talks to the backend API.
///
/// - Sends the access token with every request.
/// - When the token has expired it refreshes it once (several requests that
///   fail together share that one refresh) and repeats the request.
/// - Turns every failure into an [AppException] the screens already know how to
///   show: validation, permission, sign-in, or "cannot reach the server".
class ApiClient {
  ApiClient({
    required http.Client httpClient,
    required String baseUrl,
    required TokenStore tokens,
    Duration timeout = const Duration(seconds: 30),
    http.Client? streamClient,
  })  : _http = httpClient,
        _streamHttp = streamClient ?? httpClient,
        _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _tokens = tokens,
        _timeout = timeout;

  final http.Client _http;
  final http.Client _streamHttp;
  final String _baseUrl;
  final TokenStore _tokens;
  final Duration _timeout;

  String? _accessToken;
  Future<bool>? _refreshing;
  Future<UserModel?>? _restoring;
  final StreamController<UserModel?> _sessionChanges =
      StreamController<UserModel?>.broadcast();

  /// The signed-in user (null when signed out). Emits when someone signs in or
  /// out, or when the session ends because the refresh token stopped working.
  Stream<UserModel?> get sessionChanges => _sessionChanges.stream;

  UserModel? _user;

  UserModel? get currentUser => _user;

  BusinessInfo? _business;

  /// The business the signed-in user works for, as the server last described it
  /// (kept with the saved session, so it is known without a connection). Null
  /// when signed out, or for a session saved before businesses existed.
  BusinessInfo? get currentBusiness => _business;

  /// Takes a fresher description of the business (from `/v1/auth/me`) and saves
  /// it with the session.
  Future<void> rememberBusiness(BusinessInfo business) async {
    if (_user == null || _business == business) {
      return;
    }
    _business = business;
    final Map<String, dynamic>? saved = await _savedSessionMap();
    if (saved != null) {
      await _tokens.saveUserJson(jsonEncode(<String, dynamic>{...saved, 'tenant': business.toMap()}));
    }
  }

  /// Signed in, possibly without a connection (the saved session of a previous visit).
  bool get isSignedIn => _user != null;

  // ---- session -------------------------------------------------------------

  Future<UserModel> login(String email, String password) async {
    final ApiResponse response = await send(
      'POST',
      '/v1/auth/login',
      body: <String, dynamic>{'email': email.trim(), 'password': password},
      authenticated: false,
    );
    return _startSession(response.asMap);
  }

  /// Signs in again from the stored refresh token (page reload). Null when
  /// there is none or it no longer works.
  ///
  /// Safe to call more than once, also at the same moment: a refresh token works
  /// only once, and using it twice would look like theft and end every session.
  Future<UserModel?> restoreSession() {
    final UserModel? already = _user;
    if (already != null && _accessToken != null) {
      return Future<UserModel?>.value(already);
    }
    return _restoring ??= _doRestore().whenComplete(() => _restoring = null);
  }

  Future<UserModel?> _doRestore() async {
    final String? refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) {
      return null;
    }
    try {
      final ApiResponse response = await send(
        'POST',
        '/v1/auth/refresh',
        body: <String, dynamic>{'refreshToken': refreshToken},
        authenticated: false,
      );
      return await _startSession(response.asMap);
    } on AuthFailureException {
      await _endSession();
      return null;
    } on RemoteSyncException {
      // No connection (or the server is down). The refresh token is still the
      // one we saved, so carry on as the user who was signed in: work is saved
      // on the device and uploaded later. The first request that does get
      // through renews the access token by itself.
      final UserModel? saved = await _savedUser();
      if (saved == null) {
        rethrow;
      }
      _user = saved;
      _business = BusinessInfo.tryFromMap((await _savedSessionMap())?['tenant']);
      _sessionChanges.add(saved);
      return saved;
    }
  }

  /// The saved session: the user's map, with the business under `tenant`.
  Future<Map<String, dynamic>?> _savedSessionMap() async {
    final String? json = await _tokens.readUserJson();
    if (json == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(json);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<UserModel?> _savedUser() async {
    final Map<String, dynamic>? saved = await _savedSessionMap();
    return saved == null ? null : UserModel.fromMap(saved);
  }

  Future<void> logout() async {
    final String? refreshToken = await _tokens.readRefreshToken();
    if (refreshToken != null) {
      try {
        await send(
          'POST',
          '/v1/auth/logout',
          body: <String, dynamic>{'refreshToken': refreshToken},
          authenticated: false,
        );
      } on AppException {
        // Signing out must work even when the server cannot be reached.
      }
    }
    await _endSession();
  }

  Future<UserModel> _startSession(JsonMap tokens) async {
    final Object? access = tokens['accessToken'];
    final Object? refresh = tokens['refreshToken'];
    final Object? user = tokens['user'];
    if (access is! String || refresh is! String || user is! Map<String, dynamic>) {
      throw AuthFailureException(L10n.current.apiClientTheServerSentAn);
    }
    _accessToken = access;
    final BusinessInfo? business = BusinessInfo.tryFromMap(tokens['tenant']);
    await _tokens.saveRefreshToken(refresh);
    await _tokens.saveUserJson(
      jsonEncode(<String, dynamic>{...user, if (business != null) 'tenant': business.toMap()}),
    );
    _business = business;
    final UserModel model = UserModel.fromMap(user);
    // Announce a different person only: a token refresh is not a new sign-in.
    final bool newPerson = _user?.id != model.id;
    _user = model;
    if (newPerson) {
      _sessionChanges.add(model);
    }
    return model;
  }

  Future<void> _endSession() async {
    final bool wasSignedIn = _user != null || _accessToken != null;
    _accessToken = null;
    _user = null;
    _business = null;
    await _tokens.clear();
    if (wasSignedIn) {
      _sessionChanges.add(null);
    }
  }

  /// Gets a new access token with the refresh token. Concurrent callers share
  /// one attempt, because every refresh token can only be used once.
  Future<bool> _refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final String? refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    try {
      final ApiResponse response = await send(
        'POST',
        '/v1/auth/refresh',
        body: <String, dynamic>{'refreshToken': refreshToken},
        authenticated: false,
      );
      await _startSession(response.asMap);
      return true;
    } on AuthFailureException {
      return false;
    }
  }

  // ---- live updates --------------------------------------------------------

  /// A stream of "the server has news". It emits the kind of signal: `ready` once when
  /// the connection opens (catch up now, something may have been missed), `changed`
  /// whenever something in this business changed, and `notification` when a new
  /// notification was made (the bell). It carries no data: the listener pulls what
  /// changed with the normal sync. It ends when the
  /// connection is closed (the server ends it after half an hour) and fails
  /// when the connection is lost or silent for too long, so the caller
  /// reconnects.
  Stream<String> openChangeStream() async* {
    if (_accessToken == null && !await _refresh()) {
      return;
    }
    http.StreamedResponse response = await _requestStream();
    if (response.statusCode == 401) {
      await response.stream.drain<void>();
      if (!await _refresh()) {
        return;
      }
      response = await _requestStream();
    }
    if (response.statusCode != 200) {
      await response.stream.drain<void>();
      throw exceptionFor(response.statusCode, null);
    }
    final Stream<String> lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        // The server sends a keep-alive line every 25 seconds: silence means the connection is dead.
        .timeout(const Duration(seconds: 75));
    String type = '';
    await for (final String line in lines) {
      if (line.isEmpty) {
        if (type == 'ready' || type == 'changed' || type == 'notification') {
          yield type;
        }
        type = '';
      } else if (line.startsWith('event:')) {
        type = line.substring(6).trim();
      }
    }
  }

  Future<http.StreamedResponse> _requestStream() {
    final http.Request request = http.Request('GET', Uri.parse('$_baseUrl/v1/sync/stream'));
    request.headers['Accept'] = 'text/event-stream';
    final String? token = _accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _streamHttp.send(request).timeout(_timeout);
  }

  // ---- requests ------------------------------------------------------------

  Future<ApiResponse> get(String path, {Map<String, String>? query}) =>
      send('GET', path, query: query);

  Future<ApiResponse> post(String path, {Object? body, String? idempotencyKey}) =>
      send('POST', path, body: body, idempotencyKey: idempotencyKey);

  Future<ApiResponse> put(String path, {Object? body, String? idempotencyKey}) =>
      send('PUT', path, body: body, idempotencyKey: idempotencyKey);

  Future<ApiResponse> patch(String path, {Object? body, String? idempotencyKey}) =>
      send('PATCH', path, body: body, idempotencyKey: idempotencyKey);

  Future<ApiResponse> delete(String path, {String? idempotencyKey}) =>
      send('DELETE', path, idempotencyKey: idempotencyKey);

  /// Sends a request. [idempotencyKey] makes a repeat of the same write safe:
  /// the server answers the retry with the first answer instead of doing the
  /// action twice (use the id of the thing being created).
  Future<ApiResponse> send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    String? idempotencyKey,
    bool authenticated = true,
  }) async {
    final ApiResponse first = await _once(
      method, path, query, body, idempotencyKey, authenticated);
    if (first.status != 401 || !authenticated) {
      return _checked(first);
    }
    // The access token expired: refresh once and try again.
    if (!await _refresh()) {
      await _endSession();
      throw AuthFailureException(L10n.current.apiClientYourSessionEndedPlease);
    }
    return _checked(
        await _once(method, path, query, body, idempotencyKey, authenticated));
  }

  Future<ApiResponse> _once(
    String method,
    String path,
    Map<String, String>? query,
    Object? body,
    String? idempotencyKey,
    bool authenticated,
  ) async {
    final Uri uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final http.Request request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final String? token = _accessToken;
    if (authenticated && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (idempotencyKey != null) {
      request.headers['Idempotency-Key'] = idempotencyKey;
    }
    try {
      final http.StreamedResponse streamed =
          await _http.send(request).timeout(_timeout);
      final http.Response response = await http.Response.fromStream(streamed);
      return ApiResponse(response.statusCode, _decode(response.body));
    } on TimeoutException {
      throw RemoteSyncException(
          L10n.current.apiClientTheServerTookToo);
    } on http.ClientException catch (e) {
      // The address and the reason help to tell a wrong address from a
      // blocked or stopped server.
      debugPrint('ApiClient: ${request.method} $uri failed: ${e.message}');
      throw RemoteSyncException(
          L10n.current.apiClientCannotReachTheServer(_baseUrl, e.message));
    }
  }

  Object? _decode(String text) {
    if (text.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  /// Returns [response] when it succeeded, otherwise throws the matching exception.
  ApiResponse _checked(ApiResponse response) {
    if (response.status >= 200 && response.status < 300) {
      return response;
    }
    throw exceptionFor(response.status, response.body);
  }
}

/// The exception for a failed answer. The API sends `message` as text, or as a
/// list of texts when several fields are wrong.
AppException exceptionFor(int status, Object? body) {
  String message = '';
  String code = '';
  Map<String, Object?> params = const <String, Object?>{};
  if (body is Map<String, dynamic>) {
    final Object? raw = body['message'];
    if (raw is String) {
      message = raw;
    } else if (raw is List<Object?>) {
      message = raw.whereType<String>().join('\n');
    }
    final Object? rawCode = body['code'];
    if (rawCode is String) {
      code = rawCode;
    }
    final Object? rawParams = body['params'];
    if (rawParams is Map<String, dynamic>) {
      params = rawParams;
    }
  }
  // A code this app knows is written in the app's language; any other keeps the
  // server's English text (an older app, or an error added later).
  final String? known = code.isEmpty ? null : apiErrorText(L10n.current, code, params);
  if (known != null) {
    message = known;
  }
  switch (status) {
    case 400:
    case 404:
    case 409:
    case 422:
      return ValidationException(
          message.isEmpty ? L10n.current.apiClientTheServerRefusedThis : message, code: code);
    case 401:
      return AuthFailureException(
          message.isEmpty ? L10n.current.apiClientIncorrectEmailOrPassword : message, code: code);
    case 403:
      return PermissionDeniedException(
          message.isEmpty ? L10n.current.apiClientYouAreNotAllowed : message, code: code);
    case 429:
      return RemoteSyncException(L10n.current.apiClientTooManyAttemptsPlease, code: code);
    default:
      return RemoteSyncException(L10n.current.apiClientTheServerHadA(status), code: code);
  }
}
