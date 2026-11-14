/// Address of the backend API. Set it when building:
///
///     flutter build web --dart-define=API_BASE_URL=https://api.yourshop.com
///
/// The default is the API running on the developer's own computer.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

/// How often an open web admin asks the server for other people's changes.
const Duration onlinePollInterval = Duration(seconds: 30);
