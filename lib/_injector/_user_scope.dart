import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/profile.dart';
import 'package:ping/features/contacts/manager/_manager.dart';
import 'package:ping/features/contacts/services/_services.dart';
import 'package:ping/features/profile/services/_services.dart';

abstract class UserScope {
  static const String name = 'user';

  static Future<void> pushScope(Profile profile) async {
    if (di.hasScope(name)) await di.popScope();

    di.pushNewScope(
      scopeName: name,
      init: (scope) {
        scope.registerSingleton<Profile>(profile);
        scope.registerLazySingleton<ContactsService>(() {
          return ContactsService(di<DatabaseService>());
        });
        scope.registerLazySingleton<ContactsManager>(() {
          return ContactsManager(di<ContactsService>());
        });
        scope.registerLazySingleton<ProfileService>(() {
          return ProfileService(
            db: di<DatabaseService>(),
            userId: profile.id,
          );
        });
      },
    );
  }

  static Future<void> popScope() async {
    if (!di.hasScope(name)) return;
    await di.popScopesTill('root', inclusive: false);
  }
}
