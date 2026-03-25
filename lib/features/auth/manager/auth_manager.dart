import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ping/_injector/_user_scope.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/managers/toast_manager.dart';
import 'package:ping/features/auth/model/_model.dart';
import 'package:ping/features/auth/services/_services.dart';

@Singleton(dependsOn: [AuthService])
class AuthManager extends ChangeNotifier implements Disposable {
  AuthManager({
    required AuthService service,
    required ToastManager toast,
  }) : _service = service,
       _toast = toast;

  final AuthService _service;
  final ToastManager _toast;

  final _status = ValueNotifier<AuthStatus>(const .unauthenticated());

  ValueListenable<AuthStatus> get status => _status;

  StreamSubscription<AuthStatus>? _subscription;

  @PostConstruct(preResolve: true)
  Future<void> initialize() async {
    // Listen to the changes on the auth state from Supabase
    _subscription = _service.authStatusChanges.listen((incoming) async {
      final current = _status.value;

      // Pop user scope before pushing a new one to avoid scope leaks
      if (current is Authenticated && incoming is! Authenticated) {
        await UserScope.popScope();
      }

      if (incoming is Authenticated && current is! Authenticated) {
        UserScope.pushScope(incoming.profile);
      }

      _status.value = incoming;
    });

    // Listen to errors
    sendOtp.errors.listen((error, _) {
      final message = error?.error.toString() ?? 'Error sending OTP';
      _toast.error(message);
    });
    verifyOtp.errors.listen((error, _) {
      final message = error?.error.toString() ?? 'Error verifying OTP';
      _toast.error(message);
    });
    completeOnboarding.errors.listen((error, _) {
      final msg = error?.error.toString() ?? 'Failed to complete onboarding';
      _toast.error(msg);
    });

    // Initialize commands
    sendOtp = Command.createAsyncNoResult<String>(
      (phone) async {
        await _service.sendOtp(phone);
        _status.value = .awaitingOtp(phone);
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    verifyOtp = Command.createSyncNoResult<VerifyOtpParams>(
      (params) async {
        final session = await _service.verifyOtp(params);
        final profile = await _service.fetchProfile(session.user.id);
        if (profile?.username != null) {
          UserScope.pushScope(profile!);
          _status.value = .authenticated(profile);
        } else {
          _status.value = .onboarding(session.user.id);
        }
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    completeOnboarding = Command.createSyncNoResult<NewProfileParams>(
      (params) async {
        final profile = await _service.createProfile(params);
        UserScope.pushScope(profile);
        _status.value = .authenticated(profile);
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    signOut = Command.createAsyncNoParamNoResult(
      () async {
        await _service.signOut();
        await UserScope.popScope();
        _status.value = const .unauthenticated();
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );

    // Handle initial check before `authStatusChanges` stream is fired
    final session = _service.currentSession;
    if (session != null) {
      final profile = await _service.fetchProfile(session.user.id);
      if (profile?.username != null) {
        UserScope.pushScope(profile!);
        _status.value = .authenticated(profile);
      } else {
        _status.value = .onboarding(session.user.id);
      }
    }
  }

  // Sends OTP — transitions to awaitingOtp so the router
  // navigates to the OTP screen automatically via refreshListenable.
  late final Command<String, void> sendOtp;

  // Verifies OTP — on success, determines onboarding vs authenticated.
  // Router reacts automatically — no manual navigation needed here.
  late final Command<VerifyOtpParams, void> verifyOtp;

  // Completes onboarding — creates profile row, optionally uploads avatar,
  // then transitions to authenticated and pushes user scope.
  late final Command<NewProfileParams, void> completeOnboarding;

  // Signs out — pops user scope (disposes all user-scope services),
  // resets status. Router reacts automatically.
  late final Command<void, void> signOut;

  @override
  FutureOr<dynamic> onDispose() async {
    await _subscription?.cancel();
    _subscription = null;

    _status.dispose();

    sendOtp.dispose();
    verifyOtp.dispose();
    completeOnboarding.dispose();
    signOut.dispose();

    super.dispose();
  }
}
