import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _destinations = [
    _NavDestination(
      label: 'Lists',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      route: '/lists',
    ),
    _NavDestination(
      label: 'Items',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      route: '/items',
    ),
    _NavDestination(
      label: 'History',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      route: '/history',
    ),
    _NavDestination(
      label: 'Profile',
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      route: '/profile',
    ),
  ];

  int get _selectedIndex {
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_destinations[i].route),
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}
