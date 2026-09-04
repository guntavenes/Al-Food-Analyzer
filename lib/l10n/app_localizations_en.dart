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
  String get languageTitle => 'Language';

  @override
  String get englishLanguage => 'English';

  @override
  String get turkishLanguage => 'Türkçe';

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
  String get noFoodDetected =>
      'No food could be detected in this image. Try another photo.';

  @override
  String get invalidImage =>
      'This image is not supported. Choose a JPG, PNG, or WebP photo.';

  @override
  String get imageTooLarge =>
      'This image is too large. Choose a photo under 8 MB.';

  @override
  String get rateLimited =>
      'Too many analyses were requested. Please wait and try again.';

  @override
  String get authenticationRequired =>
      'Your secure session could not be verified. Please try again.';

  @override
  String get analysisTimeout =>
      'The analysis took too long. Check your connection and try again.';

  @override
  String get networkError =>
      'The analysis service could not be reached. Check your connection and try again.';

  @override
  String get serviceUnavailable =>
      'The analysis service is temporarily unavailable. Please try again.';

  @override
  String get premiumRequired =>
      'Your free analysis has been used. Premium is required to continue.';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get authDescription =>
      'Your account securely keeps your free analysis and future Premium access across reinstallations.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get createAccountInstead => 'New here? Create an account';

  @override
  String get authValidationMessage =>
      'Enter a valid email and a password of at least 8 characters.';

  @override
  String get checkEmailMessage =>
      'Check your email to confirm your account, then sign in.';

  @override
  String get resendConfirmation => 'Send confirmation email again';

  @override
  String get confirmationResent => 'A new confirmation email was sent.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordDescription =>
      'Enter your account email. We will send a secure link to create a new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent =>
      'Password reset email sent. Open the link on this device.';

  @override
  String get emailRateLimitedMessage =>
      'Too many emails were requested. Please wait a while before trying again.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get newPasswordTitle => 'Create a new password';

  @override
  String get newPasswordDescription =>
      'Choose a secure password with at least 8 characters.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get updatePassword => 'Update password';

  @override
  String get passwordUpdated => 'Your password was updated successfully.';

  @override
  String get accountTitle => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutDescription =>
      'You will return to the sign-in screen. Your saved account and analysis entitlement will remain secure.';

  @override
  String get signOutFailed => 'Could not sign out. Please try again.';

  @override
  String get premiumTitle => 'Unlock Premium';

  @override
  String get premiumDescription =>
      'Your complimentary analysis has been used. Continue discovering what is on your plate with Premium.';

  @override
  String get premiumBenefitAnalysis => 'Continue analyzing meals';

  @override
  String get premiumBenefitHistory => 'Keep your personal meal history';

  @override
  String get premiumBenefitNutrition => 'Detailed nutrition estimates';

  @override
  String get premiumComingSoon => 'Premium purchasing coming soon';

  @override
  String get purchaseNotAvailable =>
      'Purchasing will be enabled after App Store and Google Play products are configured.';

  @override
  String get premiumMonthlyPlan => 'Monthly Premium';

  @override
  String get premiumYearlyPlan => 'Yearly Premium';

  @override
  String get premiumBestValue => 'BEST VALUE';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get premiumPurchaseSuccess => 'Premium is active';

  @override
  String get premiumRenewalDisclosure =>
      'Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. You can manage or cancel them in your App Store account.';

  @override
  String get resultTitle => 'Food Analysis';

  @override
  String get estimatedCalories => 'ESTIMATED CALORIES';

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
    return 'Central estimate: $calories kcal';
  }

  @override
  String get confirmIngredientsTitle => 'Confirm the ingredients';

  @override
  String get confirmIngredientsMessage =>
      'Some ingredients can look alike in a photo. Are the main ingredients and portion correct?';

  @override
  String get editAndReanalyze => 'Edit and analyze again';

  @override
  String get reanalysisCostNotice =>
      'Analyzing again uses another analysis credit.';

  @override
  String get correctionSheetTitle => 'Correct meal details';

  @override
  String get correctionSheetDescription =>
      'Enter the ingredients you know and the total visible serving. AI will evaluate them with the photo again.';

  @override
  String get mainIngredientsLabel => 'Main ingredients';

  @override
  String get mainIngredientsHint =>
      'For example: ground beef, bread, tomato salsa';

  @override
  String get servingCorrectionLabel => 'Total serving';

  @override
  String get servingCorrectionHint =>
      'For example: 6 pieces and 1 small bowl of sauce';

  @override
  String get recalculateAnalysis => 'Recalculate';

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
  String get sugarLabel => 'Sugar';

  @override
  String get sodiumLabel => 'Sodium';

  @override
  String milligramValue(int milligrams) {
    return '$milligrams mg';
  }

  @override
  String get healthScoreLabel => 'Health score';

  @override
  String healthScoreValue(int score) {
    return '$score/100';
  }

  @override
  String get servingWeightLabel => 'Estimated serving weight';

  @override
  String get detectedFoodsTitle => 'Detected foods';

  @override
  String foodComponentSummary(int weight, int calories, int confidence) {
    return '$weight g · $calories kcal · %$confidence';
  }

  @override
  String get warningsTitle => 'Things to consider';

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
