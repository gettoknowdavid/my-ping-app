import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        children: [
          const Center(child: Text('Updates')),
          const SizedBox(height: 24),
          ShadButton.destructive(
            onPressed: di<AuthManager>().signOut.run,
            leading: const Icon(LucideIcons.logOut),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
