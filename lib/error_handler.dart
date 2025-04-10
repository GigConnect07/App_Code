import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ErrorHandler {
  static void handle(BuildContext context, dynamic error, {String? customMessage}) {
    final message = _getErrorMessage(error, customMessage);
    _showErrorSnackbar(context, message);
    _logError(error);
  }

  static String _getErrorMessage(dynamic error, String? customMessage) {
    if (customMessage != null) return customMessage;

    if (error is FirebaseAuthException) {
      return _firebaseAuthError(error);
    } else if (error is FirebaseException) {
      return 'Database Error: ${error.message ?? 'Unknown Firestore error'}';
    } else if (error is http.Response) {
      return _handleHttpError(error);
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is FormatException) {
      return 'Data format error. Please try again.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static String _firebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  static String _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Network error (${response.statusCode}). Please try again.';
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void _logError(dynamic error) {
    debugPrint('Error occurred: ${error.toString()}');
    if (error is Error) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
  }
}