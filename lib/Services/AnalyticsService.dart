import 'package:firebase_analytics/firebase_analytics.dart';

// https://pub.dev/packages/firebase_analytics/example
// analytics for the apps.

class AnalyticsService {
  FirebaseAnalytics analytics;
  AnalyticsService({required this.analytics});

  Future<void> sendAnalyticsEvent(String eventName) async {
    this.analytics.logEvent(name: eventName, parameters: <String, dynamic>{});
  }

  Future<void> identifyUser(String userId) async {
    this.analytics.setUserId(id: userId);
  }

  Future<void> setCurrentScreen(String userScreen) async {
    this.analytics.logScreenView(screenName: userScreen);
  }

  Future<void> logSignup() async {
    this.analytics.logSignUp(signUpMethod: 'phone_number');
  }

  Future<void> logRefund(
      String currency, double value, String transactionId) async {
    this.analytics.logRefund(
          currency: currency,
          value: value,
          transactionId: transactionId,
        );
  }

  Future<void> logPurchase(
      String currency, double value, String transactionId) async {
    this.analytics.logPurchase(
          currency: currency,
          value: value,
          transactionId: transactionId,
        );
  }
}
