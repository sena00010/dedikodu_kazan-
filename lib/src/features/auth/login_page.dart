import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tr_strings.dart';
import '../../theme/app_theme.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.errorText});
  final String? errorText;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final errorText = auth.hasError ? auth.error.toString() : widget.errorText;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppGradients.gossip
              : const LinearGradient(
                  colors: [Color(0xFFFFFBF7), Color(0xFFF0E9FF), Color(0xFFFFE0EF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                  maxWidth: wide ? 980 : 520,
                ),
                child: Center(
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _BrandPanel(errorText: errorText)),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _LoginForm(
                                register: _register,
                                name: _name,
                                email: _email,
                                password: _password,
                                loading: auth.isLoading,
                                onSubmit: _submitEmail,
                                onGoogle: _submitGoogle,
                                onToggle: _toggleMode,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BrandPanel(errorText: errorText),
                            const SizedBox(height: 28),
                            _LoginForm(
                              register: _register,
                              name: _name,
                              email: _email,
                              password: _password,
                              loading: auth.isLoading,
                              onSubmit: _submitEmail,
                              onGoogle: _submitGoogle,
                              onToggle: _toggleMode,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleMode() => setState(() => _register = !_register);

  void _submitGoogle() => ref.read(authControllerProvider.notifier).signInWithGoogle();

  void _submitEmail() {
    final controller = ref.read(authControllerProvider.notifier);
    if (_register) {
      controller.emailRegister(_name.text, _email.text, _password.text);
    } else {
      controller.emailLogin(_email.text, _password.text);
    }
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.register,
    required this.name,
    required this.email,
    required this.password,
    required this.loading,
    required this.onSubmit,
    required this.onGoogle,
    required this.onToggle,
  });

  final bool register;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          register ? 'Kazana ilk kepçeyi atalım' : 'Kazana hoş geldin',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        if (register)
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: TrStrings.fullName),
          ),
        if (register) const SizedBox(height: 12),
        TextField(
          controller: email,
          decoration: const InputDecoration(labelText: TrStrings.email),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: TrStrings.password),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: loading ? null : onSubmit,
          child: Text(register ? TrStrings.register : TrStrings.emailLogin),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: loading ? null : onGoogle,
          child: const Text(TrStrings.googleLogin),
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(register ? TrStrings.emailLogin : TrStrings.register),
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({this.errorText});
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppGradients.warm,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(Icons.local_fire_department, color: Colors.white, size: 46),
        ),
        const SizedBox(height: 24),
        Text(
          TrStrings.appName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(TrStrings.appTagline, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        if (errorText != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              errorText!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}
