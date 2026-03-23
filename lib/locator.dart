import 'package:flutter_it/flutter_it.dart';
import 'package:ping/_routing/_routing.dart';

void configureDependencies() {
  di.pushNewScope(scopeName: 'root');
  di.registerLazySingleton(() => PingRouter.create());
}
