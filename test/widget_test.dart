import 'package:flutter_test/flutter_test.dart';

import 'package:mpor_ipcr_flutter/app/app.dart';

void main() {
  testWidgets('MPOR IPCR app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MporIpcrApp());

    expect(find.text('MPOR / IPCR'), findsOneWidget);
    expect(find.text('Good day!'), findsOneWidget);

    expect(
      find.text('Daily Accomplishment'),
      findsNWidgets(2),
    );

    expect(
      find.text('Monthly Reports'),
      findsNWidgets(2),
    );

    expect(find.text('Current Reporting Period'), findsOneWidget);
  });
}