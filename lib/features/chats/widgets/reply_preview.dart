import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/chats/model/message_proxy.dart';

class ReplyPreview extends StatelessWidget {
  const ReplyPreview(this.proxy, {required this.onCancel, super.key});

  final MessageProxy proxy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  proxy.isMine ? 'You' : proxy.senderId,
                  style: theme.textTheme.p.copyWith(fontWeight: .w600),
                ),
                Text(
                  proxy.displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.p,
                ),
              ],
            ),
          ),
          ShadIconButton(
            icon: const Icon(LucideIcons.x, size: 16),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
