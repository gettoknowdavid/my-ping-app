import 'package:flutter/material.dart' show IconData;
import 'package:ping/_ping.dart' show LucideIcons;

class ShellNavItem {
  const ShellNavItem._({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  // The four tabs — defined once, used by both shells
  static const List<ShellNavItem> items = [
    ShellNavItem._(
      icon: LucideIcons.messageCircleMore,
      selectedIcon: LucideIcons.messageCircleMore,
      label: 'Chats',
    ),
    ShellNavItem._(
      icon: LucideIcons.circleFadingPlus,
      selectedIcon: LucideIcons.circleFadingPlus,
      label: 'Updates',
    ),
    ShellNavItem._(
      icon: LucideIcons.users,
      selectedIcon: LucideIcons.users,
      label: 'Communities',
    ),
    ShellNavItem._(
      icon: LucideIcons.phone,
      selectedIcon: LucideIcons.phone,
      label: 'Calls',
    ),
  ];
}
