import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';

class ConversationAvatar extends WatchingWidget {
  const ConversationAvatar(
    this.url, {
    required this.displayName,
    super.key,
    this.dimension,
  });

  final String? url;
  final String displayName;
  final double? dimension;

  @override
  Widget build(BuildContext context) {
    final placeholder = displayName[0].toUpperCase();

    final textTheme = ShadTheme.of(context).textTheme;
    final fontSize = dimension != null ? dimension! * 0.2 : null;
    final placeholderTextStyle = textTheme.muted.copyWith(fontSize: fontSize);

    return ShadAvatar(
      url,
      placeholder: Text(placeholder, style: placeholderTextStyle),
      size: dimension != null ? Size.square(dimension!) : null,
    );
  }
}
