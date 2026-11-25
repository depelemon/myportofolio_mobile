import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (project.projectImageUrl.isNotEmpty)
              Image.network(
                project.projectImageUrl,
                height: 220,
                fit: BoxFit.contain,
                semanticLabel: 'Gambar ${project.title}',
                errorBuilder: (_, error, stack) =>
                    const Text('Gambar tidak dapat dimuat.'),
              ),
            SelectableText(project.description),
            const SizedBox(height: 12),
            Text('Tanggal rilis: ${project.releasedAt}'),
            if (project.techStack.isNotEmpty)
              Text('Teknologi: ${project.techStack}'),
            if (project.projectUrl.isNotEmpty)
              SelectableText('Tautan: ${project.projectUrl}'),
          ],
        ),
      ),
    );
  }
}
