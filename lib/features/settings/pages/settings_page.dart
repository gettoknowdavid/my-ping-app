import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/profile/manager/profile_manager.dart';
import 'package:ping/features/profile/widgets/_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SingleChildScrollView(
        padding: .symmetric(horizontal: 16),
        child: Column(
          children: [ProfileTile()],
        ),
      ),
    );
  }
}

class ProfileTile extends WatchingWidget {
  const ProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = di<ProfileManager>().profile;
    watch(profile);

    final theme = ShadTheme.of(context);

    return Row(
      children: [
        const ProfileAvatar(dimension: 60),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => const ProfileRoute().push<void>(context),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(profile.displayName, style: theme.textTheme.lead),
                Text(profile.about),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        ShadIconButton.ghost(
          icon: const Icon(LucideIcons.circlePlus),
          onPressed: () {},
        ),
      ],
    );
  }
}
