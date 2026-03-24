import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/profile.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.awaitingOtp(String phone) = _AwaitingOtp;

  const factory AuthState.onboarding(String userId) = _Onboarding;

  const factory AuthState.authenticated(Profile profile) = _Authenticated;
}
