import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/profile.dart';

abstract class UserScope {
  static const String name = 'user';

  static void pushScope(Profile profile) {
    di.pushNewScope(
      scopeName: name,
      init: (scope) {
        // Register the runtime object injectable cannot generate
        scope.registerSingleton<Profile>(profile);
      },
    );
  }

  static Future<void> popScope() async {
    if (!di.hasScope(name)) return;
    await di.popScopesTill('root', inclusive: false);
  }
}
