import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/services/send_OTP.dart'; // To access verificationId

Future<UserCredential> verifyOTP(String otp) async {
  if (verificationId.isEmpty) {
    throw FirebaseAuthException(
      code: "invalid-verification-id",
      message: "Invalid verification ID. Please request a new OTP."
    );
  }
  
  if (otp.length != 6) {
    throw FirebaseAuthException(
      code: "invalid-otp-format", 
      message: "OTP must be 6 digits."
    );
  }

  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    print("OTP Verified & Logged In: ${userCredential.user?.uid}");
    return userCredential;
  } catch (e) {
    print("Invalid OTP: $e");
    throw e; // Re-throw to handle in UI
  }
}