import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/profile/manager/profile_manager.dart';

class ProfileAboutPage extends WatchingWidget {
  const ProfileAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final about = createOnce(() => ValueNotifier<String>(''));
    watch(about);

    final profile = di<ProfileManager>().profile;
    watch(profile);

    final isSaving = watch(profile.updateAboutCommand.isRunning);

    registerHandler(
      target: profile.updateAboutCommand.errors,
      handler: (context, error, _) {
        if (error == null) return;
        if ((error as CommandError<Object?>).error is PingException) {
          di<ToastManager>().error(error.error.message);
        } else {
          di<ToastManager>().error(error.error.toString());
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const .all(16),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  ShadInputFormField(
                    label: const Text('About yourself'),
                    placeholder: const Text('Write something about yourself'),
                    description: const Text('Visible in chats to everyone'),
                    initialValue: profile.about,
                    autofocus: true,
                    onChanged: (input) => about.value = input,
                  ),
                  const Spacer(),
                  SafeArea(
                    child: ShadButton(
                      enabled: !isSaving.value,
                      onPressed: () {
                        if (about.value.isEmpty) return;
                        profile.updateAboutCommand.run(about.value);
                        context.pop();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
