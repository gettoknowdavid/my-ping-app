import 'dart:async';

import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/profile.dart';
import 'package:ping/features/chats/model/_model.dart';
import 'package:ping/features/chats/services/_services.dart';

class ConversationsManager implements Disposable {
  ConversationsManager({
    required ConversationService service,
    required RemoteService db,
  }) : _service = service,
       _db = db;

  final ConversationService _service;
  final RemoteService _db;

  final conversations = ListNotifier<ConversationProxy>(data: []);
  final isLoading = ValueNotifier<bool>(false);

  RealtimeChannel? _channel;

  Future<void> initialize() async {
    refresh = Command.createAsyncNoParamNoResult(
      _fetchConversations,
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );

    _subscribeToUpdates();
    await _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    isLoading.value = true;
    try {
      final targets = await _service.fetchConversationListItems();

      // Build proxies — for one-on-one, fetch the other member's profile
      conversations.startTransAction();
      for (final target in targets) {
        Profile? otherProfile;
        if (!target.isGroup) {
          otherProfile = await _service.fetchOtherMemberProfile(
            target.id,
            _db.client.auth.currentUser!.id,
          );
        }
        conversations.add(
          ConversationProxy(target: target, otherProfile: otherProfile),
        );
      }
      conversations.endTransAction();
    } catch (e) {
      throw PingException(e.toString());
    } finally {
      isLoading.value = false;
      GetIt.instance.signalReady(this);
    }
  }

  void _subscribeToUpdates() {
    _channel = _service.subscribeToConversations(
      onUpdate: (incoming) async {
        final index = conversations.indexWhere((e) => e.id == incoming.id);
        if (index != -1) await _refreshConversation(incoming.id);
      },
    );
  }

  Future<void> _refreshConversation(String conversationId) async {
    final target = await _service.fetchConversationListItem(conversationId);
    if (target == null) return;

    final index = conversations.indexWhere((e) => e.id == conversationId);
    if (index != -1) {
      conversations[index].target = target;
      conversations.sort(
        (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
          a.lastMessageAt ?? DateTime(0),
        ),
      );
    }
  }

  late final Command<void, void> refresh;

  @override
  Future<dynamic> onDispose() async {
    await _channel?.unsubscribe();
    _channel = null;

    conversations.dispose();
    isLoading.dispose();
    refresh.dispose();
  }
}
