import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:ping/features/chats/model/_model.dart';
import 'package:ping/features/profile/model/local_profile.dart';
import 'package:ping/objectbox.g.dart';

class LocalService implements Disposable {
  LocalService._create(this.store) {
    conversations = Box<LocalConversation>(store);
    messages = Box<LocalMessage>(store);
    profiles = Box<LocalProfile>(store);
  }

  late final Store store;

  late final Box<LocalConversation> conversations;
  late final Box<LocalMessage> messages;
  late final Box<LocalProfile> profiles;

  static Future<LocalService> create() async {
    final store = await openStore();
    return LocalService._create(store);
  }

  Stream<List<LocalMessage>> watchMessages(String conversationId) {
    return messages
        .query(LocalMessage_.conversationId.equals(conversationId))
        .order(LocalMessage_.createdAt)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Stream<List<LocalConversation>> watchConversations() {
    return conversations
        .query()
        .order(LocalConversation_.lastMessageAt, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  void dispose() => store.close();

  @override
  FutureOr<dynamic> onDispose() {
    dispose();
  }
}
