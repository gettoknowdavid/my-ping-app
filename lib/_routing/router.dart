import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shell/app_shell.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';
import 'package:ping/features/auth/model/auth_status.dart';
import 'package:ping/features/auth/pages/_pages.dart';
import 'package:ping/features/calls/pages/calls_page.dart';
import 'package:ping/features/chats/pages/chats_page.dart';
import 'package:ping/features/communities/pages/communities_page.dart';
import 'package:ping/features/contacts/contacts.dart';
import 'package:ping/features/updates/pages/updates_page.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class PingRouter {
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
      initialLocation: const ChatsRoute().location,
      routes: $appRoutes,
      refreshListenable: auth.status,
      redirect: (context, state) {
        final status = auth.status.value;
        final isAuthRoute = state.matchedLocation.startsWith('/auth');
        return switch (status) {
          Unauthenticated() => const PhoneEntryRoute().location,
          AwaitingOtp() => const PhoneVerificationRoute().location,
          Onboarding() => const AccountOnboardingRoute().location,
          Authenticated() => isAuthRoute ? const ChatsRoute().location : null,
        };
      },
    );
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

@TypedGoRoute<ContactSearchRoute>(path: '/contacts/search')
class ContactSearchRoute extends GoRouteData with $ContactSearchRoute {
  const ContactSearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContactSearchPage();
  }
}

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<ChatsBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChatsRoute>(path: '/chats'),
      ],
    ),
    TypedStatefulShellBranch<UpdatesBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<UpdatesRoute>(path: '/updates'),
      ],
    ),
    TypedStatefulShellBranch<CommunitiesBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<CommunitiesRoute>(path: '/communities'),
      ],
    ),
    TypedStatefulShellBranch<CallsBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<CallsRoute>(path: '/calls'),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = appNavigatorKey;

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);

  static const String $restorationScopeId = 'appRestorationScopeId';
}

class ChatsBranch extends StatefulShellBranchData {
  const ChatsBranch();
}

class ChatsRoute extends GoRouteData with $ChatsRoute {
  const ChatsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChatsPage();
  }
}

class UpdatesBranch extends StatefulShellBranchData {
  const UpdatesBranch();
}

class UpdatesRoute extends GoRouteData with $UpdatesRoute {
  const UpdatesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UpdatesPage();
  }
}

class CommunitiesBranch extends StatefulShellBranchData {
  const CommunitiesBranch();
}

class CommunitiesRoute extends GoRouteData with $CommunitiesRoute {
  const CommunitiesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CommunitiesPage();
  }
}

class CallsBranch extends StatefulShellBranchData {
  const CallsBranch();
}

class CallsRoute extends GoRouteData with $CallsRoute {
  const CallsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CallsPage();
  }
}
