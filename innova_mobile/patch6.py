import re

file_path = r'c:\Users\danie\Documents\INNOVA\Proyecto\innova_mobile\lib\features\empleados\screens\empleado_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the Card content inside _buildContratosTab
old_card = '''                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fila de Título y Estado
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text(contrato.tipoContrato, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                Chip(
                                  label: Text(contrato.estado),
                                  backgroundColor: isActivo ? Colors.green.shade50 : Colors.grey.shade100,
                                  labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActivo ? Colors.green.shade800 : Colors.grey.shade700),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // Fila de Fechas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildDetailColumn('Fecha Inicio', _formatDate(contrato.fechaInicio))),
                                Expanded(child: _buildDetailColumn('Fecha Fin', contrato.fechaFin != null ? _formatDate(contrato.fechaFin!) : 'N/A', align: CrossAxisAlignment.center)),
                                Expanded(child: _buildDetailColumn('Fecha Salida', contrato.fechaSalida != null ? _formatDate(contrato.fechaSalida!) : 'N/A', align: CrossAxisAlignment.end)),
                              ],
                            ),
                            // Observaciones y Archivo
                            if (contrato.notas?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              _buildDetailColumn('Observación', contrato.notas!),
                            ],
                            if (contrato.archivo?.isNotEmpty == true) ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse('${ApiConstants.baseUrl}${contrato.archivo}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No se pudo abrir el documento.')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.attach_file, size: 16),
                                label: const Text('Ver Documento Adjunto'),
                              )
                            ]
                          ],
                        ),
                      ),'''

new_card = """                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Status, Edit Button and Creators
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            border: Border.all(color: Colors.grey.shade200),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            contrato.tipoContrato.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isActivo ? Colors.green.shade50 : Colors.red.shade50,
                                            border: Border.all(color: isActivo ? Colors.green.shade200 : Colors.red.shade200),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            contrato.estado.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActivo ? Colors.green.shade700 : Colors.red.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        border: Border.all(color: Colors.grey.shade200),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                              children: [
                                                const TextSpan(text: 'CREADO POR: '),
                                                TextSpan(text: (contrato.creadoPorNombre ?? 'Admin').toUpperCase(), style: const TextStyle(color: Colors.black54)),
                                                const TextSpan(text: '  |  FECHA: '),
                                                TextSpan(text: _formatDate(contrato.fechaCreacion), style: const TextStyle(color: Colors.black54)),
                                              ],
                                            ),
                                          ),
                                          if (contrato.fechaModificacion != null && contrato.fechaModificacion != contrato.fechaCreacion) ...[
                                            const SizedBox(height: 2),
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                                children: [
                                                  const TextSpan(text: 'MODIFICADO: '),
                                                  TextSpan(text: (contrato.modificadoPorNombre ?? contrato.creadoPorNombre ?? 'S/D').toUpperCase(), style: const TextStyle(color: Colors.black54)),
                                                  const TextSpan(text: '  |  FECHA: '),
                                                  TextSpan(text: _formatDate(contrato.fechaModificacion!), style: const TextStyle(color: Colors.black54)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        // TODO: Pass contrato object when editing via Map
                                        context.push('/nuevo-contrato', extra: {'empleadoId': empleado.id, 'contrato': contrato});
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          border: Border.all(color: Colors.blue.shade100),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.edit, size: 16, color: Colors.blue.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Fila de Fechas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _buildDetailColumn('Fecha Inicio', _formatDate(contrato.fechaInicio))),
                                Expanded(child: _buildDetailColumn('Fecha Fin', contrato.fechaFin != null ? _formatDate(contrato.fechaFin!) : 'N/A', align: CrossAxisAlignment.center)),
                                Expanded(child: _buildDetailColumn('Fecha Salida', contrato.fechaSalida != null ? _formatDate(contrato.fechaSalida!) : 'S/D', align: CrossAxisAlignment.end)),
                              ],
                            ),
                            // Observaciones y Archivo
                            if (contrato.notas?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('OBSERVACIÓN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text(contrato.notas!, style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                            ],
                            if (contrato.archivo?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse('${ApiConstants.baseUrl}${contrato.archivo}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No se pudo abrir el documento.')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.attach_file, size: 14),
                                label: const Text('Ver Documento Adjunto'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade800,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),"""

if old_card in content:
    content = content.replace(old_card, new_card)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Patched successfully!")
else:
    print("Failed to find old card!")
