import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';
import 'package:ping/features/auth/model/auth_status.dart';
import 'package:ping/features/auth/pages/_pages.dart';

part 'router.g.dart';

@Singleton(order: 99)
class PingRouter {
  @factoryMethod
  factory PingRouter.create(AuthManager auth) {
    assert(_instance == null, 'PingRouter cannot be created more than once');
    return _instance = PingRouter._(auth);
  }

  PingRouter._(AuthManager auth) : config = _buildConfig(auth);

  final GoRouter config;

  static PingRouter? _instance;

  static PingRouter get instance {
    assert(_instance != null, 'PingRouter cannot be accessed before creation');
    return _instance!;
  }

  static GoRouter _buildConfig(AuthManager auth) {
    return GoRouter(
      routes: $appRoutes,
      refreshListenable: auth.status,
      redirect: (context, state) {
        final status = auth.status.value;
        final isAuthRoute = state.matchedLocation.startsWith('/auth');
        return switch (status) {
          Unauthenticated() => const PhoneEntryRoute().location,
          AwaitingOtp() => const PhoneVerificationRoute().location,
          Onboarding() => const AccountOnboardingRoute().location,
          Authenticated() => isAuthRoute ? '/' : null,
        };
      },
    );
  }
}

@TypedGoRoute<RootRoute>(path: '/')
class RootRoute extends GoRouteData with $RootRoute {
  const RootRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

@TypedGoRoute<PhoneEntryRoute>(path: '/auth/phone')
class PhoneEntryRoute extends GoRouteData with $PhoneEntryRoute {
  const PhoneEntryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PhoneEntryPage();
  }
}

@TypedGoRoute<PhoneVerificationRoute>(path: '/auth/phone/verify')
class PhoneVerificationRoute extends GoRouteData with $PhoneVerificationRoute {
  const PhoneVerificationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PhoneVerificationPage();
  }
}

@TypedGoRoute<AccountOnboardingRoute>(path: '/auth/onboarding')
class AccountOnboardingRoute extends GoRouteData with $AccountOnboardingRoute {
  const AccountOnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AccountOnboardingPage();
  }
}
