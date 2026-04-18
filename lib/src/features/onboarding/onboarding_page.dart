import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tr_strings.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> with SingleTickerProviderStateMixin {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _job = TextEditingController();
  final _bio = TextEditingController();
  String? _gender;
  String? _partner;
  String _language = 'tr';
  bool _saving = false;
  bool _celebrating = false;
  String? _feedback;
  late final AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value?.user;
    _name.text = user?.fullName ?? '';
    _job.text = user?.jobTitle ?? '';
    _bio.text = user?.bio ?? '';
    _gender = user?.gender;
    _partner = user?.partner;
    _language = user?.languageCode ?? 'tr';
    _confetti = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _name.dispose();
    _age.dispose();
    _job.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFBF7), Color(0xFFEDE6FF), Color(0xFFFFE0EF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 720 : 520),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    shrinkWrap: true,
                    children: [
                      const Center(child: _KazanMark(size: 78)),
                      const SizedBox(height: 18),
                      Text(
                        'Kazan profilini hazırlayalım',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sadece adın yeterli. Diğerleri kazanın tadını tutturmak için.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(controller: _name, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: TrStrings.fullName)),
                      const SizedBox(height: 12),
                      TextField(controller: _age, textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yaş')),
                      const SizedBox(height: 12),
                      TextField(controller: _job, textAlign: TextAlign.center, decoration: const InputDecoration(labelText: 'Meslek')),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bio,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Hakkında',
                          hintText: 'Kısa bio: ilişki dedektifi, kaos arşivcisi...',
                        ),
                      ),
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
                      const SizedBox(height: 16),
                      _ChoiceSection(
                        title: 'Dil',
                        selected: _language,
                        values: const ['tr', 'en'],
                        labels: const {'tr': 'Türkçe', 'en': 'English'},
                        onSelected: (value) => setState(() => _language = value),
                      ),
                      if (_feedback != null) ...[
                        const SizedBox(height: 16),
                        _FeedbackBox(text: _feedback!),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Kazanı başlat'),
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
          ),
          if (_celebrating)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confetti,
                  builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_confetti.value)),
                ),
              ),
            ),
          if (_celebrating)
            Center(
              child: Container(
                margin: const EdgeInsets.all(28),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Color(0x22090A3A), blurRadius: 30, offset: Offset(0, 18))],
                ),
                child: const Text(
                  'Profil hazır. Kazan kaynıyor!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveMinimal() async {
    setState(() {
      _feedback = null;
      _saving = true;
    });
    await _celebrate();
    await ref.read(authControllerProvider.notifier).skipOnboarding();
  }

  Future<void> _save() async {
    setState(() {
      _feedback = null;
      _saving = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateProfile({
        'full_name': _name.text.trim().isEmpty ? 'Dedikoducu' : _name.text.trim(),
        if (_age.text.trim().isNotEmpty) 'age': int.tryParse(_age.text.trim()),
        if (_job.text.trim().isNotEmpty) 'job_title': _job.text.trim(),
        if (_bio.text.trim().isNotEmpty) 'bio': _bio.text.trim(),
        if (_gender != null) 'gender': _gender,
        if (_partner != null) 'partner': _partner,
        'language_code': _language,
      });
      await _celebrate();
      await ref.read(authControllerProvider.notifier).finishOnboarding();
    } on AuthMessage catch (error) {
      if (mounted) {
        setState(() => _feedback = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _feedback = 'Bir şey ters gitti. Tekrar dener misin?');
      }
    } finally {
      if (mounted && !_celebrating) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _celebrate() async {
    if (!mounted) return;
    setState(() => _celebrating = true);
    await _confetti.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}

class _KazanMark extends StatelessWidget {
  const _KazanMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.warm,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: AppColors.pink.withValues(alpha: 0.28), blurRadius: 28, offset: const Offset(0, 16))],
      ),
      child: const Icon(Icons.local_fire_department, color: Colors.white, size: 42),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.onSelected,
    this.labels = const {},
  });

  final String title;
  final List<String> values;
  final String? selected;
  final Map<String, String> labels;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              FilterChip(
                label: Text(labels[value] ?? value),
                selected: selected == value,
                showCheckmark: true,
                onSelected: (_) => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackBox extends StatelessWidget {
  const _FeedbackBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppColors.violet, AppColors.pink, AppColors.coral, AppColors.peach, AppColors.blue];
    for (var i = 0; i < 46; i++) {
      final seed = i * 19.7;
      final x = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final y = size.height * progress + math.cos(seed) * 90 - 140;
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: 1 - progress * 0.25);
      canvas.save();
      canvas.translate(x, y + (i % 5) * 26);
      canvas.rotate(progress * math.pi * 2 + i);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 10, 6), const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
