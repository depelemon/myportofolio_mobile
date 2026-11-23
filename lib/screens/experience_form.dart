import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  static const _categories = [
    'Internship',
    'Research',
    'Volunteer',
    'Part-Time',
    'Full-Time',
    'Freelance',
  ];

  final _formKey = GlobalKey<FormState>();
  final _startDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _endDateKey = GlobalKey<FormFieldState<DateTime>>();
  late String _title;
  late String _organization;
  late String _description;
  late String _category;
  late String _thumbnail;

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    errorMaxLines: 2,
  );

  String? _requiredText(String? value, String label, {int? maxLength}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '$label wajib diisi.';
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  String? _validateThumbnail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (text.runes.length > 200) return 'URL thumbnail maksimal 200 karakter.';

    const invalid = 'Masukkan URL thumbnail yang valid.';
    final url = Uri.tryParse(text);
    if (url == null ||
        !const {'http', 'https', 'ftp', 'ftps'}.contains(url.scheme) ||
        RegExp(r'[\s\\]').hasMatch(text)) {
      return invalid;
    }

    // Uri can normalize away an explicit port 0 for FTP and FTPS.
    final portText = RegExp(r'^[^:]+://[^/?#]*:([^:/?#@\]]+)(?=[/?#]|$)')
        .firstMatch(text)
        ?.group(1);
    if (portText != null) {
      final port = int.tryParse(portText, radix: 10);
      if (port == null || port < 1 || port > 65535) return invalid;
    }

    final host = url.host;
    if (host == 'localhost' || host.contains(':')) return null;
    if (!RegExp(r'^[^.]+(?:\.[^.]+)+\.?$').hasMatch(host)) return invalid;
    if (RegExp(r'^[0-9.]+$').hasMatch(host)) {
      try {
        Uri.parseIPv4Address(host);
      } on FormatException {
        return invalid;
      }
    }
    return null;
  }

  String _formatDate(DateTime date) =>
      MaterialLocalizations.of(context).formatShortDate(date);

  Widget _dateField(
    String label, {
    required GlobalKey<FormFieldState<DateTime>> key,
    FormFieldValidator<DateTime>? validator,
    bool canClear = false,
  }) {
    return FormField<DateTime>(
      key: key,
      validator: validator,
      builder: (field) {
        final value = field.value;
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () async {
            FocusScope.of(context).unfocus();
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100, 12, 31),
              helpText: 'Pilih ${label.toLowerCase()}',
            );
            if (date != null && field.mounted) field.didChange(date);
          },
          child: InputDecorator(
            decoration: _decoration(label).copyWith(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              suffixIcon: canClear && value != null
                  ? IconButton(
                      tooltip: 'Hapus tanggal selesai',
                      icon: const Icon(Icons.clear),
                      onPressed: () => field.didChange(null),
                    )
                  : null,
              errorText: field.errorText,
            ),
            child: Text(value == null ? 'Pilih tanggal' : _formatDate(value)),
          ),
        );
      },
    );
  }

  void _showSummary() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();
    FocusScope.of(context).unfocus();

    final start = _startDateKey.currentState!.value!;
    final end = _endDateKey.currentState!.value;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Pengalaman'),
        scrollable: true,
        content: Text(
          'Judul Pengalaman: $_title\n'
          'Organisasi: $_organization\n'
          'Deskripsi: $_description\n'
          'Kategori: $_category\n'
          'Tanggal Mulai: ${_formatDate(start)}\n'
          'Tanggal Selesai: ${end == null ? 'Masih berlangsung' : _formatDate(end)}\n'
          'URL Thumbnail: ${_thumbnail.isEmpty ? 'Tidak diisi' : _thumbnail}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengalaman'),
        centerTitle: true,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(currentPage: DrawerPage.experience),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: _decoration('Judul Pengalaman'),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      _requiredText(value, 'Judul Pengalaman', maxLength: 255),
                  onSaved: (value) => _title = value!.trim(),
                ),
                TextFormField(
                  decoration: _decoration('Organisasi'),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      _requiredText(value, 'Organisasi', maxLength: 255),
                  onSaved: (value) => _organization = value!.trim(),
                ),
                TextFormField(
                  decoration: _decoration('Deskripsi'),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) => _requiredText(value, 'Deskripsi'),
                  onSaved: (value) => _description = value!.trim(),
                ),
                DropdownButtonFormField<String>(
                  decoration: _decoration('Kategori'),
                  initialValue: 'Full-Time',
                  isExpanded: true,
                  items: [
                    for (final category in _categories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (_) {},
                  validator: (value) => _categories.contains(value)
                      ? null
                      : 'Pilih kategori pengalaman.',
                  onSaved: (value) => _category = value!,
                ),
                _dateField(
                  'Tanggal Mulai',
                  key: _startDateKey,
                  validator: (date) =>
                      date == null ? 'Tanggal mulai wajib diisi.' : null,
                ),
                _dateField(
                  'Tanggal Selesai (opsional)',
                  key: _endDateKey,
                  canClear: true,
                  validator: (end) {
                    final start = _startDateKey.currentState?.value;
                    return start != null && end != null && end.isBefore(start)
                        ? 'Tanggal selesai tidak boleh sebelum tanggal mulai.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: _decoration('URL Thumbnail (opsional)'),
                  keyboardType: TextInputType.url,
                  validator: _validateThumbnail,
                  onSaved: (value) => _thumbnail = value?.trim() ?? '',
                ),
                Align(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    onPressed: _showSummary,
                    child: const Text('Simpan'),
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
