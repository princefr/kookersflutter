import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-facing theme mode preference.
enum KookersThemeMode {
  /// Follows the OS theme.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

extension KookersThemeModeX on KookersThemeMode {
  String get label => switch (this) {
        KookersThemeMode.system => 'themeMode.system',
        KookersThemeMode.light => 'themeMode.light',
        KookersThemeMode.dark => 'themeMode.dark',
      };

  ThemeMode toMaterialThemeMode() => switch (this) {
        KookersThemeMode.system => ThemeMode.system,
        KookersThemeMode.light => ThemeMode.light,
        KookersThemeMode.dark => ThemeMode.dark,
      };
}

/// Singleton-ish controller that exposes the current theme mode as a
/// [ValueNotifier] and persists the user's choice to
/// [SharedPreferences].
///
/// Wire it in `main.dart`:
///   final themeController = ThemeController();
///   await themeController.load();
///   ...
///   ValueListenableBuilder<KookersThemeMode>(
///     valueListenable: themeController,
///     builder: (_, mode, __) => GetMaterialApp(
///       theme: KookersTheme.light,
///       darkTheme: KookersTheme.dark,
///       themeMode: mode.toMaterialThemeMode(),
///       ...
///     ),
///   )
///
/// Then anywhere in the UI: `ThemeController.of(context).set(...)`.
class ThemeController extends ValueNotifier<KookersThemeMode> {
  ThemeController() : super(KookersThemeMode.system);

  static const _prefsKey = 'kookers_theme_mode';

  /// Loads the persisted preference. Defaults to [system] if none.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    value = _parse(raw) ?? KookersThemeMode.system;
  }

  /// Updates the preference and persists it.
  Future<void> set(KookersThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  /// Returns the [ThemeData] for the current preference given the
  /// platform brightness (used to resolve [system]).
  ThemeData resolve([Brightness? platformBrightness]) {
    final brightness = platformBrightness ??
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final effective = value == KookersThemeMode.system
        ? (brightness == Brightness.dark
            ? KookersThemeMode.dark
            : KookersThemeMode.light)
        : value;
    return effective == KookersThemeMode.dark
        ? KookersTheme.dark
        : KookersTheme.light;
  }

  static KookersThemeMode? _parse(String? raw) {
    if (raw == null) return null;
    return KookersThemeMode.values.cast<KookersThemeMode?>().firstWhere(
          (m) => m?.name == raw,
          orElse: () => null,
        );
  }

  /// Convenience accessor — looks up the [ThemeController] in the
  /// widget tree. Throws if none is found, so callers must wrap their
  /// subtree in a `ValueListenableBuilder` or `Provider`.
  static ThemeController of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_ThemeControllerScope>();
    assert(widget != null,
        'ThemeController.of() called outside of a _ThemeControllerScope');
    return widget!.controller;
  }

  /// Wraps [child] in an inherited widget that exposes this controller.
  Widget scope({required Widget child}) {
    return ValueListenableBuilder<KookersThemeMode>(
      valueListenable: this,
      builder: (_, mode, child) => _ThemeControllerScope(
        controller: this,
        mode: mode,
        child: child!,
      ),
      child: child,
    );
  }
}

class _ThemeControllerScope extends InheritedWidget {
  final ThemeController controller;
  final KookersThemeMode mode;

  const _ThemeControllerScope({
    required this.controller,
    required this.mode,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ThemeControllerScope oldWidget) =>
      mode != oldWidget.mode;
}
