import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shell/widgets/_widgets.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return ShadResponsiveBuilder(
      builder: (context, breakpoint) {
        final isWide = breakpoint >= ShadTheme.of(context).breakpoints.md;
        if (isWide) return WebShell(navigationShell: navigationShell);
        return MobileShell(navigationShell: navigationShell);
      },
    );
  }
}
