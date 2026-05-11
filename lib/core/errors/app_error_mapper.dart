import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract final class AppErrorMapper {
  static String? apiErrorFromBody(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final err = data['error'];
    if (err is Map<String, dynamic>) {
      return err['message']?.toString();
    }
    return null;
  }

  static String fromDio(DioException e, {String? operationFallback}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Secure connection could not be verified. Try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final api = apiErrorFromBody(e.response?.data);
        if (api != null && api.isNotEmpty) return api;
        if (status == 401 || status == 403) {
          return 'Access denied. Check your API key or permissions.';
        }
        if (status == 404) {
          return 'That post or resource was not found.';
        }
        if (status != null && status >= 500) {
          return 'The service is temporarily unavailable. Try again later.';
        }
        final m = e.message;
        if (m != null && m.isNotEmpty) return m;
        return operationFallback ?? 'Request failed. Please try again.';
      case DioExceptionType.unknown:
        final inner = e.error;
        if (inner is FormatException) {
          return 'Received invalid data from the server.';
        }
        final m = e.message;
        if (m != null && m.isNotEmpty) return m;
        return operationFallback ?? 'Something went wrong. Please try again.';
    }
  }

  static String fromUnknown(
    Object error,
    StackTrace stackTrace, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    assert(() {
      debugPrint('AppErrorMapper.fromUnknown: $error\n$stackTrace');
      return true;
    }());
    if (error is DioException) {
      return fromDio(error, operationFallback: fallback);
    }
    return fallback;
  }

  static String fromFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak. Use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return e.message?.trim().isNotEmpty == true
            ? e.message!.trim()
            : 'Authentication failed.';
    }
  }
}
