

import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashService {
  final FirebaseCrashlytics crashlytics;
  CrashService({required this.crashlytics});


  Future<void> identifyUser(String userId) async {
      this.crashlytics.setUserIdentifier(userId);
  }


  Future<void> logMessage(String message) async {
      this.crashlytics.log(message);
  }



  
  
}