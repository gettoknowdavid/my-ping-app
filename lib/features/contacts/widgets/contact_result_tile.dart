import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/contacts/model/contact_result.dart';

class ContactResultTile extends StatelessWidget {
  const ContactResultTile({
    required this.contact,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final ContactResult contact;
  final void Function() onTap;
  final bool enabled;

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
      onTap: enabled ? onTap : null,
    );
  }
}
