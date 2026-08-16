import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'AI Food Analyzer'**
  String get appName;

  /// Tooltip for choosing app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// Turkish language option
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkishLanguage;

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

  /// Shown when the backend detects no food
  ///
  /// In en, this message translates to:
  /// **'No food could be detected in this image. Try another photo.'**
  String get noFoodDetected;

  /// Shown for an invalid image upload
  ///
  /// In en, this message translates to:
  /// **'This image is not supported. Choose a JPG, PNG, or WebP photo.'**
  String get invalidImage;

  /// Shown when an image exceeds the upload limit
  ///
  /// In en, this message translates to:
  /// **'This image is too large. Choose a photo under 8 MB.'**
  String get imageTooLarge;

  /// Shown when the backend rate limits requests
  ///
  /// In en, this message translates to:
  /// **'Too many analyses were requested. Please wait and try again.'**
  String get rateLimited;

  /// Shown when an analysis request times out
  ///
  /// In en, this message translates to:
  /// **'The analysis took too long. Check your connection and try again.'**
  String get analysisTimeout;

  /// Shown for network connection failures
  ///
  /// In en, this message translates to:
  /// **'The analysis service could not be reached. Check your connection and try again.'**
  String get networkError;

  /// Shown when the backend service is unavailable
  ///
  /// In en, this message translates to:
  /// **'The analysis service is temporarily unavailable. Please try again.'**
  String get serviceUnavailable;

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

  /// Sugar nutrient label
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugarLabel;

  /// Sodium nutrient label
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodiumLabel;

  /// Formatted nutrient amount in milligrams
  ///
  /// In en, this message translates to:
  /// **'{milligrams} mg'**
  String milligramValue(int milligrams);

  /// Estimated meal health score label
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get healthScoreLabel;

  /// Formatted health score
  ///
  /// In en, this message translates to:
  /// **'{score}/100'**
  String healthScoreValue(int score);

  /// Estimated serving weight label
  ///
  /// In en, this message translates to:
  /// **'Estimated serving weight'**
  String get servingWeightLabel;

  /// Detected food components section title
  ///
  /// In en, this message translates to:
  /// **'Detected foods'**
  String get detectedFoodsTitle;

  /// Detected food component nutrition summary
  ///
  /// In en, this message translates to:
  /// **'{weight} g · {calories} kcal · %{confidence}'**
  String foodComponentSummary(int weight, int calories, int confidence);

  /// Analysis warnings section title
  ///
  /// In en, this message translates to:
  /// **'Things to consider'**
  String get warningsTitle;

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

  /// Loading label while an analysis is saved
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingResult;

  /// Disabled action label after an analysis has been saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Confirmation shown after saving an analysis
  ///
  /// In en, this message translates to:
  /// **'Analysis saved'**
  String get analysisSaved;

  /// Error shown when an analysis cannot be saved
  ///
  /// In en, this message translates to:
  /// **'The analysis could not be saved. Please try again.'**
  String get saveAnalysisFailed;

  /// Saved food analyses screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// Title shown when analysis history is empty
  ///
  /// In en, this message translates to:
  /// **'No saved analyses yet'**
  String get emptyHistoryTitle;

  /// Description shown when analysis history is empty
  ///
  /// In en, this message translates to:
  /// **'Your saved meal analyses will appear here.'**
  String get emptyHistoryDescription;

  /// Error shown when history cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Your saved analyses could not be loaded.'**
  String get historyLoadFailed;

  /// Error shown when deleting or clearing history fails
  ///
  /// In en, this message translates to:
  /// **'The history action could not be completed.'**
  String get historyActionFailed;

  /// Title of the delete analysis confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete analysis?'**
  String get deleteAnalysisTitle;

  /// Message in the delete analysis confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This analysis and its saved photo will be permanently deleted.'**
  String get deleteAnalysisMessage;

  /// Tooltip for clearing all history
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// Title of the clear history confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get clearHistoryTitle;

  /// Message in the clear history confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'All saved analyses and their photos will be permanently deleted.'**
  String get clearHistoryMessage;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic clear action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Tooltip for opening a record action menu
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// Message shown when a saved analysis no longer exists
  ///
  /// In en, this message translates to:
  /// **'This saved analysis could not be found.'**
  String get analysisNotFound;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
