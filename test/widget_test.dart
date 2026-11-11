import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/core/providers/theme_provider.dart';
import 'package:myfinance/main.dart';

void main() {
  testWidgets('App renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyFinanceApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
