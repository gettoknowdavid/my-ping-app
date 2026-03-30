import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';

enum IndicatorType { primary, normal }

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    double size = 12,
    Color? color,
    Key? key,
  }) : this._(type: .normal, key: key, color: color, size: size);

  const LoadingIndicator.primary({
    double size = 12,
    Key? key,
  }) : this._(type: .primary, key: key, size: size);

  const LoadingIndicator._({
    required this.type,
    this.size = 16,
    this.color,
    super.key,
  });

  final double size;
  final Color? color;
  final IndicatorType type;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;

    final effectiveColor = switch (type) {
      .primary => colors.primaryForeground,
      .normal => color ?? colors.foreground,
    };

    return Center(
      child: SizedBox.square(
        dimension: size,
        child: Icon(LucideIcons.loaderCircle, color: effectiveColor, size: size)
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 1.seconds),
      ),
    );
  }
}
