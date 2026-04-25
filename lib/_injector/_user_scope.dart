import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/profile.dart';
import 'package:ping/features/chats/manager/_manager.dart';
import 'package:ping/features/chats/services/_services.dart';
import 'package:ping/features/contacts/manager/_manager.dart';
import 'package:ping/features/contacts/services/_services.dart';
import 'package:ping/features/profile/manager/_manager.dart';
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
          return ContactsService(di<RemoteService>());
        });
        scope.registerSingletonWithDependencies<ProfileService>(() {
          return ProfileService(db: di<RemoteService>(), userId: profile.id);
        }, dependsOn: [RemoteService]);
        scope.registerSingletonAsync<ConversationService>(() async {
          return ConversationService(di<RemoteService>());
        });
        scope.registerSingletonAsync<MessageService>(() async {
          return MessageService(di<RemoteService>());
        });

        scope.registerSingletonAsync<ProfileManager>(() async {
          return ProfileManager(profile: profile, toast: di<ToastManager>());
        }, onCreated: (manager) => manager.initialize());
        scope.registerLazySingleton<ContactsManager>(() {
          return ContactsManager(
            service: di<ContactsService>(),
            conversationService: di<ConversationService>(),
          );
        });
        scope.registerSingletonAsync<ConversationsManager>(
          () async => ConversationsManager(
            service: di<ConversationService>(),
            db: di<RemoteService>(),
          ),
          onCreated: (manager) async => manager.initialize(),
          dependsOn: [ConversationService, RemoteService],
          signalsReady: true,
        );
      },
    );
  }

  static Future<void> popScope() async {
    if (!di.hasScope(name)) return;
    await di.popScopesTill('root', inclusive: false);
  }
}
