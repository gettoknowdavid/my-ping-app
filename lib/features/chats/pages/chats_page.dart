import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ping', style: theme.textTheme.h2),
        actions: [
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.ellipsisVertical),
            onPressed: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
      body: const Center(child: Text('Chats')),
    );
  }
}
