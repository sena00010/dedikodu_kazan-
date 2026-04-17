import '../core/app_config.dart';

class NotificationService {
  static Future<void> tryInit() async {
    // OneSignal is intentionally left as a config hook for production builds.
    // Local simulator builds stay dependency-light until native notification
    // credentials are added.
    if (AppConfig.oneSignalAppId.isEmpty) return;
  }
}
