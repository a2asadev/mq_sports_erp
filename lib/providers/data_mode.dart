import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the app keeps its data.
enum DataMode {
  /// Mobile and desktop: Hive on the device, uploaded to the cloud by a manual sync.
  localFirst,

  /// Web: online only. Every action goes to the API; nothing is stored on the device.
  onlineOnly;

  bool get isOnline => this == DataMode.onlineOnly;
}

/// The web build is online-only, every other platform is local-first. Tests
/// override this to try either mode on any platform.
final Provider<DataMode> dataModeProvider = Provider<DataMode>(
  (Ref ref) => kIsWeb ? DataMode.onlineOnly : DataMode.localFirst,
);
