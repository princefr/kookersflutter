import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class AuthentificationService {
  final FirebaseAuth firebaseAuth;
  AuthentificationService({this.firebaseAuth});

  Stream<User> get authStateChanges => firebaseAuth.authStateChanges();

 


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<Null> verifyPhone({String phone,
   ValueSetter<PhoneAuthCredential> verificationComplted,
   ValueSetter<FirebaseAuthException> error,
   ValueSetter<String> codeisSent}) async {

    await firebaseAuth.verifyPhoneNumber(phoneNumber: phone,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) {
        // ANDROID ONLY!
        //await auth.signInWithCredential(credential);
        verificationComplted(credential);
     },
     verificationFailed: (FirebaseAuthException e) {
            error(e);
     },
     codeSent: (String verificationId, int resendToken) {
       print("code has been sent");
       // prompt the code to the user.
      // Update the UI - wait for the user to enter the SMS code
      //String smsCode = 'xxxx';
      codeisSent(verificationId);

     },
     codeAutoRetrievalTimeout: (String verificationId) {
       codeisSent(verificationId);
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
}