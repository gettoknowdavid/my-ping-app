import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/widgets/loading_indicator.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';
import 'package:ping/features/auth/model/_model.dart';

class PhoneVerificationPage extends WatchingWidget {
  const PhoneVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = createOnce(GlobalKey<FormState>.new);
    final otp = createOnce(() => ValueNotifier<String>(''));

    final phone = watchValue<AuthManager, String>(
      (m) => m.status.select(
        (value) => value.maybeWhen(
          awaitingOtp: (phone) => phone,
          authenticated: (profile) => profile.phone,
          orElse: () => '',
        ),
      ),
    );

    final isRunning = watchValue<AuthManager, bool>(
      (m) => m.verifyPhoneNumber.isRunning,
    );

    final textTheme = ShadTheme.of(context).textTheme;
    final subtitleTextStyle = textTheme.muted.copyWith(height: 1.5);

    return Form(
      key: formKey,
      autovalidateMode: .onUserInteraction,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verify your phone number', style: textTheme.h4),
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
                  style: subtitleTextStyle,
                  children: [
                    const TextSpan(
                      text: 'Waiting to automatically detect an SMS sent to ',
                    ),
                    TextSpan(
                      text: phone,
                      style: subtitleTextStyle.copyWith(fontWeight: .bold),
                    ),
                    const TextSpan(text: ' Wrong number?'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ShadInputOTPFormField(
                id: 'otp',
                maxLength: 6,
                enabled: !isRunning,
                autovalidateMode: .onUserInteractionIfError,
                label: const Text('OTP'),
                description: const Text('Enter the OTP.'),
                keyboardType: .number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => otp.value = value,
                validator: (v) {
                  if (v.contains(' ')) return 'Fill the whole OTP code';
                  return null;
                },
                children: const [
                  ShadInputOTPGroup(
                    children: [
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                    ],
                  ),
                  Icon(size: 24, LucideIcons.dot),
                  ShadInputOTPGroup(
                    children: [
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                      ShadInputOTPSlot(),
                    ],
                  ),
                ],
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
                  enabled: !isRunning || otp.value.isNotEmpty,
                  leading: isRunning ? const LoadingIndicator.primary() : null,
                  onPressed: () async {
                    if (otp.value.isEmpty) return;
                    FocusScope.of(context).unfocus();
                    final args = VerifyOtpArgs(phone: phone, otp: otp.value);
                    di<AuthManager>().verifyPhoneNumber.run(args);
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
