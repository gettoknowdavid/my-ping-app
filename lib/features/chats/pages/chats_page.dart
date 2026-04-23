import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/chats/manager/_manager.dart';
import 'package:ping/features/chats/model/_model.dart';
import 'package:ping/features/chats/widgets/_widgets.dart';

class ChatsPage extends WatchingWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final appBar = AppBar(
      title: Text('Ping', style: theme.textTheme.h2),
      actions: [
        ShadIconButton.ghost(
          icon: const Icon(LucideIcons.ellipsisVertical),
          onPressed: () => const SettingsRoute().push<void>(context),
        ),
      ],
    );

    final snapshot = watchFuture<GetIt, void>(
      (getIt) => getIt.allReady(timeout: const Duration(seconds: 30)),
      target: di,
      initialValue: null,
    );

    if (snapshot.hasError) {
      final error = snapshot.error;
      return Scaffold(
        appBar: appBar,
        body: Center(child: ShadCard(title: Text(error.toString()))),
      );
    }

    if (snapshot.connectionState != ConnectionState.done) {
      return Scaffold(appBar: appBar, body: const LoadingIndicator(size: 24));
    }

    return Scaffold(
      appBar: appBar,
      body: const ChatsPageView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => const ContactSearchRoute().push<void>(context),
        child: const Icon(LucideIcons.messageCirclePlus),
      ),
    );
  }
}

class ChatsPageView extends WatchingWidget {
  const ChatsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = watchValue<ConversationsManager, List<ConversationProxy>>(
      (manager) => manager.conversations,
    );

    final isLoading = watchValue<ConversationsManager, bool>(
      (manager) => manager.isLoading,
    );

    return CustomScrollView(
      slivers: [
        if (isLoading && items.isEmpty) ...[
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: LoadingIndicator()),
          ),
        ] else ...[
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverFillRemaining(
            child: Padding(
              padding: const .symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final proxy = items[index];
                  return ConversationTile(
                    proxy: proxy,
                    onTap: () => MessageThreadRoute(proxy.id).pushReplacement(
                      context,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final fakeConversation = ConversationListItemModel(
  id: 'id',
  type: .direct,
  createdAt: DateTime.now(),
  lastMessageAt: DateTime.now(),
  lastMessageId: 'lastMessageId',
  lastMessageSenderId: 'lastMessageSenderId',
  lastMessageType: .text,
  lastMessageContent:
      '''Everything is awesome; everything is cool when you are part of a team; everything is awesome!''',
);

final fakeProxy = ConversationProxy(target: fakeConversation);
