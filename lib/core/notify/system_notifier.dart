// The system notification of this platform: the browser's on the web, the
// desktop's (Windows, macOS, Linux) elsewhere. Phones show none yet.
export 'package:a2_stocks/core/notify/system_notifier_base.dart';
export 'package:a2_stocks/core/notify/system_notifier_io.dart'
    if (dart.library.js_interop) 'package:a2_stocks/core/notify/system_notifier_web.dart';
