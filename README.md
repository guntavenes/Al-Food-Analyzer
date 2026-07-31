# AI Food Analyzer

AI Food Analyzer için Flutter tabanlı, ölçeklenebilir mobil uygulama iskeleti.
Bu aşamada ürün özelliği, kamera, AI, Firebase veya reklam entegrasyonu bulunmaz.

## Teknoloji

- Flutter stable ve Dart
- Clean Architecture
- Feature-first klasör yapısı
- Riverpod ile bağımlılık ve durum yönetimi
- GoRouter ile yönlendirme
- Material 3, açık/koyu tema
- Flutter localization (başlangıç dili: English)
- Flutter Lints ve ek katı analiz kuralları

## Klasör yapısı

```text
lib/
├── app/                    # Uygulama kökü ve global kurulum
├── core/                   # Tema, router, sabitler ve altyapı
├── features/               # Feature-first modüller
│   └── home/
│       ├── data/           # Veri kaynakları, DTO/model ve repository impl.
│       ├── domain/         # Entity, repository sözleşmesi ve use case
│       └── presentation/   # Sayfa, widget ve Riverpod provider'ları
├── l10n/                   # ARB dosyaları ve üretilen localization kodu
├── shared/                 # Özellikler arasında paylaşılan bileşenler
└── main.dart

assets/
├── animations/
├── icons/
└── images/
```

`data -> domain <- presentation` bağımlılık yönü korunmalıdır. `core`, uygulama
genelindeki altyapıyı; `shared`, birden fazla özellikte kullanılan yeniden
kullanılabilir parçaları barındırır.

## Kurulum

Flutter'ın stable kanalında olduğunuzdan emin olun:

```bash
flutter channel stable
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

## Localization

Kaynak çeviriler `lib/l10n` altındaki ARB dosyalarında tutulur. Yeni bir dil
için `app_<locale>.arb` ekleyip `flutter gen-l10n` çalıştırın.

## Mimari notları

- Her yeni özellik `lib/features/<feature_name>` altında kendi `data`, `domain`
  ve `presentation` katmanlarıyla oluşturulur.
- İş kuralları Flutter bağımlılığı taşımayan `domain` katmanında tutulur.
- Uygulama genelindeki route tanımları `core/router` altında yönetilir.
- Tema renkleri ve ThemeData tanımları `core/theme` altında merkezidir.
