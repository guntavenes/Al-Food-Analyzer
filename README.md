# AI Food Analyzer

Flutter istemcisi, Drift tabanlı yerel geçmiş ve TypeScript/Express mock analiz
backend'inden oluşan geliştirme projesi. Gerçek AI servisi henüz bağlı değildir.

## Mimari

- Flutter: feature-first clean architecture, Riverpod, GoRouter, Dio ve Drift
- Backend: Express, TypeScript, Zod, Multer ve mock `FoodAnalysisProvider`
- Mobil uygulamada API anahtarı veya başka bir gizli bilgi bulunmaz

## Backend'i çalıştırma

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

Doğrulama komutları:

```bash
npm run typecheck
npm run lint
npm test
npm run build
```

Mock senaryoları `.env` üzerinden seçilir:

```dotenv
MOCK_ANALYSIS_FORCE_ERROR=false
MOCK_ANALYSIS_NO_FOOD=false
```

Başarı için ikisini de `false`, kontrollü hata için `MOCK_ANALYSIS_FORCE_ERROR=true`,
yemek algılanmaması için `MOCK_ANALYSIS_NO_FOOD=true` yapın ve backend'i yeniden
başlatın.

## Flutter uygulamasını çalıştırma

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

Platforma göre API adresleri:

- iOS Simulator: `http://localhost:8080`
- Android Emulator: `http://10.0.2.2:8080`
- Fiziksel cihaz: `http://BILGISAYARIN_YEREL_IP_ADRESI:8080`

Android Emulator örneği:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Fiziksel cihaz ve bilgisayar aynı ağda olmalı; firewall port `8080` erişimine
izin vermelidir. Android debug network config varsayılan olarak yalnızca
`localhost` ve `10.0.2.2` için HTTP açar. Fiziksel Android cihazda HTTPS tüneli
kullanın veya cihaz testi sırasında bilgisayarın tam yerel IP adresini yalnızca
debug network config'e ekleyin. Release build, HTTPS olmayan `API_BASE_URL`
değerini reddeder.

## API

- `GET /health`
- `POST /v1/food/analyze`
  - `multipart/form-data`
  - zorunlu `image`
  - opsiyonel `locale` (`en` veya `tr`)
  - JPG, PNG ve WebP; en fazla 8 MB

## Gizlilik ve güvenlik

Seçilen fotoğraf analiz amacıyla backend'e gönderilir. Mock backend görseli
yalnızca request belleğinde tutar; diske veya buluta kaydetmez, loglamaz ve
response içinde geri döndürmez. Mobil uygulamada gerçek servis anahtarı kesinlikle
bulundurulmamalıdır. Gerçek AI entegrasyonu yalnızca backend'de yapılacaktır.

Gelecekte gerçek sağlayıcı bağlanmadan önce EXIF metadata'nın upload öncesinde
silinmesi değerlendirilmelidir. Bu aşamada OpenAI çağrısı, OpenAI paketi veya API
anahtarı yoktur.
