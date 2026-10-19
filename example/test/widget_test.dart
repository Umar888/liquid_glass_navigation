import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_nav_bar_example/main.dart';

void main() {
  for (final size in const [Size(390, 844), Size(1194, 834)]) {
    testWidgets('demo visits every tab at ${size.width.toInt()} wide',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const DemoApp());
      for (final tab in const ['Explore', 'Inbox', 'Today', 'Settings']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Frosted'));
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
