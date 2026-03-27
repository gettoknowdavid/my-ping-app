import 'dart:io' show File;

class NewProfileArgs {
  const NewProfileArgs({
    required this.userId,
    required this.displayName,
    this.avatar,
  });

  final String userId;
  final String displayName;
  final File? avatar;
}

class VerifyOtpArgs {
  const VerifyOtpArgs({required this.phone, required this.otp});

  final String phone;
  final String otp;
}
