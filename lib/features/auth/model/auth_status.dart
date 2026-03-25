import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/profile.dart';

part 'auth_status.freezed.dart';

@freezed
sealed class AuthStatus with _$AuthStatus {
  const factory AuthStatus.unauthenticated() = Unauthenticated;

  const factory AuthStatus.awaitingOtp(String phone) = AwaitingOtp;

  const factory AuthStatus.onboarding(String userId) = Onboarding;

  const factory AuthStatus.authenticated(Profile profile) = Authenticated;
}
