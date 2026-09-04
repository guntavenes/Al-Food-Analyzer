# AI Food Analyzer

Flutter istemcisi, Drift tabanlı yerel geçmiş ve TypeScript/Express analiz
backend'inden oluşan geliştirme projesi. Backend mock veya OpenAI sağlayıcısıyla çalışabilir.

## Mimari

- Flutter: feature-first clean architecture, Riverpod, GoRouter, Dio ve Drift
- Backend: Express, TypeScript, Zod, Multer ve değiştirilebilir `FoodAnalysisProvider`
- Supabase anonim oturumlarıyla her cihaz için doğrulanmış kullanıcı kimliği
- Mobil uygulamada OpenAI veya Supabase sunucu anahtarı bulunmaz

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

Gerçek analiz yalnızca backend'de etkinleştirilir. Model adı bilinçli olarak
varsayılan içermez; hesabınızda görsel girdi ve Structured Outputs destekleyen
modeli açıkça seçin:

```dotenv
FOOD_ANALYSIS_PROVIDER=openai
OPENAI_API_KEY=your_server_side_key
OPENAI_MODEL=gpt-5.6-luna
OPENAI_TIMEOUT_MS=30000
OPENAI_MAX_RETRIES=1
OPENAI_REASONING_EFFORT=low
OPENAI_IMAGE_DETAIL=low
```

Production yapılandırması fiyat/performans dengesi için `gpt-5.6-luna` ve düşük
reasoning kullanır. Düz `gpt-5.6` alias'ı daha pahalı Sol modeline yönlendiğinden
bilinçli olarak kullanılmaz. Anahtar veya model eksikse OpenAI modu başlamaz. `mock` modu API anahtarı olmadan
çalışmaya devam eder. `low` image detail maliyeti düşürür ancak küçük içeriklerin
ve porsiyon ipuçlarının doğruluğunu azaltabilir; `high` daha fazla token ve maliyet
oluşturabilir. Kullanım ve fiyatlandırmayı seçilen model için ayrıca izleyin.

### Supabase kimlik doğrulaması

Production backend, kalıcı Supabase kullanıcı hesabının JWT'sini doğrular; anonim
oturumlar analiz yapamaz. Kullanıcı başına ilk başarılı analiz ücretsizdir. Hak,
`claim_analysis_entitlement` veritabanı fonksiyonuyla atomik biçimde tüketilir;
eşzamanlı istekler ek hak oluşturamaz. AI çağrısı başarısız olursa rezervasyon geri
alınır. Sonraki istekler aktif Premium hakkı yoksa `PREMIUM_REQUIRED` döndürür.
Mobil istemcinin kullanım ve entitlement tablolarına doğrudan erişimi yoktur.

Backend `.env` değerleri:

```dotenv
AUTH_REQUIRED=true
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_SERVER_KEY_V2=your_server_only_secret_key
ANALYSIS_RATE_LIMIT_WINDOW_MS=3600000
ANALYSIS_RATE_LIMIT_MAX_REQUESTS=10
```

`SUPABASE_SERVER_KEY_V2` yalnızca backend/Render ortamında tutulmalıdır; Flutter'a,
Git'e veya istemci tarafı yapılandırmaya eklenmemelidir. Veritabanı şeması
[`supabase/migrations`](supabase/migrations) altındaki migration ile kurulur.

## Flutter uygulamasını çalıştırma

```bash
flutter pub get
flutter gen-l10n
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your_publishable_key
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
  - `Authorization: Bearer <Supabase access token>` (production'da zorunlu)
  - JPG, PNG ve WebP; en fazla 8 MB

## Gizlilik ve güvenlik

Seçilen fotoğraf analiz amacıyla backend'e gönderilir. Backend görseli yalnızca
request belleğinde tutar; diske kaydetmez, loglamaz ve response içinde geri
döndürmez. OpenAI modu seçildiğinde görsel analiz için OpenAI API'ye aktarılır ve
sağlayıcının veri saklama/işleme koşulları ayrıca değerlendirilmelidir. Mobil
uygulamada gerçek servis anahtarı kesinlikle bulundurulmamalıdır.

Production öncesinde EXIF metadata'nın upload öncesinde silinmesi, kullanıcı
onayı, veri bölgesi ve saklama politikaları değerlendirilmelidir.

Uygulama e-posta ve şifreyle kalıcı hesap oluşturur. Böylece uygulamayı silip tekrar
yüklemek ücretsiz hakkı yenilemez. Production yayını öncesinde Supabase Auth için
CAPTCHA/Turnstile, parola sıfırlama akışı ve mağaza tarafında App Attest / Play
Integrity değerlendirilmelidir.

## App Store Premium abonelikleri

iOS Premium ekranı fiyatları doğrudan App Store'dan yükler, satın alma ve
`Restore Purchases` akışlarını StoreKit 2 üzerinden yürütür. Tanımlı ürünler:

- Aylık: `com.enesguntav.aifood.premium.monthly` — Türkiye için ₺49,99
- Yıllık: `com.enesguntav.aifood.premium.yearly` — Türkiye için ₺399,99

Mobil uygulama Apple'ın imzaladığı işlem verisini Supabase oturumuyla birlikte
`POST /v1/subscriptions/apple/verify` endpoint'ine gönderir. Backend JWS imzasını,
bundle ID'yi, App Store uygulama ID'sini, ürün kimliğini, kullanıcıya bağlanan
`appAccountToken` değerini, iptal ve bitiş tarihini doğruladıktan sonra Premium
hakkını Supabase'e yazar. Satın alma doğrulanmadan istemcide Premium açılmaz.

Önce [`supabase/migrations`](supabase/migrations) içindeki güncel migration'ları
Supabase projesine uygulayın. Ardından Render'a şu değişkenleri ekleyin:

```dotenv
APPLE_IAP_ENABLED=false
APPLE_BUNDLE_ID=com.enesguntav.aiFoodAnalyzer
APPLE_APP_ID=6806656867
APPLE_ROOT_CA_BASE64=comma_separated_base64_der_apple_root_certificates
```

Apple Root CA sertifikalarını [Apple Certificate Authority](https://www.apple.com/certificateauthority/)
sayfasından alın. DER içeriklerini base64'e çevirip virgülle ayırın. Sertifikalar
ve migration hazır olmadan `APPLE_IAP_ENABLED=true` yapmayın; eksik sertifikayla
backend bilinçli olarak başlamaz. Hazır olduğunda değeri `true` yapıp Render'ı
yeniden deploy edin.

Sandbox testi gerçek cihazda veya TestFlight build'inde Sandbox Apple hesabıyla
yapılmalıdır. Başarılı testte aylık/yıllık ürünler yerel App Store fiyatıyla
görünmeli, satın alma backend tarafından doğrulanmalı, ikinci analiz açılmalı ve
`Restore Purchases` aynı Supabase hesabında Premium erişimi geri getirmelidir.
StoreKit 2, sunucu doğrulamasına uygun JWS işlem verisini kullanır; StoreKit 1'e
geri dönüş bu entegrasyonda desteklenmez.

İlk abonelikler uygulamanın yeni sürümüyle birlikte App Review'a gönderilmelidir.
App Store Connect'te her iki ürün için review screenshot ve eksik metadata
tamamlanmadan incelemeye gönderilmemelidir. Google Play Billing bu aşamanın
kapsamında değildir.

## AI davranış sözleşmesi

OpenAI sağlayıcısı, backend'deki Zod şemasından üretilen strict Structured Output
ile JSON üretir ve sonuç tekrar aynı Zod sözleşmesiyle doğrulanır. Sistem davranışı [system prompt](backend/prompts/food-analysis-system-prompt.md)
ve [örnekler](backend/prompts/food-analysis-examples.md) ile tanımlanmıştır.

- Yalnızca görsel tarafından desteklenen yemekleri raporlar; belirsiz bilgiyi uydurmaz.
- Porsiyon ve gram değerlerini görünür ölçek ipuçlarına göre tahmin eder.
- Belirsizlik arttıkça confidence değerini düşürür ve warnings alanını kullanır.
- Birden fazla yemeği `detectedFoods` içinde ayrı ayrı raporlar.
- Yemek yoksa `isFoodDetected=false` ve besin alanlarında `null` döndürür.
- Sonuçların tahmin olduğunu ve içerik/porsiyona göre değişebileceğini açıklar.
- Gerçek sağlayıcı response'u endpoint'e ulaşmadan önce Zod ile doğrulanır.

Görsel içindeki metinler güvenilmeyen içerik sayılır ve talimat olarak uygulanmaz.
Refusal, timeout, rate limit, yetkilendirme ve şema hataları mevcut güvenli endpoint
hata sözleşmesine çevrilir. Loglar fotoğraf, base64, prompt, API anahtarı veya ham
sağlayıcı cevabı içermez.
