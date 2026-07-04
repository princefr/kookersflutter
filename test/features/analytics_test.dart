// Tests for the analytics service (FEATURE_PROPOSALS.md §9.5).
//
// Replaces the production Firebase backend with a recording one and
// asserts that every typed event helper logs the expected event name
// and parameters.

import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Services/AnalyticsService.dart';

void main() {
  late _RecordingBackend backend;

  setUp(() {
    backend = _RecordingBackend();
    KookersAnalytics.backend = backend;
  });

  test('viewDish logs publication_id', () async {
    await KookersEvents.viewDish(publicationId: 'p123');
    expect(backend.events, hasLength(1));
    expect(backend.events.single.name, 'view_dish');
    expect(backend.events.single.parameters['publication_id'], 'p123');
  });

  test('likeDish logs liked=false on unlike', () async {
    await KookersEvents.likeDish(publicationId: 'p1', liked: false);
    expect(backend.events.single.name, 'like_dish');
    expect(backend.events.single.parameters['liked'], false);
  });

  test('startPublish logs the start_publish event', () async {
    await KookersEvents.startPublish();
    expect(backend.events.single.name, 'start_publish');
  });

  test('publishSuccess logs the publication id', () async {
    await KookersEvents.publishSuccess(publicationId: 'pub-9');
    expect(backend.events.single.name, 'publish_success');
    expect(backend.events.single.parameters['publication_id'], 'pub-9');
  });

  test('startCheckout uses Firebase reserved begin_checkout name', () async {
    await KookersEvents.startCheckout(publicationId: 'p1');
    expect(backend.events.single.name, 'begin_checkout');
  });

  test('tipSelected logs the amount', () async {
    await KookersEvents.tipSelected(amount: 5);
    expect(backend.events.single.name, 'tip_selected');
    expect(backend.events.single.parameters['amount'], 5);
  });

  test('purchaseSuccess logs the standard purchase event', () async {
    await KookersEvents.purchaseSuccess(
      transactionId: 't1',
      currency: 'EUR',
      value: 25.0,
    );
    expect(backend.events.single.name, 'purchase');
    // Backend.logPurchase is called; we record the underlying call.
    expect(backend.purchases, hasLength(1));
    expect(backend.purchases.single.currency, 'EUR');
    expect(backend.purchases.single.value, 25.0);
  });

  test('purchaseSuccess logs a purchase_with_tip event when tip > 0',
      () async {
    await KookersEvents.purchaseSuccess(
      transactionId: 't2',
      currency: 'EUR',
      value: 30,
      tip: 5,
    );
    expect(backend.events, hasLength(1));
    expect(backend.events.single.name, 'purchase_with_tip');
    expect(backend.events.single.parameters['tip'], 5);
  });

  test('reorderTapped logs the original order id', () async {
    await KookersEvents.reorderTapped(originalOrderId: 'order-abc');
    expect(backend.events.single.name, 'reorder_tapped');
    expect(
        backend.events.single.parameters['original_order_id'], 'order-abc');
  });

  test('languageChanged logs the locale code', () async {
    await KookersEvents.languageChanged(locale: 'de');
    expect(backend.events.single.name, 'language_changed');
    expect(backend.events.single.parameters['locale'], 'de');
  });

  test('themeChanged logs the mode name', () async {
    await KookersEvents.themeChanged(mode: 'dark');
    expect(backend.events.single.name, 'theme_changed');
    expect(backend.events.single.parameters['mode'], 'dark');
  });

  test('viewHome logs a screen view', () async {
    await KookersEvents.viewHome();
    expect(backend.screenViews, ['home']);
  });

  test('viewTab logs the tab index', () async {
    await KookersEvents.viewTab(index: 2);
    expect(backend.events.single.name, 'view_tab');
    expect(backend.events.single.parameters['tab_index'], 2);
  });

  test('null backend is the default before init()', () {
    // Re-init the singleton by overriding the backend.
    KookersAnalytics.backend = _NullAnalyticsBackend();
    // These should be no-ops and not throw.
    KookersEvents.startPublish();
    KookersEvents.viewHome();
    KookersEvents.purchaseSuccess(
        transactionId: '', currency: 'EUR', value: 0);
  });
}

class _RecordingBackend implements AnalyticsBackend {
  final List<_RecordedEvent> events = [];
  final List<_RecordedPurchase> purchases = [];
  final List<String> screenViews = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  }) async {
    events.add(_RecordedEvent(name, Map<String, Object?>.from(parameters)));
  }

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {
    screenViews.add(screenName);
  }

  @override
  Future<void> logSignUp({required String method}) async {}

  @override
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) async {
    purchases
        .add(_RecordedPurchase(currency, value, transactionId));
  }
}

class _RecordedEvent {
  final String name;
  final Map<String, Object?> parameters;
  _RecordedEvent(this.name, this.parameters);
}

class _RecordedPurchase {
  final String currency;
  final double value;
  final String? transactionId;
  _RecordedPurchase(this.currency, this.value, this.transactionId);
}

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
