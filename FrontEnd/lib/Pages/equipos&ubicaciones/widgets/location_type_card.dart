import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';

class LocationTypeCard extends StatelessWidget {
  final LocationType type;
  final double cardPadding;
  final VoidCallback onDelete;

  const LocationTypeCard({
    Key? key,
    required this.type,
    required this.cardPadding,
    required this.onDelete,
  }) : super(key: key);

  Color getVariableTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue.shade100;
      case 'serial':
        return Colors.green.shade100;
      case 'select':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  String getVariableTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Texto';
      case 'serial':
        return 'Serial';
      case 'select':
        return 'Selección';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = type.fields ?? {};
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {},
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formato de Código',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.codeTemplate,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Formato de Nombre',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.nameTemplate,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Variables (${fields.length})',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            ...fields.entries.map((entry) {
              final v = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          v['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getVariableTypeColor(v['type'] ?? ''),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            getVariableTypeLabel(v['type'] ?? ''),
                            style: const TextStyle(),
                          ),
                        ),
                      ],
                    ),
                    if (v['defaultValue'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Por defecto: ${v['defaultValue']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    if (v['options'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Opciones: ${(v['options'] as List).join(", ")}',
                        ),
                      ),
                  ],
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Duplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
