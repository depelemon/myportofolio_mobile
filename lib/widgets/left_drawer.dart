import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

enum DrawerPage { home, projects, project, experience }

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, required this.currentPage});

  final DrawerPage currentPage;

  Future<void> _openPage(
    BuildContext context,
    DrawerPage page,
    Widget child,
  ) async {
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context)!;
    navigator.pop();
    if (currentPage == page) return;
    // The drawer can unmount while the login route is open.
    final pageContext = route.subtreeContext!;
    if (page == DrawerPage.project && !await ensureLoggedIn(pageContext)) {
      return;
    }
    if (!navigator.mounted || !route.isCurrent) return;
    final destination = MaterialPageRoute<void>(builder: (_) => child);
    if (currentPage == DrawerPage.home) {
      navigator.push(destination);
    } else {
      navigator.pushReplacement(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              final navigator = Navigator.of(context);
              final isFirst = ModalRoute.of(context)!.isFirst;
              navigator.pop();
              if (currentPage == DrawerPage.home) return;

              if (isFirst) {
                navigator.pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const MyHomePage()),
                );
              } else {
                navigator.pop();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Lihat Proyek'),
            onTap: () => _openPage(
              context,
              DrawerPage.projects,
              const ProjectListScreen(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () =>
                _openPage(context, DrawerPage.project, const ProjectFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            onTap: () => _openPage(
              context,
              DrawerPage.experience,
              const ExperienceFormPage(),
            ),
          ),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () {
              final navigator = Navigator.of(context);
              final pageContext = ModalRoute.of(context)!.subtreeContext!;
              navigator.pop();
              if (isLoggedIn) {
                logout(pageContext);
              } else {
                ensureLoggedIn(pageContext);
              }
            },
          ),
        ],
      ),
    );
  }
}
