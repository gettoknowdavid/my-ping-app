import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final class PingTheme {
  const PingTheme._();

  static ShadThemeData get darkTheme => _raw(.dark);

  static ShadThemeData get theme => _raw(.light);

  static ShadThemeData _raw(Brightness brightness) {
    final colorScheme = switch (brightness) {
      .light => const ShadGreenColorScheme.light(),
      .dark => const ShadGreenColorScheme.dark(),
    };

    return ShadThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      inputTheme: const ShadInputTheme(padding: .all(12)),
      inputOTPTheme: const ShadInputOTPTheme(height: 48, width: 48),
      selectTheme: const ShadSelectTheme(padding: .all(12)),
      sheetTheme: const ShadSheetTheme(
        removeBorderRadiusWhenTiny: false,
        radius: .all(.circular(16)),
        padding: .fromLTRB(16, 0, 16, 20),
        closeIconPosition: ShadPosition(top: 0, right: 16),
        titleTextAlign: .start,
        descriptionTextAlign: .start,
      ),
      destructiveToastTheme: const ShadToastTheme(
        padding: .symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

extension CustomColorExtension on ShadColorScheme {
  Color get blue500 => custom['blue500']!;

  Color get blue600 => custom['blue600']!;

  Color get green500 => custom['green500']!;

  Color get green600 => custom['green600']!;

  Color get light200 => custom['light200']!;

  Color get red500 => custom['red500']!;

  Color get red600 => custom['red600']!;

  Color get red700 => custom['red700']!;

  Color get dark200 => custom['dark200']!;

  Color get dark300 => custom['dark300']!;

  Color get dark400 => custom['dark400']!;

  Color get dark500 => custom['dark500']!;

  Color get dark600 => custom['dark600']!;

  Color get dark700 => custom['dark700']!;
}
