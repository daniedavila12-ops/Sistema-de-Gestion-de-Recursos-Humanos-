
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:innova_mobile/core/api/api_client.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
import '../providers/candidatos_provider.dart';

class ReclutamientoScreen extends ConsumerStatefulWidget {
  const ReclutamientoScreen({super.key});

  @override
  ConsumerState<ReclutamientoScreen> createState() => _ReclutamientoScreenState();
}

class _ReclutamientoScreenState extends ConsumerState<ReclutamientoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(candidatosProvider.notifier).fetchCandidatos());
  }

  Future<void> _abrirCV(String path) async {
    String normalizedPath = path.replaceAll('\\', '/');
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }
    final url = '${ApiConstants.baseUrl}$normalizedPath';
    
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descargando archivo...'), duration: Duration(seconds: 1))
        );
      }
      
      final tempDir = await getTemporaryDirectory();
      final fileName = normalizedPath.split('/').last;
      final savePath = '${tempDir.path}/$fileName';
      
      await apiClient.download(url, savePath);
      
      final result = await OpenFile.open(savePath);
      
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el archivo PDF: ${result.message}'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al descargar el archivo: $e')));
      }
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'Recibido':
        return Colors.blue.shade100;
      case 'Entrevista':
        return Colors.amber.shade100;
      case 'Descartado':
        return Colors.red.shade100;
      case 'Contratado':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColorEstado(String estado) {
    switch (estado) {
      case 'Recibido':
        return Colors.blue.shade800;
      case 'Entrevista':
        return Colors.amber.shade800;
      case 'Descartado':
        return Colors.red.shade800;
      case 'Contratado':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(candidatosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Candidatos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(candidatosProvider.notifier).fetchCandidatos(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(candidatosProvider.notifier).fetchCandidatos(),
                        child: const Text('Reintentar'),
                      )
                    ],
                  ),
                )
              : state.candidatos.isEmpty
                  ? const Center(
                      child: Text('No hay candidatos registrados.', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(candidatosProvider.notifier).fetchCandidatos(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.candidatos.length,
                        itemBuilder: (context, index) {
                          final candidato = state.candidatos[index];
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          candidato.nombreCompleto,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getColorEstado(candidato.estado),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: ['Recibido', 'Entrevista', 'Descartado', 'Contratado'].contains(candidato.estado) ? candidato.estado : 'Recibido',
                                            icon: Icon(Icons.arrow_drop_down, color: _getTextColorEstado(candidato.estado)),
                                            style: TextStyle(color: _getTextColorEstado(candidato.estado), fontWeight: FontWeight.bold, fontSize: 12),
                                            isDense: true,
                                            onChanged: (String? newValue) async {
                                              if (newValue != null && newValue != candidato.estado) {
                                                final success = await ref.read(candidatosProvider.notifier).actualizarEstado(candidato.id, newValue);
                                                if (success && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado'), backgroundColor: Colors.green));
                                                } else if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar estado'), backgroundColor: Colors.red));
                                                }
                                              }
                                            },
                                            items: <String>['Recibido', 'Entrevista', 'Descartado', 'Contratado'].map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Puesto: ${candidato.puestoAplicado}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 14, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () async {
                                          final Uri emailLaunchUri = Uri(
                                            scheme: 'mailto',
                                            path: candidato.correo,
                                          );
                                          if (!await launchUrl(emailLaunchUri)) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se pudo abrir el correo'), backgroundColor: Colors.red),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          candidato.correo,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(candidato.telefono, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () async {
                                          final Uri phoneLaunchUri = Uri(
                                            scheme: 'tel',
                                            path: candidato.telefono,
                                          );
                                          if (!await launchUrl(phoneLaunchUri)) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se pudo realizar la llamada'), backgroundColor: Colors.red),
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.phone_outlined, size: 16, color: Colors.blue),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () async {
                                          String phone = candidato.telefono.replaceAll(RegExp(r'[^\d+]'), '');
                                          final Uri waLaunchUri = Uri.parse('https://wa.me/$phone');
                                          if (!await launchUrl(waLaunchUri, mode: LaunchMode.externalApplication)) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('No se pudo abrir WhatsApp'), backgroundColor: Colors.red),
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.chat_outlined, size: 16, color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (candidato.createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${candidato.createdAt!.day}/${candidato.createdAt!.month}/${candidato.createdAt!.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                                      label: const Text('Ver Currículum (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue.shade700,
                                        side: BorderSide(color: Colors.blue.shade200),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => _abrirCV(candidato.cvUrl),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
