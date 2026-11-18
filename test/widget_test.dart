import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Homepage displays the owner and portfolio actions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final text in [
      'MyPortfolio',
      'NPM',
      '2506601956',
      'Name',
      'David Liman',
      'Class',
      'PBP B',
      'Selamat datang di MyPortfolio Mobile!',
      'Lihat Proyek',
      'Tambah Proyek',
      'Logout',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('Lihat Proyek and Logout display their own SnackBar', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final action in ['Lihat Proyek', 'Logout']) {
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
    }
  });

  testWidgets('Tambah Proyek opens the form and preserves Home on Back', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('MyPortfolio'), findsOneWidget);
  });

  testWidgets('Drawer switches between Home and Add Project', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('My Portfolio'), findsOneWidget);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Add Project Form'), findsNothing);
  });

  testWidgets('Project form rejects a blank name and description', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      '  ',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Project form previews its values and resets after OK', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    final inputs = {
      'Nama Proyek': 'Atlas',
      'Deskripsi Proyek': 'Peta interaktif',
      'Teknologi yang Digunakan': 'Flutter',
      'Tautan Proyek': 'https://example.com',
    };
    for (final entry in inputs.entries) {
      final field = find.widgetWithText(TextFormField, entry.key);
      await tester.ensureVisible(field);
      await tester.enterText(field, entry.value);
    }

    final category = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(category);
    await tester.tap(category);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Data Science').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    for (final text in [
      'Proyek berhasil ditambahkan!',
      'Nama Proyek: Atlas',
      'Deskripsi: Peta interaktif',
      'Kategori: Data Science',
      'Teknologi: Flutter',
      'Tautan: https://example.com',
    ]) {
      expect(find.text(text), findsOneWidget);
    }

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    for (final field in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(field.controller.text, isEmpty);
    }
    expect(
      tester.state<FormFieldState<String>>(category).value,
      'Web Development',
    );
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
