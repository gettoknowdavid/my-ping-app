import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/profile/manager/profile_manager.dart';

class PhoneChangeStep1Page extends WatchingWidget {
  const PhoneChangeStep1Page({super.key});

  @override
  Widget build(BuildContext ctx) {
    final theme = ShadTheme.of(ctx);

    final profile = di<ProfileManager>().profile;

    final formKey = createOnce(GlobalKey<ShadFormState>.new);

    final oldPhoneFocusNode = createOnce(FocusNode.new);
    final newPhoneFocusNode = createOnce(FocusNode.new);

    final oldPhoneNumber = createOnce(
      () => ValueNotifier<MobileNumber?>(
        MobileNumber.fromCompleteNumber(completeNumber: profile.phone),
      ),
    );
    final newPhoneNumber = createOnce(() => ValueNotifier<MobileNumber?>(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Change number')),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const .all(16),
              child: ShadForm(
                key: formKey,
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    PhoneInputFormField(
                      id: 'old_phone',
                      initialValue: oldPhoneNumber.value,
                      label: const Text('Enter your old phone number:'),
                      labelStyle: theme.textTheme.p,
                      focusNode: oldPhoneFocusNode,
                      onChanged: (value) => oldPhoneNumber.value = value,
                      placeholder: const Text('8011223344'),
                      validator: (v) {
                        final n = v?.number;
                        if (n == null || n.isEmpty) {
                          return 'Your old phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PhoneInputFormField(
                      id: 'new_phone',
                      label: const Text('Enter your new phone number:'),
                      labelStyle: theme.textTheme.p,
                      focusNode: newPhoneFocusNode,
                      onChanged: (value) => newPhoneNumber.value = value,
                      placeholder: const Text('9011222333'),
                      validator: (v) {
                        final n = v?.number;
                        if (n == null || n.isEmpty) {
                          return 'Your new phone number is required';
                        }
                        if (n == oldPhoneNumber.value?.number) {
                          return '''Your new phone number must be different from your old phone number''';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    SafeArea(
                      child: ShadButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() == false) return;

                          final number = newPhoneNumber.value?.completeNumber;
                          if (number == null) return;

                          await PhoneChangeStep2Route(number).push<void>(ctx);
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
