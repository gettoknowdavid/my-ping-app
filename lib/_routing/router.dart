import 'package:flutter/material.dart';
import 'package:ping/_injector/injector.dart';
import 'package:ping/_ping.dart';

part 'router.g.dart';

@mobile
@lazySingleton
class PingRouter {
  @factoryMethod
  factory PingRouter.create() {
    assert(_instance == null, 'PingRouter cannot be created more than once');
    return _instance = PingRouter._();
  }

  PingRouter._() : config = _buildConfig();

  final GoRouter config;

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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
