import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().login(_username, _password);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = switch (error) {
            ApiException(statusCode: 400 || 401) =>
              'Username atau password salah.',
            _ => 'Login gagal. Coba lagi.',
          };
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Username tidak boleh kosong.'
                      : null,
                  onSaved: (value) => _username = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => (value ?? '').isEmpty
                      ? 'Password tidak boleh kosong.'
                      : null,
                  onSaved: (value) => _password = value!,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error case final message?)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? 'Memproses…' : 'Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
