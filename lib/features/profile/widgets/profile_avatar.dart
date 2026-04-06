import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/profile/manager/_manager.dart';

class ProfileAvatar extends WatchingWidget {
  const ProfileAvatar({super.key, this.onPressed, this.dimension});

  final void Function()? onPressed;
  final double? dimension;

  @override
  Widget build(BuildContext context) {
    final profile = di<ProfileManager>().profile;
    watch(profile);

    final placeholder = _getInitials(profile.displayName);

    final textTheme = ShadTheme.of(context).textTheme;
    final fontSize = dimension != null ? dimension! * 0.2 : null;
    final placeholderTextStyle = textTheme.muted.copyWith(fontSize: fontSize);

    return GestureDetector(
      onTap: onPressed,
      child: ShadAvatar(
        profile.avatarUrl,
        placeholder: Text(placeholder, style: placeholderTextStyle),
        size: dimension != null ? Size.square(dimension!) : null,
      ),
    );
  }
}

String _getInitials(String displayName) {
  final trimmedName = displayName.trim();
  if (trimmedName.isEmpty) return '';

  // Splits the name by any sequence of whitespace
  final nameParts = trimmedName.split(RegExp(r'\s+'));

  // Extract the first character of the first word and capitalize it
  final firstInitial = nameParts.first[0].toUpperCase();

  // If there is only one word, return just the first initial
  if (nameParts.length == 1) return firstInitial;

  // If there are multiple words, grab the first character of the last word
  final lastInitial = nameParts.last[0].toUpperCase();

  return '$firstInitial$lastInitial';
}
