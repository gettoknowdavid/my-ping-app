import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/contacts/manager/contacts_manager.dart';

class ContactSearchBar extends WatchingWidget {
  const ContactSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isSearching = watchValue<ContactsManager, bool>(
      (manager) => manager.searchCommand.isRunning,
    );

    return ShadInput(
      placeholder: const Text('Enter phone number'),
      leading: const Icon(LucideIcons.search),
      trailing: isSearching ? const LoadingIndicator(size: 16) : null,
      onChanged: (value) => di<ContactsManager>().phoneInput.value = value,
      keyboardType: .phone,
    );
  }
}
