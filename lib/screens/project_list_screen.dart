import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = context.read<ApiClient>().getProjects();
  }

  Future<void> _reload() async {
    final request = context.read<ApiClient>().getProjects();
    setState(() {
      _projects = request;
    });
    try {
      await request;
    } catch (_) {
      // FutureBuilder displays the error and the retry action.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Proyek')),
      drawer: const LeftDrawer(currentPage: DrawerPage.projects),
      body: SafeArea(
        child: FutureBuilder<List<Project>>(
          future: _projects,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat proyek.'),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            final projects = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: projects.isEmpty ? 1 : projects.length,
                itemBuilder: (context, index) {
                  if (projects.isEmpty) {
                    return const Center(child: Text('Belum ada proyek.'));
                  }
                  final project = projects[index];
                  return Card(
                    child: ListTile(
                      title: Text(project.title),
                      subtitle: Text(
                        [
                          if (project.techStack.isNotEmpty) project.techStack,
                          project.description,
                        ].join('\n'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProjectDetailScreen(project: project),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
