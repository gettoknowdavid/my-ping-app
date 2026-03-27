import 'package:ping/_ping.dart';

part 'ping_exception.freezed.dart';

@freezed
sealed class PingException with _$PingException implements Exception {
  const factory PingException(String message) = _PingException;

  const factory PingException.auth(Object error) = _PingAuthException;

  const PingException._();

  /// Call this wherever you need to display the error.
  String get message => switch (this) {
    _PingException(:final message) => message,
    _PingAuthException(:final error) => _mapAuth(error),
  };

  static String _mapAuth(Object error) {
    if (error is AuthApiException) return _mapApiException(error);
    if (error is AuthException) return _mapAuthException(error);
    if (error is StorageException) return 'Could not upload file. Try again.';
    return 'Something went wrong. Please try again.';
  }

  static String _mapApiException(AuthApiException e) {
    return switch (e.code) {
      'validation_failed' => 'Please enter a valid phone number.',
      'otp_expired' => 'Your code has expired. Request a new one.',
      'otp_disabled' => 'OTP sign-in is not enabled.',
      'invalid_credentials' => 'Incorrect code. Please try again.',
      'too_many_requests' => 'Too many attempts. Wait a moment and try again.',
      'sms_send_failed' => 'Could not send SMS. Check your number & try again.',
      'phone_exists' => 'This number is already registered.',
      'phone_not_confirmed' => 'Your phone number has not been verified.',
      'session_not_found' => 'Your session has expired. Please sign in again.',
      'user_not_found' => 'Account not found.',
      'user_banned' => 'This account has been suspended.',
      'over_request_rate_limit' => 'Too many requests. Please wait.',
      _ => 'Authentication failed. Please try again.',
    };
  }

  static String _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('network')) return 'No internet connection.';
    if (msg.contains('timeout')) return 'Request timed out. Try again.';
    return 'Authentication error. Please try again.';
  }
}

extension PingExceptionX on Object? {
  String get message {
    if (this == null) return 'Something went wrong';
    if (this is PingException) return (this! as PingException).message;
    return 'Unknown error';
  }
}
