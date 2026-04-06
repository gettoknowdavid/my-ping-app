import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/profile/manager/profile_manager.dart';

class ProfileNamePage extends WatchingWidget {
  const ProfileNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = createOnce(() => ValueNotifier<String>(''));
    watch(name);

    final profile = di<ProfileManager>().profile;
    watch(profile);

    final isSaving = watch(profile.updateDisplayNameCommand.isRunning);

    registerHandler(
      target: profile.updateDisplayNameCommand.errors,
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
      appBar: AppBar(title: const Text('Name')),
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
                    label: const Text('Your name'),
                    placeholder: const Text('John Doe'),
                    description: const Text(
                      '''People will see this name if you interact with them and they don't have you saved as a contact''',
                    ),
                    maxLength: 25,
                    maxLengthEnforcement: .enforced,
                    initialValue: profile.displayName,
                    autofocus: true,
                    onChanged: (input) => name.value = input,
                  ),
                  const Spacer(),
                  SafeArea(
                    child: ShadButton(
                      enabled: !isSaving.value,
                      onPressed: () {
                        if (name.value.isEmpty) return;
                        profile.updateDisplayNameCommand.run(name.value);
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
