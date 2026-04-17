import 'package:flutter/material.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Kazan'),
          NavigationDestination(icon: Icon(Icons.groups_2_outlined), label: 'Odalar'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Premium'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
