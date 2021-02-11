import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:captain/captain_widget.dart';

void main() {
  testWidgets('expect a router widget', (WidgetTester tester) async {
    await tester.pumpWidget(Captain(
      config: CaptainConfig(
        pages: [MaterialPage(child: Container())],
        popPage: (_, __, ___) => true,
        shouldPop: (_) => SynchronousFuture(true),
        actions: {},
      ),
    ));
    var routerFinder = find.byType(Router);
    expect(routerFinder, findsOneWidget);
  });
}
