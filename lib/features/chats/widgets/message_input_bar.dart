import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/chats/manager/_manager.dart';
import 'package:ping/features/chats/model/_model.dart';
import 'package:ping/features/chats/widgets/_widgets.dart';

class MessageInputBar extends WatchingWidget {
  const MessageInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = createOnce(TextEditingController.new);

    final manager = di<ChatManager>();

    final reply = watchValue<ChatManager, MessageProxy?>(
      (manager) => manager.replyToMessage,
    );

    return Column(
      mainAxisSize: .min,
      children: [
        if (reply != null) ReplyPreview(reply, onCancel: manager.clearReply),
        Padding(
          padding: const .symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: ShadInput(
                  controller: controller,
                  placeholder: const Text('Message'),
                  maxLines: null,
                  keyboardType: .multiline,
                ),
              ),
              const SizedBox(width: 8),
              ShadButton.ghost(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  manager.sendTextCommand.run(text);
                  controller.clear();
                },
                child: const Icon(LucideIcons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
