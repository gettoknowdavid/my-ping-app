import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/widgets/loading_indicator.dart';
import 'package:ping/features/chats/manager/_manager.dart';
import 'package:ping/features/chats/model/message_proxy.dart';
import 'package:ping/features/chats/services/_services.dart';
import 'package:ping/features/chats/widgets/_widgets.dart';

class MessageThreadPage extends WatchingWidget {
  const MessageThreadPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    pushScope(
      init: (getIt) {
        getIt.registerLazySingleton<ChatManager>(
          () => ChatManager(
            conversationId: conversationId,
            messageService: di<MessageService>(),
            conversationService: di<ConversationService>(),
          ),
          onCreated: (manager) => manager.initializeCommand.run(),
        );
      },
    );

    return _MessageThreadView(conversationId);
  }
}

class _MessageThreadView extends WatchingWidget {
  const _MessageThreadView(this.conversationId);

  final String conversationId;

  @override
  Widget build(BuildContext ctx) {
    final scrollController = createOnce(ScrollController.new);

    // React to new messages — scroll to bottom as a side effect
    // No rebuild triggered — registerHandler is fire-and-forget
    registerHandler(
      target: di<ChatManager>().newMessageSignal,
      handler: (context, _, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (scrollController.hasClients) {
            await scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );

    callOnce((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: _ConversationHeader(conversationId)),
      body: Column(
        children: [
          Expanded(child: _MessageListView(controller: scrollController)),
          const MessageInputBar(),
        ],
      ),
    );
  }
}

class _MessageListView extends WatchingWidget {
  const _MessageListView({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final isLoading = watchValue<ChatManager, bool>(
      (manager) => manager.initializeCommand.isRunning,
    );

    final isLoadingMore = watchValue<ChatManager, bool>(
      (manager) => manager.loadMoreMessagesCommand.isRunning,
    );

    final messages = watchValue<ChatManager, List<MessageProxy>>(
      (manager) => manager.messages,
    );

    if (isLoading) return const LoadingIndicator();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            controller.position.pixels == 0) {
          di<ChatManager>().loadMoreMessagesCommand.run();
        }
        return false;
      },
      child: ListView.builder(
        controller: controller,
        itemCount: messages.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (isLoadingMore && index == 0) return const LoadingIndicator();
          final messageIndex = isLoadingMore ? index - 1 : index;
          final proxy = messages[messageIndex];
          return GestureDetector(
            onLongPress: () => MessageOptionsModal.show(context, proxy),
            child: MessageBubble(proxy: proxy),
          );
        },
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader(this.conversationId);

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    final manager = di<ConversationsManager>();
    final proxy = manager.conversations.value.firstWhere(
      (p) => p.id == conversationId,
      orElse: () => throw StateError('Conversation not found'),
    );

    final placeholder = proxy.displayName[0].toUpperCase();
    final textTheme = ShadTheme.of(context).textTheme;

    return Row(
      children: [
        ShadAvatar(
          proxy.avatarUrl,
          placeholder: Text(placeholder, style: textTheme.muted),
        ),
        const SizedBox(width: 8),
        Text(proxy.displayName, style: textTheme.p),
      ],
    );
  }
}
