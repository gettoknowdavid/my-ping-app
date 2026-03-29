import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/contacts/manager/contacts_manager.dart';
import 'package:ping/features/contacts/model/contact_result.dart';
import 'package:ping/features/contacts/widgets/_widgets.dart';

class ContactSearchPage extends WatchingWidget {
  const ContactSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = watchValue<ContactsManager, ContactResult?>(
      (manager) => manager.result,
    );

    final hasSearched = watchValue<ContactsManager, bool>(
      (manager) => manager.hasSearched,
    );

    final isSearching = watchValue<ContactsManager, bool>(
      (manager) => manager.searchCommand.isRunning,
    );

    registerHandler<ContactsManager, CommandError<String>?>(
      select: (manager) => manager.searchCommand.errors,
      handler: (context, error, _) {
        if (error == null) return;
        if (error.error is PingException) {
          di<ToastManager>().error(error.error.message);
        } else {
          di<ToastManager>().error(error.error.toString());
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ContactSearchBar(),
            const SizedBox(height: 24),
            if (isSearching)
              const Center(child: LoadingIndicator())
            else if (result != null)
              ContactResultTile(contact: result)
            else if (hasSearched)
              const Center(child: Text('No user found with that number'))
            else
              const Center(child: Text('Enter a phone number to find someone')),
          ],
        ),
      ),
    );
  }
}
