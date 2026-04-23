import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/chats/model/message_proxy.dart';

class MessageBubble extends WatchingWidget {
  const MessageBubble({required this.proxy, super.key});

  final MessageProxy proxy;

  @override
  Widget build(BuildContext context) {
    watch(proxy);

    final isMine = proxy.isMine;
    final theme = ShadTheme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final replyTarget = proxy.replyTarget;

    return Align(
      alignment: isMine ? .centerRight : .centerLeft,
      child: Container(
        margin: const .symmetric(horizontal: 8, vertical: 2),
        padding: const .symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? colors.primary : colors.muted,
          borderRadius: .only(
            topLeft: const .circular(12),
            topRight: const .circular(12),
            bottomLeft: .circular(isMine ? 12 : 2),
            bottomRight: .circular(isMine ? 2 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: .end,
          mainAxisSize: .min,
          children: [
            if (replyTarget != null) _ReplyQuote(target: replyTarget),
            Text(
              proxy.displayText,
              style: textTheme.p.copyWith(
                color: isMine ? colors.primaryForeground : colors.foreground,
                fontStyle: proxy.isDeleted ? .italic : .normal,
              ),
            ),
            Text(
              proxy.formattedTime,
              style: textTheme.muted.copyWith(
                fontSize: 10,
                color: isMine
                    ? colors.primaryForeground.withValues(alpha: 0.7)
                    : colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({required this.target});

  final MessageProxy target;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .only(bottom: 4),
      padding: const .all(6),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: .circular(6),
        border: const Border(left: BorderSide(color: Colors.white54, width: 2)),
      ),
      child: Text(
        target.displayText,
        maxLines: 2,
        overflow: .ellipsis,
        style: ShadTheme.of(context).textTheme.p,
      ),
    );
  }
}
