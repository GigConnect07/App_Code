import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      // User canceled the sign-in flow
      if (gUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      // Obtain auth details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error: $e");
      if (e is FirebaseAuthException) {
        print("FirebaseAuthException code: ${e.code}");
        print("FirebaseAuthException message: ${e.message}");
      }
      rethrow;
    }
  }

  /// Sign out (Google + Firebase)
  Future<void> signUserOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Optional: clean alias
  // Future<void> signOut() async {
  //   await signUserOut();
  // }
}
