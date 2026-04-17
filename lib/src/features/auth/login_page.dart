import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/tr_strings.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 980 : 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _BrandPanel(errorText: widget.errorText),
                  ),
                  SizedBox(width: wide ? 32 : 0, height: wide ? 0 : 28),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_register)
                          TextField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: TrStrings.fullName),
                          ),
                        if (_register) const SizedBox(height: 12),
                        TextField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: TrStrings.email),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: TrStrings.password),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: auth.isLoading ? null : _submitEmail,
                          child: Text(_register ? TrStrings.register : TrStrings.emailLogin),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: auth.isLoading
                              ? null
                              : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                          child: const Text(TrStrings.googleLogin),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _register = !_register),
                          child: Text(_register ? TrStrings.emailLogin : TrStrings.register),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitEmail() {
    final controller = ref.read(authControllerProvider.notifier);
    if (_register) {
      controller.emailRegister(_name.text, _email.text, _password.text);
    } else {
      controller.emailLogin(_email.text, _password.text);
    }
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_fire_department, color: scheme.onPrimary, size: 38),
        ),
        const SizedBox(height: 24),
        Text(TrStrings.appName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(TrStrings.appTagline, style: Theme.of(context).textTheme.titleMedium),
        if (errorText != null) ...[
          const SizedBox(height: 16),
          Text(errorText!, style: TextStyle(color: scheme.error)),
        ],
      ],
    );
  }
}
