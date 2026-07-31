import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'AI Food Analyzer'**
  String get appName;

  /// Main call to action on the home screen
  ///
  /// In en, this message translates to:
  /// **'Take a photo of\nyour meal'**
  String get homeTitle;

  /// Explains the value of photographing a meal
  ///
  /// In en, this message translates to:
  /// **'Get instant insights into calories, nutrients, and ingredients with one simple photo.'**
  String get homeDescription;

  /// Primary camera button label
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// Secondary gallery button label
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// Small premium feature label
  ///
  /// In en, this message translates to:
  /// **'AI-POWERED NUTRITION'**
  String get aiPowered;

  /// Camera screen title
  ///
  /// In en, this message translates to:
  /// **'Frame your meal'**
  String get cameraTitle;

  /// Camera composition guidance
  ///
  /// In en, this message translates to:
  /// **'Keep the whole plate inside the frame'**
  String get cameraHint;

  /// Shown when camera initialization fails
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable'**
  String get cameraUnavailable;

  /// Guidance shown after camera permission failure
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in Settings, then try again.'**
  String get cameraPermissionHint;

  /// Retry action label
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Selected photo preview screen title
  ///
  /// In en, this message translates to:
  /// **'Your meal'**
  String get previewTitle;

  /// Confirms that a photo was selected
  ///
  /// In en, this message translates to:
  /// **'Photo ready'**
  String get previewReady;

  /// Primary action on the meal photo preview
  ///
  /// In en, this message translates to:
  /// **'Analyze Food'**
  String get analyzeFood;

  /// Loading label while the meal photo is analyzed
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzingFood;

  /// Error shown when food analysis fails
  ///
  /// In en, this message translates to:
  /// **'Analysis could not be completed. Please try again.'**
  String get analysisFailed;

  /// Food analysis result screen title
  ///
  /// In en, this message translates to:
  /// **'Food Analysis'**
  String get resultTitle;

  /// Label above the prominent calorie value
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED CALORIES'**
  String get estimatedCalories;

  /// Formatted calorie result
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String calorieValue(int calories);

  /// Formatted nutrient amount in grams
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String gramValue(int grams);

  /// Protein nutrient label
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get proteinLabel;

  /// Carbohydrate nutrient label
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbsLabel;

  /// Fat nutrient label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fatLabel;

  /// Fiber nutrient label
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiberLabel;

  /// Analysis confidence label
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// Formatted confidence percentage
  ///
  /// In en, this message translates to:
  /// **'%{confidence}'**
  String confidenceValue(int confidence);

  /// Clarifies that the nutrition result is an estimate
  ///
  /// In en, this message translates to:
  /// **'This result is an AI-powered estimate and should not replace professional nutritional advice.'**
  String get analysisDisclaimer;

  /// Returns to the home screen to analyze another meal
  ///
  /// In en, this message translates to:
  /// **'Analyze Another Meal'**
  String get analyzeAnotherMeal;

  /// Placeholder action for saving the analysis result
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get saveResult;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
