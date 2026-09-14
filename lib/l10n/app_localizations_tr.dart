// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'AI Yemek Analizörü';

  @override
  String get languageTitle => 'Dil';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get orContinueWithEmail => 'veya e-posta ile';

  @override
  String get skip => 'Atla';

  @override
  String get next => 'İleri';

  @override
  String get getStarted => 'Başlayalım';

  @override
  String get onboardingScanTitle => 'Yemeğini saniyeler içinde analiz et';

  @override
  String get onboardingScanDescription =>
      'Fotoğraf çek veya galeriden seç; yapay zekâ besin ve kalori bilgilerini senin için hazırlasın.';

  @override
  String get onboardingHistoryTitle => 'Analizlerin Geçmiş\'te saklanır';

  @override
  String get onboardingHistoryDescription =>
      'Sağ üstteki geçmiş simgesinden kaydettiğin öğünlere istediğin zaman yeniden ulaşabilirsin.';

  @override
  String get onboardingPersonalizeTitle => 'Dilini ve hesabını yönet';

  @override
  String get onboardingPersonalizeDescription =>
      'Sağ üstteki dil simgesinden Türkçe veya İngilizceyi seç; hesap alanından Premium ve üyelik bilgilerine ulaş.';

  @override
  String get showAppTour => 'Uygulama turunu göster';

  @override
  String freeAnalysesRemaining(int count) {
    return 'Kalan ücretsiz analiz: $count';
  }

  @override
  String get englishLanguage => 'English';

  @override
  String get turkishLanguage => 'Türkçe';

  @override
  String get homeTitle => 'Yemeğinin\nfotoğrafını çek';

  @override
  String get homeDescription =>
      'Tek bir fotoğrafla kalori, besin değerleri ve içerikler hakkında anında bilgi al.';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get chooseFromGallery => 'Galeriden seç';

  @override
  String get aiPowered => 'YAPAY ZEKA DESTEKLİ BESLENME';

  @override
  String get cameraTitle => 'Yemeğini kadraja al';

  @override
  String get cameraHint => 'Tabağın tamamını kadrajın içinde tut';

  @override
  String get cameraUnavailable => 'Kamera kullanılamıyor';

  @override
  String get cameraPermissionHint =>
      'Ayarlar\'dan kamera erişimine izin verip tekrar dene.';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get previewTitle => 'Yemeğin';

  @override
  String get previewReady => 'Fotoğraf hazır';

  @override
  String get analyzeFood => 'Yemeği Analiz Et';

  @override
  String get analyzingFood => 'Analiz ediliyor...';

  @override
  String get analysisFailed => 'Analiz tamamlanamadı. Lütfen tekrar dene.';

  @override
  String get noFoodDetected =>
      'Bu görselde yemek algılanamadı. Başka bir fotoğraf dene.';

  @override
  String get invalidImage =>
      'Bu görsel desteklenmiyor. JPG, PNG veya WebP fotoğraf seç.';

  @override
  String get imageTooLarge =>
      'Bu görsel çok büyük. 8 MB\'tan küçük bir fotoğraf seç.';

  @override
  String get rateLimited =>
      'Çok fazla analiz istendi. Biraz bekleyip tekrar dene.';

  @override
  String get authenticationRequired =>
      'Güvenli oturumun doğrulanamadı. Lütfen tekrar dene.';

  @override
  String get analysisTimeout =>
      'Analiz çok uzun sürdü. Bağlantını kontrol edip tekrar dene.';

  @override
  String get networkError =>
      'Analiz servisine ulaşılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get serviceUnavailable =>
      'Analiz servisi geçici olarak kullanılamıyor. Lütfen tekrar dene.';

  @override
  String get premiumRequired =>
      'Ücretsiz analiz hakkını kullandın. Devam etmek için Premium gerekli.';

  @override
  String get signInTitle => 'Tekrar hoş geldin';

  @override
  String get createAccountTitle => 'Hesabını oluştur';

  @override
  String get authDescription =>
      'Hesabın, ücretsiz analiz hakkını ve gelecekteki Premium erişimini uygulamayı yeniden yüklesen bile güvenle korur.';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get createAccount => 'Hesap oluştur';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get createAccountInstead => 'Yeni misin? Hesap oluştur';

  @override
  String get authValidationMessage =>
      'Geçerli bir e-posta ve en az 8 karakterli bir şifre gir.';

  @override
  String get invalidEmailMessage =>
      'Geçerli bir e-posta adresi gir. Örnek: ad@outlook.com.';

  @override
  String get passwordTooShortMessage => 'Şifren en az 8 karakter olmalı.';

  @override
  String get emailAlreadyRegisteredMessage =>
      'Bu e-posta ile zaten bir hesap var. Giriş yapmayı dene.';

  @override
  String get invalidLoginMessage => 'E-posta veya şifre hatalı.';

  @override
  String get authGenericErrorMessage =>
      'İşlem tamamlanamadı. Lütfen tekrar dene.';

  @override
  String get checkEmailMessage =>
      'Doğrulama e-postası gönderildi. Gelen kutunu ve spam klasörünü kontrol et, ardından giriş yap.';

  @override
  String get resendConfirmation => 'Doğrulama e-postasını yeniden gönder';

  @override
  String resendConfirmationCountdown(int seconds) {
    return 'Tekrar gönder ($seconds sn)';
  }

  @override
  String get confirmationResent =>
      'Yeni doğrulama e-postası gönderildi. Gelen kutunda göremezsen spam klasörünü kontrol et.';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String get forgotPasswordTitle => 'Şifreni yenile';

  @override
  String get forgotPasswordDescription =>
      'Hesabına ait e-posta adresini gir. Yeni şifre oluşturman için güvenli bir bağlantı göndereceğiz.';

  @override
  String get sendResetLink => 'Sıfırlama bağlantısı gönder';

  @override
  String get resetLinkSent =>
      'Şifre sıfırlama e-postası gönderildi. Bağlantıyı bu cihazda aç.';

  @override
  String get emailRateLimitedMessage =>
      'Çok fazla e-posta istendi. Bir süre bekleyip tekrar dene.';

  @override
  String get backToSignIn => 'Giriş ekranına dön';

  @override
  String get newPasswordTitle => 'Yeni şifre oluştur';

  @override
  String get newPasswordDescription =>
      'En az 8 karakterden oluşan güvenli bir şifre belirle.';

  @override
  String get newPasswordLabel => 'Yeni şifre';

  @override
  String get confirmPasswordLabel => 'Yeni şifreyi doğrula';

  @override
  String get passwordsDoNotMatch => 'Şifreler birbiriyle eşleşmiyor.';

  @override
  String get updatePassword => 'Şifreyi güncelle';

  @override
  String get passwordUpdated => 'Şifren başarıyla güncellendi.';

  @override
  String get accountTitle => 'Hesap';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get signOutTitle => 'Çıkış yapılsın mı?';

  @override
  String get signOutDescription =>
      'Giriş ekranına döneceksin. Hesabın ve analiz kullanım hakkın güvenle korunmaya devam edecek.';

  @override
  String get signOutFailed => 'Çıkış yapılamadı. Lütfen tekrar dene.';

  @override
  String get premiumMember => 'Premium üye';

  @override
  String get freeMember => 'Ücretsiz plan';

  @override
  String get managePremium => 'Premium\'u yönet';

  @override
  String get upgradeToPremium => 'Premium\'a geç';

  @override
  String get premiumTitle => 'Premium\'u aç';

  @override
  String get premiumDescription =>
      'Ücretsiz analiz hakkını kullandın. Tabağındakileri keşfetmeye Premium ile devam et.';

  @override
  String get premiumBenefitAnalysis => 'Yemeklerini analiz etmeye devam et';

  @override
  String get premiumBenefitHistory => 'Kişisel yemek geçmişini koru';

  @override
  String get premiumBenefitNutrition => 'Detaylı besin değeri tahminleri';

  @override
  String get premiumComingSoon => 'Premium satın alma yakında';

  @override
  String get purchaseNotAvailable =>
      'App Store ve Google Play ürünleri yapılandırıldıktan sonra satın alma etkinleştirilecek.';

  @override
  String get premiumMonthlyPlan => 'Aylık Premium';

  @override
  String get premiumYearlyPlan => 'Yıllık Premium';

  @override
  String get premiumBestValue => 'EN AVANTAJLI';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get restorePurchasesDescription =>
      'Bu Apple hesabıyla daha önce abone oldun mu? Yeniden ücret ödemeden erişimini geri yükle.';

  @override
  String get manageSubscription => 'Aboneliği yönet veya iptal et';

  @override
  String get premiumPurchaseSuccess => 'Premium etkin';

  @override
  String get premiumRenewalDisclosure =>
      'Abonelikler, mevcut dönemin bitiminden en az 24 saat önce iptal edilmezse otomatik yenilenir. App Store hesabından yönetebilir veya iptal edebilirsin.';

  @override
  String get resultTitle => 'Yemek Analizi';

  @override
  String get estimatedCalories => 'TAHMİNİ KALORİ';

  @override
  String get nutritionSummaryTitle => 'Besin değerleri';

  @override
  String calorieValue(int calories) {
    return '$calories kcal';
  }

  @override
  String calorieRangeValue(int minimum, int maximum) {
    return '$minimum–$maximum kcal';
  }

  @override
  String centralCalorieEstimate(int calories) {
    return 'Orta tahmin: $calories kcal';
  }

  @override
  String get confirmIngredientsTitle => 'İçeriği doğrula';

  @override
  String get confirmIngredientsMessage =>
      'Görselde benzer görünen malzemeler olabilir. Ana malzemeler ve porsiyon doğru mu?';

  @override
  String get editAndReanalyze => 'Düzenle ve tekrar analiz et';

  @override
  String get reanalysisCostNotice =>
      'Tekrar analiz yeni bir kullanım hakkı harcar.';

  @override
  String get correctionSheetTitle => 'Yemek bilgisini düzelt';

  @override
  String get correctionSheetDescription =>
      'Bildiğin malzemeleri ve görünen toplam porsiyonu yaz. AI bu bilgileri fotoğrafla birlikte yeniden değerlendirecek.';

  @override
  String get mainIngredientsLabel => 'Ana malzemeler';

  @override
  String get mainIngredientsHint => 'Örn. dana kıyma, ekmek, domates salsa';

  @override
  String get servingCorrectionLabel => 'Toplam porsiyon';

  @override
  String get servingCorrectionHint => 'Örn. 6 adet ve 1 küçük kase sos';

  @override
  String get recalculateAnalysis => 'Tekrar Hesapla';

  @override
  String gramValue(int grams) {
    return '$grams g';
  }

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Karbonhidrat';

  @override
  String get fatLabel => 'Yağ';

  @override
  String get fiberLabel => 'Lif';

  @override
  String get sugarLabel => 'Şeker';

  @override
  String get sodiumLabel => 'Sodyum';

  @override
  String milligramValue(int milligrams) {
    return '$milligrams mg';
  }

  @override
  String get healthScoreLabel => 'Sağlık puanı';

  @override
  String healthScoreValue(int score) {
    return '$score/100';
  }

  @override
  String get servingWeightLabel => 'Tahmini porsiyon ağırlığı';

  @override
  String get detectedFoodsTitle => 'Algılanan yiyecekler';

  @override
  String foodComponentSummary(int weight, int calories, int confidence) {
    return '$weight g · $calories kcal · %$confidence';
  }

  @override
  String get warningsTitle => 'Dikkat edilmesi gerekenler';

  @override
  String get confidenceLabel => 'Güven';

  @override
  String confidenceValue(int confidence) {
    return '%$confidence';
  }

  @override
  String get analysisDisclaimer =>
      'Bu sonuç yapay zeka destekli bir tahmindir ve profesyonel beslenme tavsiyesinin yerini tutmaz.';

  @override
  String get analyzeAnotherMeal => 'Başka Bir Yemek Analiz Et';

  @override
  String get saveResult => 'Sonucu Kaydet';

  @override
  String get savingResult => 'Kaydediliyor...';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get analysisSaved => 'Analiz kaydedildi';

  @override
  String get saveAnalysisFailed => 'Analiz kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get emptyHistoryTitle => 'Henüz kayıtlı analiz yok';

  @override
  String get emptyHistoryDescription =>
      'Kaydettiğin yemek analizleri burada görünecek.';

  @override
  String get historyLoadFailed => 'Kayıtlı analizlerin yüklenemedi.';

  @override
  String get historyActionFailed => 'Geçmiş işlemi tamamlanamadı.';

  @override
  String get deleteAnalysisTitle => 'Analiz silinsin mi?';

  @override
  String get deleteAnalysisMessage =>
      'Bu analiz ve kayıtlı fotoğrafı kalıcı olarak silinecek.';

  @override
  String get clearHistory => 'Geçmişi temizle';

  @override
  String get clearHistoryTitle => 'Tüm geçmiş temizlensin mi?';

  @override
  String get clearHistoryMessage =>
      'Tüm kayıtlı analizler ve fotoğrafları kalıcı olarak silinecek.';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get clear => 'Temizle';

  @override
  String get moreActions => 'Daha fazla işlem';

  @override
  String get analysisNotFound => 'Bu kayıtlı analiz bulunamadı.';

  @override
  String get chooseFeatureTitle => 'Nasıl yardımcı olalım?';

  @override
  String get chooseFeatureDescription =>
      'Yemeğini analiz et veya menüdeki seçenekler arasından daha dengeli olanı bul.';

  @override
  String get scanFoodTitle => 'Besin Tara';

  @override
  String get scanFoodDescription =>
      'Tabağının kalori ve besin değerlerini öğren.';

  @override
  String get scanFoodSourceDescription =>
      'Yemeğinin tamamı görünecek şekilde bir fotoğraf çek veya galeriden seç.';

  @override
  String get scanBarcode => 'Barkoddan tara';

  @override
  String get barcodeScanDescription =>
      'Ürün barkodunu çerçevenin içine getir. Bulunduğunda birebir besin değerlerini göstereceğiz.';

  @override
  String get findingProduct => 'Ürün bulunuyor...';

  @override
  String get barcodeProductNotFound =>
      'Bu barkodu bulamadık. Tekrar tarayabilir veya ürünü fotoğrafla analiz edebilirsin.';

  @override
  String get barcodeLookupFailed =>
      'Ürün bilgisine şu anda ulaşılamıyor. Lütfen tekrar dene.';

  @override
  String get verifiedProduct => 'BARKOD EŞLEŞTİ';

  @override
  String get consumedAmount => 'Tüketilen miktar';

  @override
  String caloriesForAmount(int grams) {
    return '$grams g için kalori';
  }

  @override
  String dataSource(String source) {
    return 'Kaynak: $source';
  }

  @override
  String get scanAnotherBarcode => 'Başka barkod tara';

  @override
  String get enterBarcodeManually => 'Barkodu elle gir';

  @override
  String get enterBarcode => 'Barkod numarasını gir';

  @override
  String get barcodeHint => '8–14 haneli barkod';

  @override
  String get searchProduct => 'Ürünü bul';

  @override
  String get emailUnavailable => 'E-posta bilgisi yüklenemedi';

  @override
  String get menuScanTitle => 'Menüden Seç';

  @override
  String get menuScanDescription =>
      'Menüyü tara, daha hafif ve dengeli seçenekleri karşılaştır.';

  @override
  String get menuScanIntroDescription =>
      'Menünün net bir fotoğrafını çek. Okunabilen yemekleri kalori, içerik ve denge açısından karşılaştıracağız.';

  @override
  String get menuScanComingSoon => 'Menü analizi hazırlanıyor';

  @override
  String get menuScanHeroTitle => 'Menüdeki en iyi seçeneği bul';

  @override
  String get menuPhotoSheetTitle => 'Menüyü nasıl eklemek istersin?';

  @override
  String get menuPhotoSheetDescription =>
      'Yemek adları ve açıklamaları net ve mümkünse tek karede görünsün.';

  @override
  String get scanMenuAction => 'Menüyü Tara';

  @override
  String get scanAnotherMenu => 'Başka Bir Menü Tara';

  @override
  String get analyzingMenu => 'Menü inceleniyor...';

  @override
  String get analyzingMenuDescription =>
      'Seçenekleri kalori ve besin dengesi açısından karşılaştırıyoruz.';

  @override
  String get menuAnalysisFailed =>
      'Menü analiz edilemedi. Yazıların net göründüğü bir fotoğrafla tekrar dene.';

  @override
  String get bestMenuChoice => 'En dengeli seçim';

  @override
  String get otherMenuOptions => 'Diğer seçenekler';

  @override
  String get menuEstimateDisclaimer =>
      'Kalori ve sağlık puanları menü açıklamalarına dayalı tahminlerdir; gerçek içerik ve porsiyona göre değişebilir.';
}
