import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_routing/_routing.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';
import 'package:ping/features/auth/model/_model.dart';

class HomePage extends WatchingWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = di<Profile>();
    log(profile.toString());
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const .only(left: 16),
          child: ShadAvatar(
            profile.avatarUrl,
            placeholder: Text(profile.displayName?[0] ?? ''),
          ),
        ),
      ),
      body: Center(
        child: ShadButton.destructive(
          onPressed: di<AuthManager>().signOut.run,
          leading: const Icon(LucideIcons.logOut),
          child: const Text('Logout'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => const ContactSearchRoute().push<void>(context),
        child: const Icon(LucideIcons.messageCirclePlus),
      ),
    );
  }
}

// 9018304102
