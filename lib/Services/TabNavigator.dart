import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lightweight global tab-navigation helper.
///
/// The previous codebase had no way to programmatically switch tabs
/// from outside `TabHome` — the `BehaviorSubject<int>` was private to
/// the `_TabHomeState`. That meant empty-state CTAs like "Browse
/// dishes" (which should jump to the Home tab) had nowhere to go.
///
/// This class sidesteps that by using `Get.until` + a route name. The
/// `TabHome` widget registers itself as a named route (`/home`) on
/// startup; CTAs can then call `TabNavigator.goTab(context, 0)` and
/// the helper pops back to `TabHome` and emits an event the
/// `TabHome` listens for to switch pages.
class TabNavigator {
  TabNavigator._();

  /// Switches to the given tab index on the main TabHome shell.
  ///
  /// If we're deep in a navigation stack (e.g. inside `OrderPageChild`),
  /// this pops back to the TabHome root first, then switches tabs.
  static void goTab(BuildContext context, int index) {
    // Pop back to the TabHome root.
    Get.until((route) => route.isFirst);
    // Emit the switch event via Get's route name mechanism. TabHome
    // subscribes to this stream in initState.
    TabNavBus.instance.switchTo(index);
  }
}

/// A simple broadcast bus for tab-switch events. Decouples emitters
/// (CTAs in empty states, deep-link handlers, push notification taps)
/// from the `TabHome` widget that owns the `PageController`.
class TabNavBus {
  TabNavBus._();
  static final TabNavBus instance = TabNavBus._();

  final _controller = _StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;

  void switchTo(int index) => _controller.add(index);
  void dispose() => _controller.close();
}

// Minimal stream controller wrapper so we don't add a rxdart dep to
// this file (it's already used elsewhere in the project, but keeping
// this file dependency-free makes it easier to test in isolation).
class _StreamController<T> {
  final _listeners = <void Function(T)>[];
  bool _closed = false;

  void add(T event) {
    if (_closed) return;
    for (final l in List<void Function(T)>.from(_listeners)) {
      l(event);
    }
  }

  Stream<T> get stream => _Stream<T>(this);
  void close() {
    _closed = true;
    _listeners.clear();
  }
}

class _Stream<T> extends Stream<T> {
  final _StreamController<T> _controller;
  _Stream(this._controller);

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final sub = _StreamSubscription<T>(onData);
    _controller._listeners.add(sub._handle);
    return sub;
  }
}

class _StreamSubscription<T> extends StreamSubscription<T> {
  final void Function(T)? _onData;
  bool _isPaused = false;
  _StreamSubscription(this._onData);

  void _handle(T event) {
    if (!_isPaused) _onData?.call(event);
  }

  @override
  Future<void> cancel() async {}
  @override
  void onData(void Function(T event)? handleData) {}
  @override
  void onDone(void Function()? handleDone) {}
  @override
  void onError(Function? handleError) {}
  @override
  void pause([Future<void>? resumeSignal]) => _isPaused = true;
  @override
  void resume() => _isPaused = false;
  @override
  bool get isPaused => _isPaused;
}
