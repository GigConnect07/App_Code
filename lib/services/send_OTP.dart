import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;
String verificationId = ""; // This should be stored more securely

Future<void> sendOTP(String phoneNumber) async {
  String formattedPhoneNumber = "+91$phoneNumber"; // Country code hardcoded
  
  // Create a completer to handle the async result
  Completer<void> completer = Completer<void>();
  
  await auth.verifyPhoneNumber(
    phoneNumber: formattedPhoneNumber,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
      try {
        await auth.signInWithCredential(credential);
        print("Automatically Verified & Logged In");
        if (!completer.isCompleted) completer.complete();
      } catch (e) {
        if (!completer.isCompleted) completer.completeError(e);
      }
    },
    verificationFailed: (FirebaseAuthException e) {
      print("Verification Failed: ${e.message}");
      if (!completer.isCompleted) completer.completeError(e);
    },
    codeSent: (String verId, int? resendToken) {
      verificationId = verId;
      print("OTP Sent to $formattedPhoneNumber");
      if (!completer.isCompleted) completer.complete();
    },
    codeAutoRetrievalTimeout: (String verId) {
      verificationId = verId;
      // Only completeError if it's a timeout and not already completed
      // by another callback
      if (!completer.isCompleted) {
        completer.completeError(
          FirebaseAuthException(
            code: "timeout",
            message: "OTP code retrieval timeout"
          )
        );
      }
    },
  );
  
  // Return the future from the completer
  
  return completer.future;
  
} 
