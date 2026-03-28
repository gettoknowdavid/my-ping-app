import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';
import 'package:ping/features/auth/model/_model.dart';

class AccountOnboardingPage extends WatchingWidget {
  const AccountOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = createOnce(GlobalKey<ShadFormState>.new);
    final displayName = createOnce(() => ValueNotifier<String>(''));
    final avatar = createOnce(() => ValueNotifier<File?>(null));

    final isRunning = watchValue<AuthManager, bool>(
      (manager) => manager.completeOnboarding.isRunning,
    );

    final userId = watchValue<AuthManager, String>(
      (m) => m.status.select(
        (value) => value.maybeWhen(
          onboarding: (userId) => userId,
          authenticated: (profile) => profile.id,
          orElse: () => '',
        ),
      ),
    );

    final textTheme = ShadTheme.of(context).textTheme;
    final subtitleTextStyle = textTheme.muted.copyWith(height: 1.5);

    watch(displayName);

    return ShadForm(
      key: formKey,
      enabled: !isRunning,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Info', style: textTheme.h4),
          actions: [
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: () => AccountOnboardingOptionsModal.show(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const .all(16),
          child: Column(
            children: [
              Text(
                '''Please provide your name, username and an optional profile photo.''',
                style: subtitleTextStyle,
              ),
              const SizedBox(height: 32),
              _AvatarField(avatar: avatar),
              const SizedBox(height: 32),
              ShadInputFormField(
                id: 'display_name',
                label: const Text('Full Name'),
                placeholder: const Text('John Doe'),
                textInputAction: .done,
                onChanged: (input) => displayName.value = input,
                validator: (input) {
                  if (input.isEmpty) return 'Full Name is required';
                  return null;
                },
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Padding(
            padding: const .symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .min,
              children: [
                ShadButton(
                  enabled: displayName.value.isNotEmpty && !isRunning,
                  onPressed: () {
                    if (!formKey.currentState!.saveAndValidate()) return;
                    final args = NewProfileArgs(
                      userId: userId,
                      displayName: displayName.value,
                      avatar: avatar.value,
                    );
                    di<AuthManager>().completeOnboarding.run(args);
                  },
                  leading: isRunning ? const LoadingIndicator.primary() : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarField extends WatchingWidget {
  const _AvatarField({required this.avatar})
    : super(key: const Key('AccountOnboardingAvatarField'));
  final ValueNotifier<File?> avatar;

  @override
  Widget build(BuildContext context) {
    watch(avatar);

    final hasImage = avatar.value != null;

    final colors = ShadTheme.of(context).colorScheme;

    DecorationImage? image;
    Widget? placeholder = const Icon(LucideIcons.imagePlus, size: 40);

    if (hasImage) {
      image = DecorationImage(image: FileImage(avatar.value!), fit: .cover);
      placeholder = null;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            final result = await ImagePickerModal.show(context);
            if (result != null) avatar.value = result;
          },
          child: Container(
            height: 124,
            width: 124,
            decoration: BoxDecoration(
              color: colors.muted,
              shape: .circle,
              image: image,
            ),
            child: placeholder,
          ),
        ),
        if (hasImage)
          Positioned(
            right: 12,
            bottom: 0,
            child: ShadIconButton.destructive(
              icon: const Icon(LucideIcons.x),
              height: 24,
              width: 24,
              iconSize: 16,
              decoration: const ShadDecoration(shape: .circle),
              onPressed: () => avatar.value = null,
            ),
          ),
      ],
    );
  }
}

class AccountOnboardingOptionsModal extends StatelessWidget {
  const AccountOnboardingOptionsModal._() : super(key: null);

  static Future<void> show(BuildContext context) => showShadSheet<void>(
    context: context,
    useRootNavigator: true,
    side: ShadSheetSide.bottom,
    builder: (_) => const AccountOnboardingOptionsModal._(),
  );

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Padding(
      padding: const .fromLTRB(16, 0, 16, 16),
      child: ShadSheet(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const SizedBox(height: 16),
            ShadButton.ghost(
              crossAxisAlignment: .center,
              mainAxisAlignment: .start,
              onPressed: () async {
                await Supabase.instance.client.auth.refreshSession();
              },
              leading: const Icon(LucideIcons.refreshCcw),
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 16),
            ShadButton.ghost(
              crossAxisAlignment: .center,
              mainAxisAlignment: .start,
              foregroundColor: colors.destructive,
              backgroundColor: colors.destructive.withValues(alpha: 0.2),
              onPressed: () async => Supabase.instance.client.auth.signOut(),
              leading: const Icon(LucideIcons.logOut),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
