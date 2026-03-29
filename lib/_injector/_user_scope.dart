import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/profile.dart';
import 'package:ping/features/contacts/services/contacts_service.dart';

abstract class UserScope {
  static const String name = 'user';

  static void pushScope(Profile profile) {
    di.pushNewScope(
      scopeName: name,
      init: (scope) {
        scope.registerSingleton<Profile>(profile);
        scope.registerLazySingleton<ContactsService>(() {
          return ContactsService(di<DatabaseService>());
        });
      },
    );
  }

  static Future<void> popScope() async {
    if (!di.hasScope(name)) return;
    await di.popScopesTill('root', inclusive: false);
  }
}
