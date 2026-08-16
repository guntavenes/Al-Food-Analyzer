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
  String get resultTitle => 'Yemek Analizi';

  @override
  String get estimatedCalories => 'TAHMİNİ KALORİ';

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
}
