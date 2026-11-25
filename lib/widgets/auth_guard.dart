import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;
  return await Navigator.of(context)
          .push<bool>(MaterialPageRoute(builder: (_) => const LoginScreen())) ??
      false;
}

Future<void> logout(BuildContext context) async {
  final auth = context.read<AuthState>();
  if (!auth.isLoggedIn) return;
  final messenger = ScaffoldMessenger.of(context);
  var message = 'Berhasil logout.';
  try {
    await auth.logout();
  } on ApiException catch (error) {
    if (error.statusCode != 401) {
      message = 'Sesi lokal ditutup, tetapi token gagal dicabut di server.';
    }
  } catch (_) {
    message = 'Sesi lokal ditutup, tetapi token gagal dicabut di server.';
  }
  if (messenger.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
