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
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orContinueWithEmail => 'or continue with email';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingScanTitle => 'Analyze your meal in seconds';

  @override
  String get onboardingScanDescription =>
      'Take a photo or choose one from your library and let AI prepare nutrition and calorie details.';

  @override
  String get onboardingHistoryTitle => 'Your analyses stay in History';

  @override
  String get onboardingHistoryDescription =>
      'Use the History icon at the top right to revisit your saved meals at any time.';

  @override
  String get onboardingPersonalizeTitle => 'Manage your language and account';

  @override
  String get onboardingPersonalizeDescription =>
      'Choose English or Turkish from the language icon and manage Premium from your account.';

  @override
  String get showAppTour => 'Show app tour';

  @override
  String freeAnalysesRemaining(int count) {
    return 'Free analyses remaining: $count';
  }

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
  String get invalidEmailMessage =>
      'Enter a valid email address, such as name@outlook.com.';

  @override
  String get passwordTooShortMessage =>
      'Your password must be at least 8 characters.';

  @override
  String get emailAlreadyRegisteredMessage =>
      'An account already exists for this email. Try signing in instead.';

  @override
  String get invalidLoginMessage => 'The email or password is incorrect.';

  @override
  String get authGenericErrorMessage =>
      'We could not complete this request. Please try again.';

  @override
  String get checkEmailMessage =>
      'We sent a confirmation email. Check your inbox and spam folder, then sign in.';

  @override
  String get resendConfirmation => 'Send confirmation email again';

  @override
  String resendConfirmationCountdown(int seconds) {
    return 'Send again (${seconds}s)';
  }

  @override
  String get confirmationResent =>
      'A new confirmation email was sent. Check your spam folder if it is not in your inbox.';

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
  String get premiumMember => 'Premium member';

  @override
  String get freeMember => 'Free plan';

  @override
  String get managePremium => 'Manage Premium';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

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
  String get restorePurchasesDescription =>
      'Already subscribed with this Apple ID? Restore your access without being charged again.';

  @override
  String get manageSubscription => 'Manage or cancel subscription';

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
  String get nutritionSummaryTitle => 'Nutrition Summary';

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

  @override
  String get chooseFeatureTitle => 'How can we help?';

  @override
  String get chooseFeatureDescription =>
      'Analyze your meal or find a more balanced choice from a menu.';

  @override
  String get scanFoodTitle => 'Scan Food';

  @override
  String get scanFoodDescription =>
      'Estimate calories and nutrition for your plate.';

  @override
  String get scanFoodSourceDescription =>
      'Take or choose a photo that clearly shows the entire meal.';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get barcodeScanDescription =>
      'Place the product barcode inside the frame. We\'ll find its exact nutrition facts when available.';

  @override
  String get findingProduct => 'Finding product...';

  @override
  String get barcodeProductNotFound =>
      'We couldn\'t find this barcode. You can scan again or analyze the product with a photo.';

  @override
  String get barcodeLookupFailed =>
      'Product information is temporarily unavailable. Please try again.';

  @override
  String get verifiedProduct => 'BARCODE MATCH';

  @override
  String get consumedAmount => 'Amount consumed';

  @override
  String caloriesForAmount(int grams) {
    return 'Calories for $grams g';
  }

  @override
  String dataSource(String source) {
    return 'Source: $source';
  }

  @override
  String get scanAnotherBarcode => 'Scan another barcode';

  @override
  String get enterBarcodeManually => 'Enter barcode manually';

  @override
  String get enterBarcode => 'Enter barcode';

  @override
  String get barcodeHint => '8–14 digit barcode';

  @override
  String get searchProduct => 'Find product';

  @override
  String get emailUnavailable => 'Email information unavailable';

  @override
  String get menuScanTitle => 'Choose from Menu';

  @override
  String get menuScanDescription =>
      'Scan a menu and compare lighter, balanced choices.';

  @override
  String get menuScanIntroDescription =>
      'Take a clear photo of the menu. We will compare readable dishes by calories, ingredients, and balance.';

  @override
  String get menuScanComingSoon => 'Menu analysis is being prepared';

  @override
  String get menuScanHeroTitle => 'Find the best choice on the menu';

  @override
  String get menuPhotoSheetTitle => 'How would you like to add the menu?';

  @override
  String get menuPhotoSheetDescription =>
      'Make sure dish names and descriptions are clear and, if possible, visible in one frame.';

  @override
  String get scanMenuAction => 'Scan Menu';

  @override
  String get scanAnotherMenu => 'Scan Another Menu';

  @override
  String get analyzingMenu => 'Reviewing the menu...';

  @override
  String get analyzingMenuDescription =>
      'Comparing options by calories and nutritional balance.';

  @override
  String get menuAnalysisFailed =>
      'The menu could not be analyzed. Try again with a photo where the text is clear.';

  @override
  String get bestMenuChoice => 'Best balanced choice';

  @override
  String get otherMenuOptions => 'Other options';

  @override
  String get menuEstimateDisclaimer =>
      'Calories and health scores are estimates based on menu descriptions and may vary by ingredients and serving size.';

  @override
  String get nutritionSummarySubtitle =>
      'Track your daily macros and the last 7 days.';

  @override
  String get todaySummary => 'Today\'s summary';

  @override
  String get weeklyCalories => 'Last 7 days';

  @override
  String mealsTracked(int count) {
    return '$count meals saved';
  }

  @override
  String get noNutritionData => 'No saved meals yet';

  @override
  String get noNutritionDataDescription =>
      'Save an analysis result to build your daily and weekly summary here.';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get premiumNutritionBadge => 'PREMIUM TRACKING';

  @override
  String get searchHistory => 'Search history';

  @override
  String get allHistory => 'All';

  @override
  String get favorites => 'Favorites';

  @override
  String get highProtein => 'High protein';

  @override
  String get selectDate => 'Select date';

  @override
  String get clearDate => 'Clear date';

  @override
  String get noFilteredHistory => 'No meals match these filters.';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get weeklyComparison => 'Weekly comparison';

  @override
  String get thisWeek => 'This week';

  @override
  String get lastWeek => 'Last week';

  @override
  String calorieChangeUp(int percent) {
    return '$percent% more than last week';
  }

  @override
  String calorieChangeDown(int percent) {
    return '$percent% less than last week';
  }

  @override
  String get calorieChangeSame => 'About the same as last week';

  @override
  String get premiumReport => 'Premium Analysis';

  @override
  String get macroDistribution => 'Macro distribution';

  @override
  String get portionEstimate => 'Portion estimate';

  @override
  String get ingredientRisks => 'Ingredient risks';

  @override
  String get healthierSuggestions => 'Healthier improvements';

  @override
  String get noIngredientRisks => 'No notable ingredient risks were found.';

  @override
  String get suggestMoreFiber => 'Add vegetables or a salad for more fiber.';

  @override
  String get suggestLessSodium =>
      'Reducing sauces and salt may improve the balance.';

  @override
  String get suggestMoreProtein => 'Consider adding a little more protein.';

  @override
  String get suggestSmallerPortion =>
      'A smaller portion can help balance total calories.';

  @override
  String get suggestBalancedMeal =>
      'The overall balance looks good; keep the portion steady.';

  @override
  String get shareReport => 'Share report';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get shareAsPdf => 'Share as PDF';

  @override
  String get preparingReport => 'Preparing report...';

  @override
  String get reportShareFailed =>
      'The report could not be prepared. Please try again.';

  @override
  String get todayProgress => 'Today\'s progress';

  @override
  String get calorieProgress => 'Calories';

  @override
  String get proteinProgress => 'Protein';

  @override
  String targetValue(String value) {
    return 'Target: $value';
  }

  @override
  String get smartReminders => 'Smart reminders';

  @override
  String get smartRemindersDescription =>
      'Get occasional reminders on incomplete days and weekly progress.';

  @override
  String get dailyReminderTitle => 'Your nutrition check-in';

  @override
  String get dailyReminderBody =>
      'Complete today\'s analyses; small steps make a big difference.';

  @override
  String get notificationsPermissionRequired =>
      'Notifications were not allowed. You can enable them in Settings.';

  @override
  String get nutritionGoals => 'Nutrition goals';

  @override
  String get nutritionGoalsDescription =>
      'Set your daily calorie and protein targets.';

  @override
  String get calorieTarget => 'Daily calorie target';

  @override
  String get proteinTarget => 'Daily protein target';

  @override
  String get saveGoals => 'Save goals';

  @override
  String get invalidGoals => 'Please enter valid targets.';

  @override
  String get weeklyInsightTitle => 'Your weekly progress';

  @override
  String get weeklyInsightBody =>
      'Your vegetable and greens intake increased this week. Keep it going!';
}
