import 'package:flutter/material.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VIP kazan modu', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Özel rozet, premium kazanlar ve odalarda daha uzun AI sohbet süresi.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () {}, child: const Text('VIP ol')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CreditPack(title: '50 Jeton', subtitle: 'Bir özel odaya AI çağırmak için ideal.'),
          const SizedBox(height: 12),
          _CreditPack(title: '120 Jeton', subtitle: 'Hafta sonu kazanı kaynatır.'),
          const SizedBox(height: 12),
          _CreditPack(title: '300 Jeton', subtitle: 'Kalabalık arkadaş grupları için.'),
        ],
      ),
    );
  }
}

class _CreditPack extends StatelessWidget {
  const _CreditPack({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: FilledButton(onPressed: () {}, child: const Text('Al')),
    );
  }
}
