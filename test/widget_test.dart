import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const _project = {
  'title': 'Atlas',
  'description': 'Peta interaktif',
  'released_at': '2026-11-25',
  'tech_stack': 'Flutter',
  'project_url': 'https://example.com',
  'project_image_url': '',
};

Future<void> _pumpApp(WidgetTester tester, {int createStatus = 201}) async {
  final api = ApiClient(
    client: MockClient((request) async {
      expect(request.method, 'POST');
      if (request.url.path == '/api/v1/auth/token/') {
        expect(jsonDecode(request.body), {
          'username': 'owner',
          'password': 'password',
        });
        return http.Response('{"token":"test-token"}', 200);
      }
      expect(request.headers['authorization'], 'Token test-token');
      if (request.url.path == '/api/v1/auth/logout/') {
        return http.Response('', 204);
      }
      expect(request.url.path, '/api/v1/projects/');
      expect(jsonDecode(request.body), _project);
      return http.Response(
        jsonEncode({..._project, 'id': 'server-id'}),
        createStatus,
      );
    }),
  );
  addTearDown(api.close);
  await tester.pumpWidget(MyApp(apiClient: api));
}

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  await _enter(tester, 'Username', 'owner');
  await _enter(tester, 'Password', 'password');
  await _tap(tester, 'Masuk');
}

Future<void> _fillProject(WidgetTester tester) async {
  await _enter(tester, 'Nama Proyek', 'Atlas');
  await _enter(tester, 'Deskripsi Proyek', 'Peta interaktif');
  await _enter(tester, 'Tanggal Rilis', '2026-11-25');
  await _enter(tester, 'Teknologi yang Digunakan', 'Flutter');
  await _enter(tester, 'Tautan Proyek', 'https://example.com');
}

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
      'Tambah Pengalaman',
      'Login',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('Tambah Proyek is blocked when login is cancelled', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, 'Tambah Proyek');
    expect(find.text('Masuk'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsNothing);
    expect(find.text('MyPortfolio'), findsOneWidget);
  });

  testWidgets('Drawer guards Add Project and returns to Home', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await _tap(tester, 'Add Project');
    expect(find.text('Masuk'), findsOneWidget);
    await _login(tester);
    expect(find.text('Add Project Form'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await _tap(tester, 'Home');
    expect(find.text('MyPortfolio'), findsOneWidget);
    await _tap(tester, 'Logout');
    expect(find.text('Berhasil logout.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Project form rejects invalid data without posting', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, 'Tambah Proyek');
    await _login(tester);
    await _enter(tester, 'Tanggal Rilis', '2026-02-30');
    await _enter(tester, 'Tautan Proyek', 'bukan url');
    await _tap(tester, 'Save');
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('Masukkan tanggal yang valid (YYYY-MM-DD).'),
      findsOneWidget,
    );
    expect(
      find.text('Masukkan URL HTTP atau HTTPS yang valid.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Project form posts authenticated JSON and resets after OK', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _tap(tester, 'Tambah Proyek');
    await _login(tester);
    await _fillProject(tester);
    await _tap(tester, 'Save');
    expect(find.text('“Atlas” sudah tersimpan.'), findsOneWidget);
    await _tap(tester, 'OK');
    for (final field in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(field.controller.text, isEmpty);
    }
  });

  testWidgets('A rejected token requires login again and keeps form input', (
    tester,
  ) async {
    await _pumpApp(tester, createStatus: 401);
    await _tap(tester, 'Tambah Proyek');
    await _login(tester);
    await _fillProject(tester);
    await _tap(tester, 'Save');
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Atlas'), findsOneWidget);
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
      await _tap(tester, 'Login');
      expect(find.text('Masuk'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
  });
}
