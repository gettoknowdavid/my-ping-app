import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/chats/model/conversation_proxy.dart';
import 'package:ping/features/chats/widgets/_widgets.dart';

class ConversationTile extends WatchingWidget {
  const ConversationTile({required this.proxy, required this.onTap, super.key});

  final ConversationProxy proxy;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    watch(proxy);

    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: const .symmetric(horizontal: 12, vertical: 16),
        leading: ConversationAvatar(
          proxy.avatarUrl,
          displayName: proxy.displayName,
        ),
        title: Padding(
          padding: const .symmetric(horizontal: 8),
          child: Text(
            proxy.displayName,
            style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        rowMainAxisAlignment: .start,
        description: Padding(
          padding: const .symmetric(horizontal: 8),
          child: Text(
            proxy.lastMessagePreview,
            maxLines: 1,
            overflow: .ellipsis,
            style: theme.textTheme.muted,
          ),
        ),
        trailing: Text(
          proxy.formattedTime,
          style: theme.textTheme.muted.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
