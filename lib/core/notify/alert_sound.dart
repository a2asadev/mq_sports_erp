import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Which sound: a bright chime for a new online order, a calmer, lower pair for stock running low.
enum AlertSoundKind { newOrder, stock }

/// Plays an alert sound. A sound that cannot play (no audio device, a browser
/// that has not allowed sound yet) never throws: the alert is a convenience.
abstract class AlertSound {
  Future<void> play(AlertSoundKind kind);
}

class AssetAlertSound implements AlertSound {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> play(AlertSoundKind kind) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(kind == AlertSoundKind.newOrder ? 'sounds/new_order.wav' : 'sounds/stock_alert.wav'));
    } catch (error) {
      debugPrint('Alert sound could not play: $error');
    }
  }
}
