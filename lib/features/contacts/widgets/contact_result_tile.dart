import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/contacts/model/contact_result.dart';

class ContactResultTile extends StatelessWidget {
  const ContactResultTile({required this.contact, super.key});

  final ContactResult contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ShadAvatar(
        contact.avatarUrl != null
            ? CachedNetworkImageProvider(contact.avatarUrl!)
            : null,
        placeholder: Text(contact.label[0].toUpperCase()),
      ),
      title: Text(contact.label),
      subtitle: Text(contact.phone),
      onTap: () {
        // Will navigate to new conversation when chat exists
        // For now: show a toast or profile preview
      },
    );
  }
}
