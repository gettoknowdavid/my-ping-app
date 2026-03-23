import 'package:flutter/foundation.dart';
import 'package:ping/ping.dart';

import 'injector.config.dart';

const mobileEnv = Environment('platform.mobile');
const webEnv = Environment('platform.web');

@InjectableInit(generateAccessors: true)
Future<void> _configInjector(
  String env, {
  EnvironmentFilter? envFilter,
}) async => di.init(environment: env, environmentFilter: envFilter);

Future<void> configureDependencies() async {
  if (kIsWeb) return _configInjector(webEnv.name);
  return _configInjector(mobileEnv.name);
}
