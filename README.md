# Dedikodu Kazani Flutter App

Flutter istemcisi Dio ile Go API'ye baglanir, Firebase Google girisi ve email girisi destekler, WebSocket ile canli mesajlari dinler.

## Calistirma

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080 --dart-define=WS_BASE_URL=ws://127.0.0.1:8080
```

## Entegrasyon notlari

- Firebase icin platform bazli `google-services.json` ve `GoogleService-Info.plist` eklenmeli.
- RevenueCat anahtarlari `REVENUECAT_APPLE_KEY` ve `REVENUECAT_GOOGLE_KEY` dart-define ile verilebilir.
- OneSignal kullanilacaksa `ONESIGNAL_APP_ID` verilir; bos ise otomatik pasif kalir.
- TR metinleri `lib/src/l10n/tr_strings.dart` ve `lib/src/l10n/app_tr.arb` icindedir.
