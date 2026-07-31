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
}
