import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class AuthentificationService {
  final FirebaseAuth firebaseAuth;
  AuthentificationService({required this.firebaseAuth});

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<User?> userConnected() async {
    return firebaseAuth.currentUser;
  }

 


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

  }

  Future<void> verifyPhone({required String phone,
   required ValueSetter<PhoneAuthCredential> verificationComplted,
   required ValueSetter<FirebaseAuthException> error,
   required ValueSetter<String> codeisSent, 
   required ValueSetter<String> codeTimeOut}) async {

    await firebaseAuth.verifyPhoneNumber(phoneNumber: phone,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) {
        verificationComplted(credential);
     },
     verificationFailed: (FirebaseAuthException e) {
        error(e);
     },
     codeSent: (String verificationId, int? resendToken) {
      codeisSent(verificationId);

     },
     codeAutoRetrievalTimeout: (String verificationId) {
       codeTimeOut(verificationId);
     });
  }


  Future<UserCredential> signInWithVerificationID(String verificationId, String smsCode) async {
     PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      return firebaseAuth.signInWithCredential(phoneAuthCredential);
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential phoneAuthCredential){
    return firebaseAuth.signInWithCredential(phoneAuthCredential);
  }


  Future<UserCredential> signAnonymous(){
    return this.firebaseAuth.signInAnonymously();
  }
}