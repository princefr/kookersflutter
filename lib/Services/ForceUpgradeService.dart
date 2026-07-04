import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kookers/UI/Colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Minimum app version enforcement (FEATURE_PROPOSALS.md §9.1).
///
/// On startup, the app fetches a JSON config document containing the
/// minimum required version. If the running app is older, the user is
/// shown a non-dismissible dialog with an "Update" button that opens
/// the App Store / Play Store.
///
/// The config URL is configurable but defaults to a Firestore-backed
/// REST endpoint. Failures (network error, parse error) are silently
/// swallowed — better to let a possibly-outdated app run than to lock
/// the user out because of a misconfigured config endpoint.
class ForceUpgradeService {
  ForceUpgradeService._();

  /// Check whether the running app meets the minimum version
  /// requirement. Returns `true` if the app is OK to run, `false` if
  /// the user must upgrade.
  ///
  /// The [configUrl] should return JSON like:
  ///   { "minimum_app_version": "1.2.0" }
  ///
  /// If the request fails, the parse fails, or the version comparison
  /// fails, we return `true` (fail-open).
  static Future<bool> meetsMinimum({
    String configUrl =
        'https://firestore.googleapis.com/v1/projects/getkookers/databases/(default)/documents/config/app',
    String? currentVersionOverride,
  }) async {
    try {
      final response = await http.get(Uri.parse(configUrl)).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode != 200) return true;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      // Firestore REST returns nested fields under "fields"
      final fields = body['fields'] as Map<String, dynamic>?;
      final minVersionValue = fields?['minimum_app_version'];
      String? minVersion;
      if (minVersionValue is Map) {
        minVersion = (minVersionValue['stringValue'] ??
            minVersionValue['integerValue'] ??
            '') as String?;
      } else if (minVersionValue is String) {
        minVersion = minVersionValue;
      }
      if (minVersion == null || minVersion.isEmpty) return true;

      final packageInfo = await PackageInfo.fromPlatform();
      final current =
          currentVersionOverride ?? packageInfo.version;

      return _versionSatisfies(current, minVersion);
    } catch (_) {
      // Fail-open: never block the user because of a config fetch error.
      return true;
    }
  }

  /// Returns true if [current] >= [minimum] using semver-style
  /// comparison. Falls back to lexicographic comparison if either
  /// string isn't a valid semver.
  static bool _versionSatisfies(String current, String minimum) {
    final currentParts = _parseSemver(current);
    final minParts = _parseSemver(minimum);
    if (currentParts == null || minParts == null) {
      return current.compareTo(minimum) >= 0;
    }
    for (var i = 0; i < 3; i++) {
      if (currentParts[i] > minParts[i]) return true;
      if (currentParts[i] < minParts[i]) return false;
    }
    return true; // equal
  }

  static List<int>? _parseSemver(String version) {
    // Strip build metadata (+) and pre-release (-)
    final clean = version.split(RegExp(r'[+-]')).first;
    final parts = clean.split('.');
    if (parts.length < 2) return null;
    try {
      return parts.map(int.parse).toList(growable: true);
    } catch (_) {
      return null;
    }
  }

  /// Show the non-dismissible upgrade dialog. Doesn't return until the
  /// user taps "Update" (which opens the store) — there's no Cancel.
  static Future<void> showUpgradeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('upgrade.title'.tr()),
          content: Text('upgrade.body'.tr()),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(_storeUrl());
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text('upgrade.action'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the platform-appropriate store URL. The iOS bundle id and
  /// Android package name are baked in (see pubspec.yaml); change them
  /// if the app is repackaged.
  static String _storeUrl() {
    // We can't check Platform.isIOS at compile time here without
    // importing dart:io, which is fine.
    return Theme.of(navigatorKeyForUpgrade.currentContext!).platform ==
            TargetPlatform.iOS
        ? 'https://apps.apple.com/app/id1529436130'
        : 'https://play.google.com/store/apps/details?id=com.getkookers.android';
  }

  /// Stand-in navigator key — the real one is set from `main.dart` so
  /// the static [_storeUrl] can resolve Platform without needing a
  /// BuildContext. Set via `ForceUpgradeService.setNavigatorKey(...)`
  /// at startup.
  static final GlobalKey<NavigatorState> navigatorKeyForUpgrade =
      GlobalKey<NavigatorState>();
}
