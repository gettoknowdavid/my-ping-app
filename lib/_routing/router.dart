import 'package:flutter/material.dart';
import 'package:ping/ping.dart';

part 'router.g.dart';

@lazySingleton
class PingRouter {
  PingRouter._() : config = _buildConfig();

  final GoRouter config;

  @factoryMethod
  factory PingRouter.create() {
    assert(_instance == null, 'PingRouter cannot be created more than once');
    return _instance = PingRouter._();
  }

  static PingRouter? _instance;

  static PingRouter get instance {
    assert(_instance != null, 'PingRouter cannot be accessed before creation');
    return _instance!;
  }

  static GoRouter _buildConfig() {
    return GoRouter(routes: $appRoutes);
  }
}

@TypedGoRoute<RootRoute>(path: '/')
class RootRoute extends GoRouteData with $RootRoute {
  const RootRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
