import 'package:flutter/material.dart';
import '../widgets/usuarios_tab.dart';
import '../widgets/roles_tab.dart';
import '../widgets/usuario_form_dialog.dart';
import '../widgets/rol_form_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class UsuariosRolesScreen extends ConsumerStatefulWidget {
  const UsuariosRolesScreen({super.key});

  @override
  ConsumerState<UsuariosRolesScreen> createState() => _UsuariosRolesScreenState();
}

class _UsuariosRolesScreenState extends ConsumerState<UsuariosRolesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin de Accesos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header matching web
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ADMINISTRACIÓN DE ACCESOS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B), // slate-800
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestión integral de usuarios, roles y permisos del sistema.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.blueGrey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Action Button dynamically changing
                Builder(builder: (context) {
                  final authState = ref.watch(authProvider);
                  final bool puedeCrearUsuario = authState.hasPermission('Control de Usuarios', 'puedeCrear');
                  final bool puedeCrearRol = authState.hasPermission('Roles y Permisos', 'puedeCrear');

                  if (_currentIndex == 0 ? !puedeCrearUsuario : !puedeCrearRol) {
                    return const SizedBox.shrink();
                  }

                  return ElevatedButton.icon(
                    onPressed: () {
                      if (_currentIndex == 0) {
                        showDialog(
                          context: context,
                          builder: (_) => const UsuarioFormDialog(),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => const RolFormDialog(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B), // slate-800
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(
                      _currentIndex == 0 ? 'NUEVO USUARIO' : 'NUEVO ROL',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // Custom Tabs
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.blueGrey.shade100, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        title: '👥 Usuarios',
                        isActive: _currentIndex == 0,
                        activeColor: Colors.blue[600]!,
                        onTap: () => _tabController.animateTo(0),
                      ),
                      const SizedBox(width: 16),
                      _buildTabButton(
                        title: '🛡️ Roles y Permisos',
                        isActive: _currentIndex == 1,
                        activeColor: Colors.purple[600]!,
                        onTap: () => _tabController.animateTo(1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                UsuariosTab(),
                RolesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: isActive ? activeColor : Colors.blueGrey.shade400,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
