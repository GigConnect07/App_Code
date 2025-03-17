import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
String verificationId = ""; // Verify karne ke liye use hoga

void sendOTP(String phoneNumber) async {
  String formattedPhoneNumber = "+91$phoneNumber"; // Country code hardcoded

  await auth.verifyPhoneNumber(
    phoneNumber: formattedPhoneNumber,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
      await auth.signInWithCredential(credential);
      print("Automatically Verified & Logged In");
    },
    verificationFailed: (FirebaseAuthException e) {
      print("Verification Failed: ${e.message}");
    },
    codeSent: (String verId, int? resendToken) {
      verificationId = verId;
      print("OTP Sent to $formattedPhoneNumber");
    },
    codeAutoRetrievalTimeout: (String verId) {
      verificationId = verId;
    },
  );
}

