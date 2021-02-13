import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:captain/captain_widget.dart';

void main() {
  testWidgets('expect a router widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Captain(
          config: CaptainConfig(
            pages: [MaterialPage(child: Center())],
          ),
        ),
      ),
    );
    var routerFinder = find.byType(Router);
    expect(routerFinder, findsOneWidget);
  });
}
