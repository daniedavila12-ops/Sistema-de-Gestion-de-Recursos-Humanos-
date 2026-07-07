import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/empleado_provider.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

class EmpleadosScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const EmpleadosScreen({super.key, this.initialFilter});

  @override
  ConsumerState<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends ConsumerState<EmpleadosScreen> {
  String _searchQuery = '';
  late String _statusFilter;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialFilter ?? 'todos';
  }

  @override
  Widget build(BuildContext context) {
    final empleadosAsync = ref.watch(empleadosProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lista de Empleados', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/nuevo-empleado');
        },
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NUEVO EMPLEADO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header search and filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, identidad...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(value: 'todos', child: Text('Todos')),
                        DropdownMenuItem(value: 'activos', child: Text('Activos')),
                        DropdownMenuItem(value: 'inactivos', child: Text('Inactivos')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _statusFilter = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: empleadosAsync.when(
              data: (empleados) {
                final filtered = empleados.where((emp) {
                  // Filter by status
                  if (_statusFilter == 'activos' && emp.estado != 1) return false;
                  if (_statusFilter == 'inactivos' && emp.estado == 1) return false;

                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    final nombreCompleto = emp.nombreCompleto.toLowerCase();
                    final identidad = (emp.identidad ?? '').toLowerCase();
                    if (!nombreCompleto.contains(_searchQuery) && !identidad.contains(_searchQuery)) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron resultados para la búsqueda.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    return ref.refresh(empleadosProvider.future);
                  },
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                    itemBuilder: (context, index) {
                      final emp = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: emp.foto != null
                              ? NetworkImage('${ApiConstants.baseUrl}${emp.foto}')
                              : null,
                          child: emp.foto == null
                              ? Text(
                                  emp.nombre.isNotEmpty ? emp.nombre[0].toUpperCase() : 'U',
                                  style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Text(
                          emp.nombreCompleto,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Código: ${emp.codigoEmpleado ?? 'N/A'} | ID: ${emp.identidad ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    emp.tipoContrato ?? 'Permanente',
                                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (emp.estado == 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Activo',
                                      style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Inactivo',
                                      style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        onTap: () {
                          context.push('/empleado', extra: emp);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}