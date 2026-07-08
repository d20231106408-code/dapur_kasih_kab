// Basic smoke test for the DapurKasih app.
//
// The full app requires a live Firebase connection, so this test
// exercises the WelcomePage (pure UI, no Firebase) to verify the
// widget tree builds and the entry action is present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dapur/welcome_page.dart';

void main() {
  testWidgets('Welcome page shows brand and Get Started button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
    await tester.pump(const Duration(seconds: 1)); // let intro animation run

    expect(find.text('DapurKasih'), findsWidgets);
    expect(
      find.widgetWithText(ElevatedButton, "Let's Get Started"),
      findsOneWidget,
    );
  });
}
