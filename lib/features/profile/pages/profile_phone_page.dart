import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';

class ProfilePhonePage extends WatchingWidget {
  const ProfilePhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Change number')),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const .symmetric(horizontal: 32, vertical: 16),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: .center,
                      spacing: 10,
                      children: [
                        const Icon(
                          LucideIcons.cardSim200,
                          size: 100,
                          color: Colors.green,
                        ),
                        Icon(
                          LucideIcons.ellipsis,
                          size: 40,
                          color: Colors.green.shade100,
                        ),
                        Icon(
                          LucideIcons.cardSim200,
                          size: 100,
                          color: Colors.green.shade100,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '''Changing your phone number will migrate your account info, groups & settings.''',
                    style: theme.textTheme.p.copyWith(
                      fontWeight: .w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '''Before proceeding, please confirm that you are able to receive SMS or calls from the new number.''',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '''If you have both a new phone & a new number, first change your number on your old phone.''',
                    style: theme.textTheme.muted,
                  ),
                  const Spacer(),
                  SafeArea(
                    child: ShadButton(
                      onPressed: () =>
                          const PhoneChangeStep1Route().replace(context),
                      child: const Text('Next'),
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
