import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/chats/manager/_manager.dart';
import 'package:ping/features/chats/model/message_proxy.dart';

class MessageOptionsModal extends WatchingWidget {
  const MessageOptionsModal._(this.proxy) : super(key: null);

  final MessageProxy proxy;

  static Future<void> show(BuildContext context, MessageProxy proxy) =>
      showShadSheet<void>(
        context: context,
        useRootNavigator: true,
        side: ShadSheetSide.bottom,
        builder: (_) => MessageOptionsModal._(proxy),
      );

  @override
  Widget build(BuildContext context) {
    final manager = di<ChatManager>();
    final colors = ShadTheme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const .fromLTRB(16, 0, 16, 16),
        child: ShadSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!proxy.isDeleted) ...[
                ListTile(
                  leading: const Icon(LucideIcons.reply),
                  title: const Text('Reply'),
                  onTap: () {
                    context.pop(context);
                    manager.setReply(proxy);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.copy),
                  title: const Text('Copy'),
                  onTap: () async {
                    context.pop(context);
                    await Clipboard.setData(
                      ClipboardData(text: proxy.content ?? ''),
                    );
                  },
                ),
              ],
              if (proxy.isMine && !proxy.isDeleted)
                ListTile(
                  leading: Icon(
                    LucideIcons.trash,
                    color: colors.destructive,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(color: colors.destructive),
                  ),
                  onTap: () {
                    context.pop(context);
                    proxy.deleteCommand.run();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
