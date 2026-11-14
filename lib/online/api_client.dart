import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/online/token_store.dart';

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
  })  : _http = httpClient,
        _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _tokens = tokens,
        _timeout = timeout;

  final http.Client _http;
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

  bool get isSignedIn => _accessToken != null;

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
    }
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
      throw const AuthFailureException('The server sent an unexpected sign-in answer.');
    }
    _accessToken = access;
    await _tokens.saveRefreshToken(refresh);
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

  // ---- requests ------------------------------------------------------------

  Future<ApiResponse> get(String path, {Map<String, String>? query}) =>
      send('GET', path, query: query);

  Future<ApiResponse> post(String path, {Object? body, String? idempotencyKey}) =>
      send('POST', path, body: body, idempotencyKey: idempotencyKey);

  Future<ApiResponse> put(String path, {Object? body}) =>
      send('PUT', path, body: body);

  Future<ApiResponse> patch(String path, {Object? body}) =>
      send('PATCH', path, body: body);

  Future<ApiResponse> delete(String path) => send('DELETE', path);

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
      throw const AuthFailureException('Your session ended. Please sign in again.');
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
      throw const RemoteSyncException(
          'The server took too long to answer. Please try again.');
    } on http.ClientException {
      throw const RemoteSyncException(
          'Cannot reach the server. Check your connection and try again.');
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
  if (body is Map<String, dynamic>) {
    final Object? raw = body['message'];
    if (raw is String) {
      message = raw;
    } else if (raw is List<Object?>) {
      message = raw.whereType<String>().join('\n');
    }
  }
  switch (status) {
    case 400:
    case 404:
    case 409:
    case 422:
      return ValidationException(
          message.isEmpty ? 'The server refused this request.' : message);
    case 401:
      return AuthFailureException(
          message.isEmpty ? 'Incorrect email or password.' : message);
    case 403:
      return PermissionDeniedException(
          message.isEmpty ? 'You are not allowed to do this.' : message);
    case 429:
      return const RemoteSyncException(
          'Too many attempts. Please wait a moment and try again.');
    default:
      return RemoteSyncException(
          'The server had a problem (error $status). Please try again.');
  }
}
