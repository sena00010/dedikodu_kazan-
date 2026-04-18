import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP Kazan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _VipHero(),
          SizedBox(height: 16),
          _CreditPack(title: '50 Jeton', subtitle: 'Bir özel odaya AI çağır.', accent: AppColors.lilac),
          SizedBox(height: 12),
          _CreditPack(title: '120 Jeton', subtitle: 'Hafta sonu kazanı harlar.', accent: Color(0xFFFFD8ED)),
          SizedBox(height: 12),
          _CreditPack(title: '300 Jeton', subtitle: 'Kalabalık kanka grupları için.', accent: Color(0xFFFFE1CA)),
        ],
      ),
    );
  }
}

class _VipHero extends StatelessWidget {
  const _VipHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppGradients.gossip, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            'VIP kazan modu',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Özel rozet, premium kazanlar ve odalarda daha uzun AI sohbet süresi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.ink),
            onPressed: () {},
            child: const Text('VIP ol'),
          ),
        ],
      ),
    );
  }
}

class _CreditPack extends StatelessWidget {
  const _CreditPack({required this.title, required this.subtitle, required this.accent});
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_rounded, color: AppColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(72, 40), backgroundColor: AppColors.blue),
              onPressed: () {},
              child: const Text('Al'),
            ),
          ),
        ],
      ),
    );
  }
}
