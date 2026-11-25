import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  testWidgets('Lihat Proyek membuka daftar publik dari Home', (tester) async {
    var attempts = 0;
    final api = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['authorization'], isNull);
        if (++attempts == 1) return http.Response('server error', 500);
        return http.Response('''[{
        "id": "server-id", "title": "Atlas", "description": "Peta interaktif",
        "released_at": "2026-11-25", "tech_stack": "Flutter",
        "project_url": "https://example.com", "project_image_url": null
      }]''', 200);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Proyek'), findsOneWidget);
    expect(find.text('Gagal memuat proyek.'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Atlas'), findsOneWidget);
    expect(find.text('Flutter\nPeta interaktif'), findsOneWidget);
    await tester.tap(find.text('Atlas'));
    await tester.pumpAndSettle();
    expect(find.text('Tanggal rilis: 2026-11-25'), findsOneWidget);
    expect(find.text('Tautan: https://example.com'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(attempts, 2);
  });
}
