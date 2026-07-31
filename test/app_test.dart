import 'package:ai_food_analyzer/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the meal capture home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.text('Take a photo of\nyour meal'), findsOneWidget);
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
  });
}
