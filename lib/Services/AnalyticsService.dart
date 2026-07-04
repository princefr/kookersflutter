import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralised analytics surface for the whole app.
///
/// Wrap every analytics call in one of the typed helpers below — never
/// call `FirebaseAnalytics` directly from a screen. The reasons:
///
///   1. Centralising means we can later swap backends (e.g. add PostHog
///      alongside Firebase) without touching every screen.
///   2. The typed helpers make it impossible to typo an event name or
///      forget a required parameter.
///   3. The class is mockable in tests via the [AnalyticsBackend]
///      interface — set `KookersAnalytics.backend = _RecordingBackend()`
///      in test setUp and assert on the recorded events.
///
/// Standard event names follow Firebase's reserved list where one
/// exists (so they show up in the standard funnels in the Firebase
/// console) — see https://firebase.google.com/docs/reference/cpp/group/event-names.
library;

/// Backend interface. [FirebaseAnalyticsBackend] is the production
/// implementation; tests inject a recording one.
abstract class AnalyticsBackend {
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  });

  Future<void> setUserId(String? id);
  Future<void> logScreenView({required String screenName});
  Future<void> logSignUp({required String method});
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  });
}

class FirebaseAnalyticsBackend implements AnalyticsBackend {
  FirebaseAnalyticsBackend(this._analytics);
  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  }) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  @override
  Future<void> logScreenView({required String screenName}) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> logSignUp({required String method}) =>
      _analytics.logSignUp(signUpMethod: method);

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) =>
      _analytics.logPurchase(
        currency: currency,
        value: value,
        transactionId: transactionId,
      );
}

/// Singleton entry point. Replaced with a recording backend in tests.
class KookersAnalytics {
  KookersAnalytics._();
  static AnalyticsBackend backend = _NullAnalyticsBackend();

  /// Initialise with the real Firebase Analytics instance. Called
  /// from `main()` once Firebase has been set up.
  static void init(FirebaseAnalytics analytics) {
    backend = FirebaseAnalyticsBackend(analytics);
  }
}

/// Default no-op backend used until [KookersAnalytics.init] is called
/// (e.g. in unit tests). All calls are silently swallowed.
class _NullAnalyticsBackend implements AnalyticsBackend {
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  }) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> logSignUp({required String method}) async {}

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) async {}
}

// ---------------------------------------------------------------------------
// Typed event helpers. Add new ones here as new flows get instrumented.
// ---------------------------------------------------------------------------

abstract final class KookersEvents {
  KookersEvents._();

  /// Buyer tapped a food card on the home feed.
  static Future<void> viewDish({required String publicationId}) =>
      KookersAnalytics.backend.logEvent(
        name: 'view_dish',
        parameters: {'publication_id': publicationId},
      );

  /// Buyer tapped the like / unlike button on a food card.
  static Future<void> likeDish({
    required String publicationId,
    required bool liked,
  }) =>
      KookersAnalytics.backend.logEvent(
        name: 'like_dish',
        parameters: {
          'publication_id': publicationId,
          'liked': liked,
        },
      );

  /// Buyer tapped the publish FAB (auth + seller gate happens after).
  static Future<void> startPublish() =>
      KookersAnalytics.backend.logEvent(name: 'start_publish');

  /// Seller successfully published a new dish.
  static Future<void> publishSuccess({required String publicationId}) =>
      KookersAnalytics.backend.logEvent(
        name: 'publish_success',
        parameters: {'publication_id': publicationId},
      );

  /// Buyer opened the checkout screen.
  static Future<void> startCheckout({required String publicationId}) =>
      KookersAnalytics.backend.logEvent(
        name: 'begin_checkout',
        parameters: {'publication_id': publicationId},
      );

  /// Buyer selected a tip amount at checkout.
  static Future<void> tipSelected({required num amount}) =>
      KookersAnalytics.backend.logEvent(
        name: 'tip_selected',
        parameters: {'amount': amount},
      );

  /// Buyer completed a purchase.
  static Future<void> purchaseSuccess({
    required String transactionId,
    required String currency,
    required double value,
    num? tip,
  }) async {
    await KookersAnalytics.backend.logPurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
    );
    if (tip != null && tip > 0) {
      await KookersAnalytics.backend.logEvent(
        name: 'purchase_with_tip',
        parameters: {
          'transaction_id': transactionId,
          'tip': tip,
          'currency': currency,
        },
      );
    }
  }

  /// Buyer tapped "Order again" from the order detail screen.
  static Future<void> reorderTapped({required String originalOrderId}) =>
      KookersAnalytics.backend.logEvent(
        name: 'reorder_tapped',
        parameters: {'original_order_id': originalOrderId},
      );

  /// User changed the app language.
  static Future<void> languageChanged({required String locale}) =>
      KookersAnalytics.backend.logEvent(
        name: 'language_changed',
        parameters: {'locale': locale},
      );

  /// User changed the theme mode.
  static Future<void> themeChanged({required String mode}) =>
      KookersAnalytics.backend.logEvent(
        name: 'theme_changed',
        parameters: {'mode': mode},
      );

  /// User opened the home feed.
  static Future<void> viewHome() =>
      KookersAnalytics.backend.logScreenView(screenName: 'home');

  /// User opened a tab on the TabHome shell.
  static Future<void> viewTab({required int index}) =>
      KookersAnalytics.backend.logEvent(
        name: 'view_tab',
        parameters: {'tab_index': index},
      );
}
