import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_page.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return auth.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => LoginPage(errorText: error.toString()),
      data: (state) {
        if (!state.isAuthenticated) return const LoginPage();
        if (!state.onboardingCompleted) return const OnboardingPage();
        return const HomeShell();
      },
    );
  }
}
