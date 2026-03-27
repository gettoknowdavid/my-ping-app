import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ping/_injector/_user_scope.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/_model.dart';
import 'package:ping/features/auth/services/auth_service.dart';

@singleton
class AuthManager extends ChangeNotifier implements Disposable {
  AuthManager({
    required AuthService service,
    required ToastManager toast,
  }) : _service = service,
       _toast = toast;

  final AuthService _service;
  final ToastManager _toast;

  final phoneNumber = ValueNotifier<String?>(null);
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

    // Initialize commands
    submitPhoneNumber = .createAsyncNoResult<String>(
      (phone) async {
        await _service.sendOtp(phone);
        phoneNumber.value = phone;
        _status.value = .awaitingOtp(phone);
      },
      errorFilter: const LocalErrorFilter(),
    );
    verifyPhoneNumber = .createAsyncNoResult<VerifyOtpArgs>(
      (params) async {
        final session = await _service.verifyOtp(params);
        final profile = await _service.fetchProfile(session.user.id);
        if (profile?.displayName != null) {
          UserScope.pushScope(profile!);
          _status.value = .authenticated(profile);
        } else {
          _status.value = .onboarding(session.user.id);
        }
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    completeOnboarding = .createAsyncNoResult<NewProfileArgs>(
      (params) async {
        final profile = await _service.createProfile(params);
        UserScope.pushScope(profile);
        _status.value = .authenticated(profile);
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    signOut = .createAsyncNoParamNoResult(
      () async {
        await _service.signOut();
        await UserScope.popScope();
        _status.value = const .unauthenticated();
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );

    // Listen to errors
    submitPhoneNumber.errors.listen((errors, _) {
      final message = errors?.error.message;
      _toast.error('Authentication Error', description: message);
    });
    verifyPhoneNumber.errors.listen((errors, _) {
      final message = errors?.error.message;
      _toast.error('Authentication Error', description: message);
    });
    completeOnboarding.errors.listen((errors, _) {
      final message = errors?.error.message;
      _toast.error('Authentication Error', description: message);
    });

    // Handle initial check before `authStatusChanges` stream is fired
    final session = _service.currentSession;
    if (session != null) {
      final profile = await _service.fetchProfile(session.user.id);
      if (profile?.displayName != null) {
        UserScope.pushScope(profile!);
        _status.value = .authenticated(profile);
      } else {
        _status.value = .onboarding(session.user.id);
      }
    }
  }

  // Sends OTP — transitions to awaitingOtp so the router
  // navigates to the OTP screen automatically via refreshListenable.
  late final Command<String, void> submitPhoneNumber;

  // Verifies OTP — on success, determines onboarding vs authenticated.
  // Router reacts automatically — no manual navigation needed here.
  late final Command<VerifyOtpArgs, void> verifyPhoneNumber;

  // Completes onboarding — creates profile row, optionally uploads avatar,
  // then transitions to authenticated and pushes user scope.
  late final Command<NewProfileArgs, void> completeOnboarding;

  // Signs out — pops user scope (disposes all user-scope services),
  // resets status. Router reacts automatically.
  late final Command<void, void> signOut;

  @override
  FutureOr<dynamic> onDispose() async {
    await _subscription?.cancel();
    _subscription = null;

    phoneNumber.dispose();
    _status.dispose();

    submitPhoneNumber.dispose();
    verifyPhoneNumber.dispose();
    completeOnboarding.dispose();
    signOut.dispose();

    super.dispose();
  }
}
