import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../premium/premium_page.dart';
import '../profile/profile_page.dart';
import '../chat/direct_messages_page.dart';
import 'threads_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [ThreadsPage(), DirectMessagesPage(), PremiumPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.forum_outlined), label: Text('Kazan')),
                NavigationRailDestination(icon: Icon(Icons.groups_2_outlined), label: Text('Odalar')),
                NavigationRailDestination(icon: Icon(Icons.workspace_premium_outlined), label: Text('Premium')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('Profil')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _pages[_index]),
          ],
        ),
      );
    }
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0x1A090A3A), blurRadius: 24, offset: Offset(0, 10))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  _NavItem(icon: Icons.forum_rounded, label: 'Kazan', selected: _index == 0, onTap: () => setState(() => _index = 0)),
                  _NavItem(icon: Icons.favorite_rounded, label: 'Kankalar', selected: _index == 1, onTap: () => setState(() => _index = 1)),
                  _NavItem(icon: Icons.auto_awesome_rounded, label: 'VIP', selected: _index == 2, onTap: () => setState(() => _index = 2)),
                  _NavItem(icon: Icons.person_rounded, label: 'Profil', selected: _index == 3, onTap: () => setState(() => _index = 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.ink.withValues(alpha: 0.68);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.gossip : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}
