import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tr_strings.dart';
import '../auth/auth_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _job = TextEditingController();
  final _gender = TextEditingController();
  final _partner = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = ref.read(authControllerProvider).value?.user?.fullName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 720 : 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text('Kazan profilini hazırlayalım', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(TrStrings.optionalInfo),
                const SizedBox(height: 24),
                TextField(controller: _name, decoration: const InputDecoration(labelText: TrStrings.fullName)),
                const SizedBox(height: 12),
                TextField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yaş')),
                const SizedBox(height: 12),
                TextField(controller: _job, decoration: const InputDecoration(labelText: 'Meslek')),
                const SizedBox(height: 12),
                TextField(controller: _gender, decoration: const InputDecoration(labelText: 'Cinsiyet')),
                const SizedBox(height: 12),
                TextField(controller: _partner, decoration: const InputDecoration(labelText: 'Erkek arkadaş / partner')),
                const SizedBox(height: 18),
                FilledButton(onPressed: _save, child: const Text('Devam et')),
                TextButton(onPressed: _saveMinimal, child: const Text('Sonra doldururum')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMinimal() => _save(skipOptional: true);

  Future<void> _save({bool skipOptional = false}) async {
    await ref.read(authControllerProvider.notifier).completeOnboarding({
      'full_name': _name.text.trim().isEmpty ? 'Dedikoducu' : _name.text.trim(),
      if (!skipOptional && _age.text.trim().isNotEmpty) 'age': int.tryParse(_age.text.trim()),
      if (!skipOptional && _job.text.trim().isNotEmpty) 'job_title': _job.text.trim(),
      if (!skipOptional && _gender.text.trim().isNotEmpty) 'gender': _gender.text.trim(),
      if (!skipOptional && _partner.text.trim().isNotEmpty) 'partner': _partner.text.trim(),
    });
  }
}
