// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import '../models/documento_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentoCard extends StatelessWidget {
  final Documento documento;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String apiBaseUrl; // To construct full URLs if needed

  const DocumentoCard({
    super.key,
    required this.documento,
    required this.onEdit,
    required this.onDelete,
    required this.apiBaseUrl,
  });

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.tryParse(urlString);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Intento concatenar base url si es un path relativo
      if (urlString.startsWith('/')) {
        final fullUrl = Uri.tryParse('$apiBaseUrl$urlString');
        if (fullUrl != null && await canLaunchUrl(fullUrl)) {
          await launchUrl(fullUrl, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.amber.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Superior Ámbar
          Container(
            height: 6,
            color: Colors.amber.shade600,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (documento.categoria.isNotEmpty ? documento.categoria : 'General').toUpperCase(),
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // Acciones
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          color: Colors.blue.shade400,
                          onPressed: onEdit,
                          tooltip: 'Editar',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red.shade400,
                          onPressed: onDelete,
                          tooltip: 'Eliminar',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Título
                Text(
                  documento.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Descripción
                Text(
                  documento.descripcion.isNotEmpty ? documento.descripcion : 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Meta info (Fechas, creador)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subido: ${documento.fechaCreacion}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    if (documento.creadoPorNombre.isNotEmpty)
                      Text(
                        'Por: ${documento.creadoPorNombre}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // --- BOTONES DE DESCARGA / LINKS ---
                
                // Archivo Legacy
                if (documento.archivoLegacy != null && documento.archivoLegacy!.isNotEmpty && documento.archivos.isEmpty)
                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Descargar (Legacy)',
                    subtitle: documento.tamanoLegacy ?? '',
                    color: Colors.blue.shade700,
                    onTap: () => _launchUrl(documento.archivoLegacy!),
                  ),
                
                // Archivos
                ...documento.archivos.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var arch = entry.value;
                  return _buildActionButton(
                    icon: Icons.download,
                    label: 'Archivo ${idx + 1}',
                    subtitle: arch.tamano,
                    color: Colors.blue.shade700,
                    onTap: () => _launchUrl(arch.archivoUrl),
                  );
                }),

                // Link Legacy
                if (documento.linkLegacy != null && documento.linkLegacy!.isNotEmpty && documento.links.isEmpty)
                  _buildActionButton(
                    icon: Icons.link,
                    label: 'Link (Legacy)',
                    color: Colors.blue.shade600,
                    onTap: () => _launchUrl(documento.linkLegacy!),
                  ),

                // Links
                ...documento.links.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var link = entry.value;
                  return _buildActionButton(
                    icon: Icons.link,
                    label: 'Link ${idx + 1}',
                    color: Colors.blue.shade600,
                    onTap: () => _launchUrl(link.linkUrl),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String subtitle = '',
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
