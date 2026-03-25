import 'dart:io' show File;

class NewProfileParams {
  const NewProfileParams({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
  });

  final String userId;
  final String username;
  final String? displayName;
  final File? avatar;
}

class VerifyOtpParams {
  const VerifyOtpParams({required this.phone, required this.otp});

  final String phone;
  final String otp;
}
