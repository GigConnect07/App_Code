class ErrorHandler {
  static void showAuthError(String code) {
    String message = switch(code) {
      'weak-password' => 'Password too weak!',
      'email-already-in-use' => 'Email already registered',
      _ => 'Registration failed',
    };
    // Show dialog/snackbar
  }
}