import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  String _description = '';
  String _releasedAt = '';
  String _technologies = '';
  String _projectLink = '';
  String _imageUrl = '';
  bool _submitting = false;

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      errorMaxLines: 2,
    );
  }

  bool _isWebUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  bool _isReleaseDate(String value) {
    if (!RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$').hasMatch(value)) return false;
    final date = DateTime.tryParse(value);
    return date != null &&
        date.year > 0 &&
        date.toIso8601String().startsWith('${value}T');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    if (_submitting || !form.validate()) return;
    form.save();
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    setState(() => _submitting = true);

    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = auth.token;
      if (token == null) return;
      final saved = await api.createProject(
        Project(
          title: _projectName,
          description: _description,
          releasedAt: _releasedAt,
          techStack: _technologies,
          projectUrl: _projectLink,
          projectImageUrl: _imageUrl,
        ),
        token: token,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text('“${saved.title}” sudah tersimpan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) form.reset();
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        auth.clearSession();
        _showError('Sesi berakhir. Masuk lagi sebelum menyimpan.');
        await ensureLoggedIn(context);
      } else {
        _showError(switch (error.statusCode) {
          403 => 'Hanya pemilik portofolio yang dapat menambah proyek.',
          400 => 'Data proyek ditolak. Periksa kembali isianmu.',
          _ => 'Proyek gagal disimpan. Coba lagi.',
        });
      }
    } catch (_) {
      if (mounted) {
        _showError(
          'Tidak dapat memastikan proyek tersimpan. Periksa daftar sebelum mencoba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(currentPage: DrawerPage.project),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                TextFormField(
                  decoration: _decoration('Nama Proyek'),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Nama proyek tidak boleh kosong!'
                      : null,
                  onSaved: (value) => _projectName = value!.trim(),
                ),
                TextFormField(
                  decoration: _decoration('Deskripsi Proyek'),
                  maxLines: 5,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Deskripsi proyek tidak boleh kosong!'
                      : null,
                  onSaved: (value) => _description = value!.trim(),
                ),
                TextFormField(
                  decoration: _decoration('Tanggal Rilis', hint: 'YYYY-MM-DD'),
                  keyboardType: TextInputType.datetime,
                  validator: (value) => _isReleaseDate((value ?? '').trim())
                      ? null
                      : 'Masukkan tanggal yang valid (YYYY-MM-DD).',
                  onSaved: (value) => _releasedAt = value!.trim(),
                ),
                TextFormField(
                  decoration: _decoration(
                    'Teknologi yang Digunakan',
                    hint: 'Contoh: Flutter, Django, Figma',
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Teknologi tidak boleh kosong!'
                      : null,
                  onSaved: (value) => _technologies = value?.trim() ?? '',
                ),
                TextFormField(
                  decoration: _decoration(
                    'Tautan Proyek',
                    hint: 'https://example.com',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) => _isWebUrl((value ?? '').trim())
                      ? null
                      : 'Masukkan URL HTTP atau HTTPS yang valid.',
                  onSaved: (value) => _projectLink = value?.trim() ?? '',
                ),
                TextFormField(
                  decoration: _decoration('URL Gambar (Opsional)'),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    final input = (value ?? '').trim();
                    return input.isEmpty || _isWebUrl(input)
                        ? null
                        : 'Masukkan URL gambar HTTP atau HTTPS yang valid.';
                  },
                  onSaved: (value) => _imageUrl = value?.trim() ?? '',
                ),
                Align(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Menyimpan…' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
