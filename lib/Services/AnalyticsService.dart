import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';


// https://pub.dev/packages/firebase_analytics/example
// analytics for the apps.




class AnalyticsService { 
  FirebaseAnalytics analytics;  
  AnalyticsService({required this.analytics});



  Future<void> sendAnalyticsEvent(String eventName) async {
      // parameters: <String, dynamic>{
      //   'string': 'string',
      //   'int': 42,
      //   'long': 12345678910,
      //   'double': 42.0,
      //   'bool': true,
      // },
    this.analytics.logEvent(name: eventName, parameters: <String, dynamic>{});
  }


  Future<void> identifyUser(String userId) async {
      this.analytics.setUserId(userId);
  }

  Future<void> setCurrentScreen(String userScreen) async {
    this.analytics.setCurrentScreen(screenName: userScreen);
  }


  Future<void> logSignup() async {
    this.analytics.logSignUp(signUpMethod: 'phone_number');
  }


  Future<void> logRefund(String currency, double value, String transactionId) async {
    this.analytics.logPurchaseRefund(
      currency: currency,
      value: value,
      transactionId: transactionId,
    );
  }

  Future<void> logPurchase(String currency, double value, String transactionId) async {
    this.analytics.logEcommercePurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
    );
  }

  


}