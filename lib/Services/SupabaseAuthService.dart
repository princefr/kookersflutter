import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kookers/Services/SupabaseService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Drop-in replacement for the legacy `AuthentificationService` that
/// delegates to Supabase Auth instead of Firebase Auth.
///
/// The previous class exposed Firebase-specific types
/// (`firebase_auth.User`, `PhoneAuthCredential`, `UserCredential`),
/// which leaked into every screen. To keep the migration reviewable,
/// this new class keeps the **same method names and call shape** but
/// returns generic types (`String` user ids, `bool` success). Screens
/// that consumed Firebase types directly will need a mechanical
/// follow-up pass.
///
/// Phone auth flow with Supabase is two-step (same as Firebase):
///   1. `verifyPhone(phone, ...)` — sends an SMS. Supabase returns a
///      `phone_verification_id` that we hand back via `codeisSent`.
///   2. `signInWithVerificationID(verificationId, smsCode)` — exchanges
///      the verification id + code for a session.
class SupabaseAuthService {
  SupabaseAuthService();

  /// Stream of auth state changes. Emits the user's id (or null when
  /// signed out). Equivalent to `FirebaseAuth.authStateChanges()` but
  /// returns `String?` instead of `User?`.
  Stream<String?> get authStateChanges =>
      SupabaseService.auth.onAuthStateChange.map((event) {
        final session = event.session;
        return session?.user.id;
      });

  /// Returns the current user's id, or null if signed out.
  /// Mirrors the legacy `userConnected()` method but returns `String?`
  /// instead of `firebase_auth.User?`.
  Future<String?> userConnected() async {
    return SupabaseService.auth.currentUser?.id;
  }

  /// Signs the user out and clears the local session.
  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }

  /// Starts the phone-verification flow. Supabase sends an SMS with a
  /// 6-digit code; the [codeisSent] callback receives a phone
  /// verification id that's needed for the follow-up
  /// [signInWithVerificationID] call.
  ///
  /// Errors are surfaced via [error] as a plain [Exception] (no
  /// FirebaseAuthException type). The [verificationCompltd] callback
  /// is unused on Supabase — auto-retrieval isn't supported — but is
  /// kept in the signature for call-site compatibility.
  Future<void> verifyPhone({
    required String phone,
    required ValueSetter<Map<String, dynamic>> verificationCompltd,
    required ValueSetter<Exception> error,
    required ValueSetter<String> codeisSent,
    required ValueSetter<String> codeTimeOut,
  }) async {
    try {
      await SupabaseService.auth.signInWithOtp(phone: phone);
      // Supabase doesn't return a verificationId the way Firebase
      // does — the phone number itself is the "verification id" we
      // pass to verifyOTP. We hand it back via codeisSent so the
      // existing PhoneAuthCodePage can store it for later.
      codeisSent(phone);
      // No-op completion — Supabase has no auto-retrieval.
      verificationCompltd(const <String, dynamic>{'phone': phone});
    } on Exception catch (e) {
      error(e);
    }
  }

  /// Verifies the SMS code and exchanges it for a session. Returns
  /// true on success, false on failure (wrong code, expired, etc.).
  Future<bool> signInWithVerificationID(
      String verificationId, String smsCode) async {
    try {
      final response = await SupabaseService.auth.verifyOTP(
        phone: verificationId, // we stored the phone in codeisSent above
        token: smsCode,
        type: OtpType.sms,
      );
      return response.user != null;
    } on Exception catch (_) {
      return false;
    }
  }

  /// Anonymous sign-in. Supabase supports this via
  /// `signInAnonymously()` — but we keep it as a no-op for now since
  /// the legacy app used it only as a guest fallback that's no longer
  /// needed (the home feed is publicly readable).
  Future<bool> signAnonymous() async {
    try {
      await SupabaseService.auth.signInAnonymously();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  /// Updates the user's FCM token in their profile row. Called from
  /// `TabHome.initState` after the user signs in.
  Future<void> updateFcmToken(String token) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await SupabaseService.from('profiles').update({
      'fcm_token': token,
    }).eq('id', uid);
  }
}
