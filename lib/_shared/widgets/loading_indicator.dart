import 'package:flutter/material.dart';
import 'package:ping/_ping.dart' show ShadTheme;

enum IndicatorType { primary, normal }

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    double dimension = 12,
    Color? color,
    Key? key,
  }) : this._(type: .normal, key: key, color: color, dimension: dimension);

  const LoadingIndicator.primary({
    double dimension = 12,
    Key? key,
  }) : this._(type: .primary, key: key, dimension: dimension);

  const LoadingIndicator._({
    required this.type,
    this.dimension = 12,
    this.color,
    super.key,
  });

  final double dimension;
  final Color? color;
  final IndicatorType type;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return SizedBox.square(
      dimension: dimension,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: switch (type) {
          .primary => colors.primaryForeground,
          .normal => color ?? colors.foreground,
        },
      ),
    );
  }
}
