import 'package:flutter/material.dart';
import '../widgets/usuarios_tab.dart';
import '../widgets/roles_tab.dart';

class UsuariosRolesScreen extends StatefulWidget {
  const UsuariosRolesScreen({super.key});

  @override
  State<UsuariosRolesScreen> createState() => _UsuariosRolesScreenState();
}

class _UsuariosRolesScreenState extends State<UsuariosRolesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin de Accesos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuarios', icon: Icon(Icons.people)),
            Tab(text: 'Roles', icon: Icon(Icons.security)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UsuariosTab(),
          RolesTab(),
        ],
      ),
    );
  }
}
