abstract final class LegalLinks {
  static final privacyPolicy = Uri.parse(
    'https://ai-food-analyzer-api.onrender.com/privacy',
  );
  static final termsOfUse = Uri.parse(
    'https://ai-food-analyzer-api.onrender.com/terms',
  );
  static const supportEmail = 'guntav.enes@gmail.com';
  static final support = Uri(
    scheme: 'mailto',
    path: supportEmail,
    queryParameters: {'subject': 'AI Food Analyzer Support'},
  );
}
