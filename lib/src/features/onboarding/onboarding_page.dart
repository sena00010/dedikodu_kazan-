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
  String? _gender;
  String? _partner;
  bool _saving = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _name.text = ref.read(authControllerProvider).value?.user?.fullName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 720 : 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text(
                  'Kazan profilini hazırlayalım',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(TrStrings.optionalInfo),
                const SizedBox(height: 24),
                TextField(controller: _name, decoration: const InputDecoration(labelText: TrStrings.fullName)),
                const SizedBox(height: 12),
                TextField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yaş')),
                const SizedBox(height: 12),
                TextField(controller: _job, decoration: const InputDecoration(labelText: 'Meslek')),
                const SizedBox(height: 18),
                _ChoiceSection(
                  title: 'Cinsiyet',
                  selected: _gender,
                  values: const ['Kadın', 'Erkek', 'Non-binary', 'Söylemem'],
                  onSelected: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 16),
                _ChoiceSection(
                  title: 'Partner durumu',
                  selected: _partner,
                  values: const ['Var', 'Yok', 'Karışık', 'Söylemem'],
                  onSelected: (value) => setState(() => _partner = value),
                ),
                if (_feedback != null) ...[
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _feedback!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Devam et'),
                ),
                TextButton(
                  onPressed: _saving ? null : _saveMinimal,
                  child: const Text('Sonra doldururum'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMinimal() async {
    setState(() {
      _feedback = null;
      _saving = true;
    });
    await ref.read(authControllerProvider.notifier).skipOnboarding();
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  Future<void> _save({bool skipOptional = false}) async {
    setState(() {
      _feedback = null;
      _saving = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).completeOnboarding({
        'full_name': _name.text.trim().isEmpty ? 'Dedikoducu' : _name.text.trim(),
        if (!skipOptional && _age.text.trim().isNotEmpty) 'age': int.tryParse(_age.text.trim()),
        if (!skipOptional && _job.text.trim().isNotEmpty) 'job_title': _job.text.trim(),
        if (!skipOptional && _gender != null) 'gender': _gender,
        if (!skipOptional && _partner != null) 'partner': _partner,
      });
    } on AuthMessage catch (error) {
      if (mounted) {
        setState(() => _feedback = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _feedback = 'Bir şey ters gitti. Tekrar dener misin?');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                FilterChip(
                  label: Text(value),
                  selected: selected == value,
                  showCheckmark: true,
                  onSelected: (_) => onSelected(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
