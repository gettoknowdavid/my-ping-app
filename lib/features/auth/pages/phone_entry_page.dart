import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';

class PhoneEntryPage extends WatchingWidget {
  const PhoneEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = createOnce(GlobalKey<FormState>.new);
    final focusNode = createOnce(FocusNode.new);
    final phone = createOnce(() => ValueNotifier<MobileNumber?>(null));

    final isRunning = watchValue<AuthManager, bool>(
      (m) => m.submitPhoneNumber.isRunning,
    );

    final textTheme = ShadTheme.of(context).textTheme;

    return Form(
      key: formKey,
      autovalidateMode: .onUserInteraction,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Enter your phone number', style: textTheme.h4),
          actions: [
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const .all(16),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: textTheme.muted.copyWith(height: 1.5),
                  children: const [
                    TextSpan(
                      text: '''Ping will need to verify your phone number.''',
                    ),
                    TextSpan(
                      text: ''' Carrier charges may apply. ''',
                    ),
                    TextSpan(
                      text: '''What's my number?''',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PhoneInputFormField(
                id: 'phone',
                focusNode: focusNode,
                enabled: !isRunning,
                onChanged: (value) => phone.value = value,
                placeholder: const Text('8123456789'),
                validator: (v) {
                  final n = v?.number;
                  if (n == null || n.isEmpty) return 'Phone number is required';
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
                  enabled: !isRunning,
                  leading: isRunning ? const LoadingIndicator.primary() : null,
                  onPressed: () async {
                    final number = phone.value?.completeNumber;
                    if (number == null) return;

                    FocusScope.of(context).unfocus();

                    final confirmed = await ConfirmPhoneDialog.show<bool?>(
                      context,
                      number: number,
                    );

                    if (confirmed == null) return;

                    if (!confirmed) {
                      focusNode.requestFocus();
                    } else {
                      di<AuthManager>().submitPhoneNumber.run(number);
                    }
                  },
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

class ConfirmPhoneDialog extends StatelessWidget {
  const ConfirmPhoneDialog._(this.number) : super(key: null);

  static Future<T?> show<T>(BuildContext context, {required String number}) {
    return showShadDialog<T?>(
      context: context,
      builder: (_) => ConfirmPhoneDialog._(number),
    );
  }

  final String number;

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    return Padding(
      padding: const .symmetric(horizontal: 32),
      child: ShadDialog.alert(
        removeBorderRadiusWhenTiny: false,
        title: const Text('Is this number correct?'),
        descriptionTextAlign: .start,
        descriptionStyle: textTheme.muted,
        actionsMainAxisSize: .min,
        actionsMainAxisAlignment: .end,
        actionsAxis: .horizontal,
        expandActionsWhenTiny: false,
        actionsGap: 8,
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Please confirm that '),
                TextSpan(
                  text: number,
                  style: textTheme.muted.copyWith(fontWeight: .bold),
                ),
                const TextSpan(text: ' is your correct phone number.'),
              ],
            ),
          ),
        ),
        actions: [
          ShadButton.outline(
            height: 32,
            child: const Text('Edit'),
            onPressed: () => context.pop(false),
          ),
          ShadButton(
            height: 32,
            child: const Text('Yes'),
            onPressed: () => context.pop(true),
          ),
        ],
      ),
    );
  }
}
