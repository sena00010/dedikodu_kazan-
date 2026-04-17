import 'package:flutter_test/flutter_test.dart';

import 'package:dedikodu_kazani/main.dart';

void main() {
  testWidgets('login screen opens', (WidgetTester tester) async {
    await tester.pumpWidget(const DedikoduKazaniApp());

    expect(find.text('Dedikodu Kazanı'), findsOneWidget);
  });
}
