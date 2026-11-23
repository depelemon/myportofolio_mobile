import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Kartu Tambah Pengalaman membuka form dan Back kembali ke Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final card = find.text('Tambah Pengalaman');
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Tambah Pengalaman'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'MyPortfolio'), findsOneWidget);
  });

  testWidgets('Add Experience dari drawer menyediakan jalan kembali ke Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _selectDrawerItem(tester, 'Add Experience');
    expect(find.widgetWithText(AppBar, 'Tambah Pengalaman'), findsOneWidget);

    await _selectDrawerItem(tester, 'Add Project');
    expect(find.widgetWithText(AppBar, 'Add Project Form'), findsOneWidget);
    await _selectDrawerItem(tester, 'Add Experience');
    await _selectDrawerItem(tester, 'Home');
    expect(find.widgetWithText(AppBar, 'MyPortfolio'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Tambah Pengalaman'), findsNothing);
  });

  testWidgets('Home dari drawer menghapus rute form di atas Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final card = find.text('Tambah Pengalaman');
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tambah Pengalaman'), findsOneWidget);

    await _selectDrawerItem(tester, 'Add Project');
    expect(find.widgetWithText(AppBar, 'Add Project Form'), findsOneWidget);
    await _selectDrawerItem(tester, 'Home');
    final home = find.widgetWithText(AppBar, 'MyPortfolio');
    expect(home, findsOneWidget);
    expect(Navigator.of(tester.element(home)).canPop(), isFalse);
  });

  testWidgets('Form menolak kolom wajib yang kosong atau hanya berisi spasi', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _selectDrawerItem(tester, 'Add Experience');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Pengalaman'),
      '   ',
    );
    await _save(tester);

    for (final error in [
      'Judul Pengalaman wajib diisi.',
      'Organisasi wajib diisi.',
      'Deskripsi wajib diisi.',
      'Tanggal mulai wajib diisi.',
    ]) {
      expect(find.text(error), findsOneWidget);
    }
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Simpan merangkum semua isian pada layar ponsel', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MyApp());
    await _selectDrawerItem(tester, 'Add Experience');
    await _enterDetails(tester);
    final category = find.byType(DropdownButtonFormField<String>);
    expect(category, findsOneWidget);
    await tester.ensureVisible(category);
    await tester.tap(category);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Internship').last);
    await tester.pumpAndSettle();
    await _pickDate(tester, 'Tanggal Mulai', '01/02/2025');
    await _pickDate(tester, 'Tanggal Selesai (opsional)', '03/04/2025');
    await _enterText(
      tester,
      'URL Thumbnail (opsional)',
      'https://example.com/team.png',
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    final save = find.widgetWithText(ElevatedButton, 'Simpan');
    await tester.ensureVisible(save);
    expect(save.hitTestable(), findsOneWidget);
    await tester.tap(save);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    for (final text in [
      'Judul Pengalaman: Asisten Riset',
      'Organisasi: Lab UI',
      'Deskripsi: Mengolah data penelitian.',
      'Kategori: Internship',
      'Tanggal Mulai: Jan 2, 2025',
      'Tanggal Selesai: Mar 4, 2025',
      'URL Thumbnail: https://example.com/team.png',
    ]) {
      expect(
        find.descendant(of: dialog, matching: find.textContaining(text)),
        findsOneWidget,
      );
    }
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(find.text('Asisten Riset'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Form menolak panjang, URL, dan urutan tanggal yang tidak valid',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await _selectDrawerItem(tester, 'Add Experience');
      await _enterDetails(tester);
      await _enterText(tester, 'Judul Pengalaman', 'a' * 256);
      await _enterText(tester, 'Organisasi', 'a' * 256);
      await _pickDate(tester, 'Tanggal Mulai', '06/15/2025');
      await _pickDate(tester, 'Tanggal Selesai (opsional)', '06/14/2025');
      await _enterText(
        tester,
        'URL Thumbnail (opsional)',
        'https://example.com/${'a' * 200}',
      );
      await _save(tester);

      expect(
        find.text('Judul Pengalaman maksimal 255 karakter.'),
        findsOneWidget,
      );
      expect(find.text('Organisasi maksimal 255 karakter.'), findsOneWidget);
      expect(find.text('URL thumbnail maksimal 200 karakter.'), findsOneWidget);
      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await _enterDetails(tester);
      await _enterText(tester, 'URL Thumbnail (opsional)', 'https://');
      await _save(tester);
      expect(find.text('Masukkan URL thumbnail yang valid.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      final clearEndDate = find.byTooltip('Hapus tanggal selesai');
      await tester.ensureVisible(clearEndDate);
      await tester.tap(clearEndDate);
      await _enterText(tester, 'URL Thumbnail (opsional)', '');
      await _save(tester);

      expect(find.text('Ringkasan Pengalaman'), findsOneWidget);
      expect(
        find.textContaining('Tanggal Selesai: Masih berlangsung'),
        findsOneWidget,
      );
      expect(find.textContaining('URL Thumbnail: Tidak diisi'), findsOneWidget);
    },
  );

  for (final url in [
    'https://999.999.999.999/a.png',
    'https://example.com:99999/a.png',
    'https://example.com:0/a.png',
    'FTP://example.com:0/a.png',
    'https://example.com:99999999999999999999/a.png',
  ]) {
    testWidgets('Form menolak URL thumbnail $url', (tester) async {
      await tester.pumpWidget(const MyApp());
      await _selectDrawerItem(tester, 'Add Experience');
      await _enterDetails(tester);
      await _pickDate(tester, 'Tanggal Mulai', '01/02/2025');
      await _enterText(tester, 'URL Thumbnail (opsional)', url);
      await _save(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Masukkan URL thumbnail yang valid.'), findsOneWidget);
    });
  }

  testWidgets('Form menerima URL localhost, IPv4, IPv6, dan FTP tanpa port', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _selectDrawerItem(tester, 'Add Experience');
    await _enterDetails(tester);
    await _pickDate(tester, 'Tanggal Mulai', '01/02/2025');

    for (final url in [
      'http://localhost:1/a.png',
      'https://192.0.2.1:65535/a.png',
      'https://[2001:db8::1]/a.png',
      'ftp://example.com/a.png',
    ]) {
      await _enterText(tester, 'URL Thumbnail (opsional)', url);
      await _save(tester);
      expect(find.textContaining('URL Thumbnail: $url'), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
    }
  });
}

Future<void> _selectDrawerItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Simpan');
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _enterDetails(WidgetTester tester) async {
  await _enterText(tester, 'Judul Pengalaman', 'Asisten Riset');
  await _enterText(tester, 'Organisasi', 'Lab UI');
  await _enterText(tester, 'Deskripsi', 'Mengolah data penelitian.');
}

Future<void> _enterText(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  expect(field, findsOneWidget);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _pickDate(WidgetTester tester, String label, String date) async {
  final field = find.text(label);
  expect(field, findsOneWidget);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  final input = find.descendant(
    of: find.byType(DatePickerDialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(input, date);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(find.byType(DatePickerDialog), findsNothing);
}
