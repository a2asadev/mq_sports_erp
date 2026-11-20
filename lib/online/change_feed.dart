import 'dart:async';

/// Keeps a live-updates connection open and reacts to it.
///
/// [open] gives a stream of "the server has news" (see ApiClient.openChangeStream).
/// Each signal makes [onSignal] run, once per quiet moment: a burst of signals
/// is one call. A `notification` signal (a new item for the bell) runs
/// [onNotification] instead, and the opening `ready` also checks the bell, because
/// one may have been made while the connection was down. When the connection ends or fails the feed waits a little
/// (1 s, 2 s, 4 s ... at most 30 s) and connects again, for as long as it is
/// started. Nothing depends on it: the devices keep their timers, so a feed
/// that cannot connect only costs the speed.
class ChangeFeed {
  ChangeFeed({
    required Stream<String> Function() open,
    required Future<void> Function() onSignal,
    Future<void> Function()? onNotification,
    this.quiet = const Duration(milliseconds: 300),
    this.firstWait = const Duration(seconds: 1),
    this.longestWait = const Duration(seconds: 30),
  })  : _open = open,
        _onSignal = onSignal,
        _onNotification = onNotification;

  final Stream<String> Function() _open;
  final Future<void> Function() _onSignal;
  final Future<void> Function()? _onNotification;

  /// How long to wait for more signals before acting on them.
  final Duration quiet;
  final Duration firstWait;
  final Duration longestWait;

  bool _running = false;
  int _failures = 0;
  Timer? _debounce;
  Timer? _debounceNotification;
  Timer? _backoff;
  StreamSubscription<String>? _subscription;
  Completer<void>? _wake;

  bool get isRunning => _running;

  /// Opens the connection (and keeps it open). Safe to call twice.
  void start() {
    if (_running) {
      return;
    }
    _running = true;
    _failures = 0;
    unawaited(_loop());
  }

  /// Closes the connection and stops reconnecting.
  Future<void> stop() async {
    _running = false;
    _debounce?.cancel();
    _debounceNotification?.cancel();
    _backoff?.cancel();
    final StreamSubscription<String>? subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    _complete();
  }

  /// Connects again now instead of waiting out the pause (the network came back).
  void reconnectNow() {
    if (!_running) {
      return;
    }
    _backoff?.cancel();
    _complete();
  }

  void _complete() {
    final Completer<void>? wake = _wake;
    _wake = null;
    if (wake != null && !wake.isCompleted) {
      wake.complete();
    }
  }

  Future<void> _loop() async {
    while (_running) {
      // One connection: ends when it closes, fails or the feed stops.
      final Completer<void> ended = Completer<void>();
      _wake = ended;
      bool heard = false;
      try {
        _subscription = _open().listen(
          (String type) {
            heard = true;
            _failures = 0;
            if (type == 'notification' || type == 'ready') {
              _signalNotification();
            }
            if (type != 'notification') {
              _signal();
            }
          },
          onError: (Object _) => _complete(),
          onDone: _complete,
          cancelOnError: true,
        );
      } catch (_) {
        _complete();
      }
      await ended.future;
      await _subscription?.cancel();
      _subscription = null;
      if (!_running) {
        return;
      }
      if (!heard) {
        _failures += 1;
      }
      // Wait before the next try, unless the network just came back (reconnectNow).
      final Completer<void> pause = Completer<void>();
      _wake = pause;
      final int doublings = (_failures - 1).clamp(0, 5);
      Duration wait = firstWait * (1 << doublings);
      if (wait > longestWait) {
        wait = longestWait;
      }
      _backoff = Timer(wait, _complete);
      await pause.future;
      _backoff?.cancel();
    }
  }

  void _signalNotification() {
    final Future<void> Function()? handler = _onNotification;
    if (handler == null) {
      return;
    }
    _debounceNotification?.cancel();
    _debounceNotification = Timer(quiet, () {
      if (_running) {
        unawaited(handler().catchError((Object _) {}));
      }
    });
  }

  void _signal() {
    _debounce?.cancel();
    _debounce = Timer(quiet, () {
      if (_running) {
        unawaited(_onSignal().catchError((Object _) {}));
      }
    });
  }
}
