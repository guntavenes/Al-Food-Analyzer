// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AI Food Analyzer';

  @override
  String get homeTitle => 'Take a photo of\nyour meal';

  @override
  String get homeDescription =>
      'Get instant insights into calories, nutrients, and ingredients with one simple photo.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get aiPowered => 'AI-POWERED NUTRITION';

  @override
  String get cameraTitle => 'Frame your meal';

  @override
  String get cameraHint => 'Keep the whole plate inside the frame';

  @override
  String get cameraUnavailable => 'Camera is unavailable';

  @override
  String get cameraPermissionHint =>
      'Allow camera access in Settings, then try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get previewTitle => 'Your meal';

  @override
  String get previewReady => 'Photo ready';

  @override
  String get analyzeFood => 'Analyze Food';

  @override
  String get analyzingFood => 'Analyzing...';

  @override
  String get analysisFailed =>
      'Analysis could not be completed. Please try again.';

  @override
  String get resultTitle => 'Food Analysis';

  @override
  String get estimatedCalories => 'ESTIMATED CALORIES';

  @override
  String calorieValue(int calories) {
    return '$calories kcal';
  }

  @override
  String gramValue(int grams) {
    return '$grams g';
  }

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Carbs';

  @override
  String get fatLabel => 'Fat';

  @override
  String get fiberLabel => 'Fiber';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String confidenceValue(int confidence) {
    return '%$confidence';
  }

  @override
  String get analysisDisclaimer =>
      'This result is an AI-powered estimate and should not replace professional nutritional advice.';

  @override
  String get analyzeAnotherMeal => 'Analyze Another Meal';

  @override
  String get saveResult => 'Save Result';

  @override
  String get savingResult => 'Saving...';

  @override
  String get saved => 'Saved';

  @override
  String get analysisSaved => 'Analysis saved';

  @override
  String get saveAnalysisFailed =>
      'The analysis could not be saved. Please try again.';

  @override
  String get historyTitle => 'History';

  @override
  String get emptyHistoryTitle => 'No saved analyses yet';

  @override
  String get emptyHistoryDescription =>
      'Your saved meal analyses will appear here.';

  @override
  String get historyLoadFailed => 'Your saved analyses could not be loaded.';

  @override
  String get historyActionFailed =>
      'The history action could not be completed.';

  @override
  String get deleteAnalysisTitle => 'Delete analysis?';

  @override
  String get deleteAnalysisMessage =>
      'This analysis and its saved photo will be permanently deleted.';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryTitle => 'Clear all history?';

  @override
  String get clearHistoryMessage =>
      'All saved analyses and their photos will be permanently deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get clear => 'Clear';

  @override
  String get moreActions => 'More actions';

  @override
  String get analysisNotFound => 'This saved analysis could not be found.';
}
