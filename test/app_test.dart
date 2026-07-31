import 'package:ai_food_analyzer/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the localized project foundation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.text('AI Food Analyzer'), findsOneWidget);
    expect(find.text('Project foundation is ready.'), findsOneWidget);
  });
}
