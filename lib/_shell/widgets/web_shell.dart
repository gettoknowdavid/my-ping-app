import 'package:flutter/material.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shell/widgets/_widgets.dart';

class WebShell extends StatelessWidget {
  const WebShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: .none,
      destinations: ShellNavItem.items.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
        );
      }).toList(),
      trailing: const Expanded(
        child: Align(
          alignment: .bottomCenter,
          child: Padding(
            padding: .only(bottom: 16),
            child: ProfileAvatar(),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends WatchingWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const ShadAvatar(null, placeholder: Text('DA')),
    );
  }
}
