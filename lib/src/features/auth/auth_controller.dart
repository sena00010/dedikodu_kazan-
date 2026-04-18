import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../services/revenuecat_service.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  const AuthState({this.user, this.onboardingCompleted = false});

  final AppUser? user;
  final bool onboardingCompleted;
  bool get isAuthenticated => user != null;
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return const AuthState();
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.get<Map<String, dynamic>>('/api/user/me');
      return AuthState(
        user: AppUser.fromJson(res.data!),
        onboardingCompleted: prefs.getBool('onboarding_completed') ?? false,
      );
    } on DioException {
      await prefs.remove('auth_token');
      await prefs.remove('onboarding_completed');
      return const AuthState();
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final google = await GoogleSignIn().signIn();
      if (google == null) return const AuthState();
      final auth = await google.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final firebaseUser = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await firebaseUser.user!.getIdToken();
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'firebase_token': firebaseToken},
      );
      await _persist(res.data!['token'] as String);
      await RevenueCatService.configure(firebaseUser.user!.uid);
      return AuthState(user: AppUser.fromJson(res.data!['user'] as Map<String, dynamic>));
    });
  }

  Future<void> emailLogin(String email, String password) => _email('/api/auth/email-login', {
        'email': email,
        'password': password,
      });

  Future<void> emailRegister(String fullName, String email, String password) =>
      _email('/api/auth/register', {
        'full_name': fullName,
        'email': email,
        'password': password,
      });

  Future<void> _email(String path, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final api = ref.read(apiClientProvider);
        final res = await api.dio.post<Map<String, dynamic>>(path, data: data);
        await _persist(res.data!['token'] as String);
        return AuthState(user: AppUser.fromJson(res.data!['user'] as Map<String, dynamic>));
      } on DioException catch (error) {
        final data = error.response?.data;
        if (data is Map && data['error'] is String) {
          throw AuthMessage(data['error'] as String);
        }
        throw AuthMessage('Giriş yapılamadı. Bilgilerini kontrol edip tekrar dene.');
      }
    });
  }

  Future<void> completeOnboarding(Map<String, dynamic> data) async {
    final user = await updateProfile(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = AsyncData(AuthState(
      user: user,
      onboardingCompleted: true,
    ));
  }

  Future<AppUser> updateProfile(Map<String, dynamic> data) async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.put<Map<String, dynamic>>('/api/user/me', data: data);
      final user = AppUser.fromJson(res.data!);
      final current = state.valueOrNull;
      state = AsyncData(AuthState(
        user: user,
        onboardingCompleted: current?.onboardingCompleted ?? false,
      ));
      return user;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['error'] is String) {
        throw AuthMessage(data['error'] as String);
      }
      throw AuthMessage('Profil kaydedilemedi. Bağlantıyı kontrol edip tekrar dene.');
    }
  }

  Future<void> finishOnboarding() async {
    final current = state.valueOrNull;
    if (current?.user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = AsyncData(AuthState(user: current!.user, onboardingCompleted: true));
  }

  Future<void> skipOnboarding() async {
    final current = state.valueOrNull;
    if (current?.user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = AsyncData(AuthState(
      user: current!.user,
      onboardingCompleted: true,
    ));
  }

  Future<void> _persist(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
}

class AuthMessage implements Exception {
  const AuthMessage(this.message);
  final String message;

  @override
  String toString() => message;
}
