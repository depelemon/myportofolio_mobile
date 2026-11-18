import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, required this.isHome});

  final bool isHome;

  @override
  Widget build(BuildContext context) {
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
              if (isHome) return;

              if (isFirst) {
                navigator.pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => MyHomePage()),
                );
              } else {
                navigator.pop();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              if (isHome) {
                navigator.pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProjectFormPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
