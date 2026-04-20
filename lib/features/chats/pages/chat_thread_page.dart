import 'package:flutter/material.dart';

class ChatThreadPage extends StatelessWidget {
  const ChatThreadPage({required this.conversationId, super.key});
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(conversationId)),
      body: const Center(child: Text('Messages coming in v1.0')),
    );
  }
}
