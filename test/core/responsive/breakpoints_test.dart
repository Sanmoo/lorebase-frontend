import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/responsive/breakpoints.dart';

void main() {
  group('getScreenSize', () {
    testWidgets('returns mobile when width < 600', (tester) async {
      await _pumpWithWidth(tester, 360);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.mobile);
    });

    testWidgets('returns tablet when width >= 600 and < 900', (tester) async {
      await _pumpWithWidth(tester, 768);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.tablet);
    });

    testWidgets('returns desktop when width >= 900', (tester) async {
      await _pumpWithWidth(tester, 1440);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.desktop);
    });

    testWidgets('returns mobile at boundary 599', (tester) async {
      await _pumpWithWidth(tester, 599);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.mobile);
    });

    testWidgets('returns tablet at boundary 600', (tester) async {
      await _pumpWithWidth(tester, 600);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.tablet);
    });

    testWidgets('returns desktop at boundary 900', (tester) async {
      await _pumpWithWidth(tester, 900);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.desktop);
    });
  });
}

Future<void> _pumpWithWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width * 3, 800 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SizedBox(),
      ),
    ),
  );
}
