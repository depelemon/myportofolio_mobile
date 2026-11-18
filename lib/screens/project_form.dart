import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  String _description = '';
  String _category = _categories.first;
  String _technologies = '';
  String _projectLink = '';

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      errorMaxLines: 2,
    );
  }

  void _showProject() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();
    FocusScope.of(context).unfocus();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proyek berhasil ditambahkan!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nama Proyek: $_projectName'),
              Text('Deskripsi: $_description'),
              Text('Kategori: $_category'),
              Text('Teknologi: $_technologies'),
              Text('Tautan: $_projectLink'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              form.reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      drawer: const LeftDrawer(isHome: false),
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
                DropdownButtonFormField<String>(
                  decoration: _decoration('Kategori Proyek'),
                  initialValue: _categories.first,
                  isExpanded: true,
                  items: [
                    for (final category in _categories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (value) => _category = value ?? _categories.first,
                ),
                TextFormField(
                  decoration: _decoration(
                    'Teknologi yang Digunakan',
                    hint: 'Contoh: Flutter, Django, Figma',
                  ),
                  onSaved: (value) => _technologies = value?.trim() ?? '',
                ),
                TextFormField(
                  decoration: _decoration(
                    'Tautan Proyek',
                    hint: 'URL Proyek (opsional)',
                  ),
                  keyboardType: TextInputType.url,
                  onSaved: (value) => _projectLink = value?.trim() ?? '',
                ),
                Align(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _showProject,
                    child: const Text('Save'),
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
