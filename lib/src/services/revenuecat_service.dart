import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/app_config.dart';

class RevenueCatService {
  static Future<void> configure(String firebaseUid) async {
    final key = Platform.isIOS ? AppConfig.revenueCatAppleKey : AppConfig.revenueCatGoogleKey;
    if (key.isEmpty) return;
    await Purchases.configure(PurchasesConfiguration(key)..appUserID = firebaseUid);
  }
}
