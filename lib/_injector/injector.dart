import 'package:flutter/foundation.dart';
import 'package:ping/_injector/injector.config.dart';
import 'package:ping/_ping.dart';

const mobile = Environment('mobile');
const web = Environment('web');

@InjectableInit(generateAccessors: true)
Future<GetIt> _configInjector(String environment) async {
  const buildEnv = kDebugMode ? Environment.dev : Environment.prod;
  return di.init(
    environment: environment,
    environmentFilter: NoEnvOrContainsAny({environment, buildEnv}),
  );
}

Future<GetIt> configureDependencies() async {
  if (kIsWeb) return _configInjector(web.name);
  return _configInjector(mobile.name);
}
