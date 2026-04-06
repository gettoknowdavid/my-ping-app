import 'package:flutter/material.dart';
import 'package:ping/_core/phone_number_parser.dart';
import 'package:ping/_ping.dart';

class PhoneChangeStep2Page extends WatchingWidget {
  const PhoneChangeStep2Page(this.newPhoneNumber, {super.key});

  final String newPhoneNumber;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final formattedPhoneNumber = parsePhoneNumber(newPhoneNumber);

    final shareNumber = createOnce(() => ValueNotifier(false));
    watch(shareNumber);

    final shareNumberType = createOnce(
      () => ValueNotifier<ShareNumberType?>(.all),
    );
    watch(shareNumberType);

    return Scaffold(
      appBar: AppBar(title: const Text('Change number')),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.p,
                      children: [
                        const TextSpan(
                          text: 'You are about to change your phone number to ',
                        ),
                        TextSpan(
                          text: formattedPhoneNumber,
                          style: theme.textTheme.p.copyWith(fontWeight: .w600),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 64, color: theme.colorScheme.mutedForeground),
                Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: .start,
                    spacing: 16,
                    children: [
                      Expanded(
                        child: Text(
                          '''Do you want to share your new number with your contacts?''',
                          style: theme.textTheme.p,
                        ),
                      ),
                      ShadSwitch(
                        value: shareNumber.value,
                        onChanged: (input) => shareNumber.value = input,
                      ),
                    ],
                  ),
                ),
                if (shareNumber.value) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const .symmetric(horizontal: 16),
                    child: ShadRadioGroup<ShareNumberType>(
                      spacing: 8,
                      initialValue: shareNumberType.value,
                      items: ShareNumberType.values.map((type) {
                        return ShadRadio(
                          value: type,
                          label: Text(
                            type.name,
                            style: theme.textTheme.p,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => shareNumberType.value = value,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Divider(height: 64, color: theme.colorScheme.mutedForeground),
                _FinalStatement(shareNumber: shareNumber.value),
                const Spacer(),
                SafeArea(
                  child: Padding(
                    padding: const .fromLTRB(16, 0, 16, 16),
                    child: ShadButton(
                      onPressed: () async {},
                      child: const Text('Done'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalStatement extends StatelessWidget {
  const _FinalStatement({required this.shareNumber});

  final bool shareNumber;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final style = theme.textTheme.muted;

    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: RichText(
        text: TextSpan(
          style: style,
          children: [
            if (!shareNumber)
              const TextSpan(
                text: 'Your new number will only be shared with your groups.',
              )
            else ...[
              const TextSpan(
                text: 'Your new number will be shared with your groups and ',
              ),
              TextSpan(
                text: '165 contacts',
                style: style.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: .w600,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ],
        ),
      ),
    );
  }
}

enum ShareNumberType { all, contactsIHaveChatsWith, custom }

extension ShareNumberTypeX on ShareNumberType {
  String get name => switch (this) {
    .all => 'All',
    .contactsIHaveChatsWith => 'Contacts I have chats with',
    .custom => 'Custom',
  };
}
