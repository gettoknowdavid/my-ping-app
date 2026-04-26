//
// ignore_for_file: use_setters_to_change_properties

import 'dart:async';

import 'package:ping/_ping.dart';
import 'package:ping/features/chats/model/_model.dart';
import 'package:ping/features/chats/services/_services.dart';

class ChatManager implements Disposable {
  ChatManager({
    required MessageService messageService,
    required ConversationService conversationService,
    required String conversationId,
  }) : _messageService = messageService,
       _conversationService = conversationService,
       _conversationId = conversationId {
    _canLoadMore = hasReachedStart.combineLatest<String?, bool>(
      _oldestMessageId,
      (isAtTheStart, oldestId) => isAtTheStart || oldestId == null,
    );

    initializeCommand = .createAsyncNoParamNoResult(() async {
      _subscribeToRealtimeChannels();
      await _conversationService.markAllAsRead(_conversationId);
    }, errorFilter: const GlobalIfNoLocalErrorFilter());

    loadMoreMessagesCommand = .createAsyncNoParamNoResult(
      () async {
        final fetched = await _messageService.fetchMessages(
          conversationId,
          beforeId: _oldestMessageId.value,
        );

        if (fetched.isEmpty) {
          hasReachedStart.value = true;
          return;
        }

        messages.startTransAction();
        final reversed = fetched.reversed.toList();
        _oldestMessageId.value = reversed.first.id;
        messages.insertAll(0, reversed.map(MessageProxy.new));
        messages.endTransAction();

        hasReachedStart.value = fetched.length < 30;
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
      restriction: _canLoadMore.map((value) => !value),
    );

    sendTextCommand = .createAsyncNoResult<String>((content) async {
      clearReply();
      await _messageService.sendTextMessage(
        conversationId: _conversationId,
        content: content,
        replyToId: replyToMessage.value?.id,
      );
    }, errorFilter: const GlobalIfNoLocalErrorFilter());
  }

  final MessageService _messageService;
  final ConversationService _conversationService;
  final String _conversationId;

  final messages = ListNotifier<MessageProxy>(data: []);
  final replyToMessage = ValueNotifier<MessageProxy?>(null);
  final hasReachedStart = ValueNotifier<bool>(false);
  final _oldestMessageId = ValueNotifier<String?>(null);

  final newMessageSignal = ValueNotifier<int>(0);
  final updatedMessageSignal = ValueNotifier<int>(0);

  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _receiptsChannel;

  StreamSubscription<List<Message>>? _messagesSubscription;

  void _subscribeToRealtimeChannels() {
    _messagesSubscription = _messageService
        .watchMessages(_conversationId)
        .listen((incoming) {
          messages.startTransAction();
          messages.clear();
          messages.addAll(incoming.map(MessageProxy.new));
          messages.endTransAction();
        });

    // _messagesChannel = _messageService.subscribeToMessages(
    //   conversationId: _conversationId,
    //   onInsert: (incoming) async {
    //     final proxy = MessageProxy(incoming);
    //     messages.add(proxy);
    //     await _messageService.markRead(incoming.id);
    //     newMessageSignal.value++;
    //   },
    //   onUpdate: (incoming) {
    //     final proxy = MessageProxy(incoming);
    //     final index = messages.indexWhere((i) => i.id == proxy.id);
    //     if (index != -1) {
    //       messages[index] = proxy;
    //       updatedMessageSignal.value++;
    //     }
    //   },
    // );

    _receiptsChannel = _messageService.subscribeToReceipts(
      conversationId: _conversationId,
      onUpdate: (incoming) {},
    );
  }

  void setReply(MessageProxy proxy) => replyToMessage.value = proxy;

  void clearReply() => replyToMessage.value = null;

  late final Command<void, void> initializeCommand;
  late final Command<void, void> loadMoreMessagesCommand;
  late final Command<String, void> sendTextCommand;

  late final ValueListenable<bool> _canLoadMore;

  @override
  Future<dynamic> onDispose() async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;

    await _messagesChannel?.unsubscribe();
    await _receiptsChannel?.unsubscribe();

    _messagesChannel = null;
    _receiptsChannel = null;

    messages.dispose();
    replyToMessage.dispose();
    hasReachedStart.dispose();
    _oldestMessageId.dispose();
    newMessageSignal.dispose();
    updatedMessageSignal.dispose();

    initializeCommand.dispose();
    loadMoreMessagesCommand.dispose();
    sendTextCommand.dispose();
  }
}
