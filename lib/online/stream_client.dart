// A client that can read a response while it is still arriving (live updates).
// The browser's default client waits for the whole answer, which never comes
// for a stream, so the web uses the Fetch API; every other platform's default
// client already streams.
export 'package:a2_stocks/online/stream_client_io.dart'
    if (dart.library.js_interop) 'package:a2_stocks/online/stream_client_web.dart';
