import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_connect/services/send_OTP.dart';

void verifyOTP(String otp) async {
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    print("OTP Verified & Logged In: ${userCredential.user?.uid}");
  } catch (e) {
    print("Invalid OTP: $e");
  }
}
