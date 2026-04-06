import 'package:flutter/material.dart';
import 'package:ping/_core/phone_number_parser.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/profile/manager/profile_manager.dart';
import 'package:ping/features/profile/widgets/_widgets.dart';

class ProfilePage extends WatchingWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = di<ProfileManager>().profile;
    watch(profile);

    final formattedPhoneNumber = parsePhoneNumber(profile.phone);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const .all(16),
        child: Column(
          children: [
            const Center(child: ProfileAvatar(dimension: 160)),
            ShadButton.link(child: const Text('Edit'), onPressed: () {}),
            const SizedBox(height: 24),
            ProfilePageTile(
              icon: const Icon(LucideIcons.userRound),
              label: 'Name',
              content: Text(profile.displayName),
              onPressed: () => const ProfileNameRoute().push<void>(context),
            ),
            const SizedBox(height: 16),
            ProfilePageTile(
              icon: const Icon(LucideIcons.info),
              label: 'About',
              content: Text(profile.about),
              onPressed: () => const ProfileAboutRoute().push<void>(context),
            ),
            const SizedBox(height: 16),
            ProfilePageTile(
              icon: const Icon(LucideIcons.phone),
              label: 'Phone',
              content: Text(formattedPhoneNumber),
              onPressed: () => const ProfilePhoneRoute().push<void>(context),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePageTile extends StatelessWidget {
  const ProfilePageTile({
    required this.icon,
    required this.label,
    required this.content,
    super.key,
    this.onPressed,
  });

  final Widget icon;
  final String label;
  final Widget content;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: ShadCard(
        padding: const .fromLTRB(16, 8, 16, 8),
        columnMainAxisAlignment: .center,
        rowCrossAxisAlignment: .center,
        leading: Padding(
          padding: const .only(right: 16),
          child: IconTheme(
            data: IconThemeData(
              size: 18,
              color: theme.colorScheme.mutedForeground,
            ),
            child: icon,
          ),
        ),
        title: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(label, style: theme.textTheme.p.copyWith(fontWeight: .w500)),
            DefaultTextStyle(
              style: theme.textTheme.muted.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}
