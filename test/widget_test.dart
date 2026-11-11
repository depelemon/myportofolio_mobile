import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Homepage displays the owner and portfolio actions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final text in [
      'MyPortfolio',
      'NPM',
      '2406000001',
      'Name',
      'Burhan',
      'Class',
      'PBP A',
      'Selamat datang di MyPortfolio Mobile!',
      'Lihat Proyek',
      'Tambah Proyek',
      'Logout',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('Each action displays its own SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (final action in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
    }
  });

  testWidgets('Homepage fits a small screen and scrolls in landscape', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
