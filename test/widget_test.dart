import 'package:flutter_test/flutter_test.dart';

import 'package:chain_watch_ai/app.dart';

void main() {
  testWidgets('App launches to the landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const ChainWatchApp());
    await tester.pumpAndSettle();

    expect(find.text('CHAINWATCH AI'), findsWidgets);
  });
}
