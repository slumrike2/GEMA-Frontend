import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';

class DeleteBrandDialog extends StatefulWidget {
  final Brand brand;
  final int equipmentCount;
  final List<Brand> otherBrands;
  final void Function(bool moveToNoMarca, Brand? selectedBrand) onDelete;

  const DeleteBrandDialog({
    Key? key,
    required this.brand,
    required this.equipmentCount,
    required this.otherBrands,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DeleteBrandDialog> createState() => _DeleteBrandDialogState();
}

class _DeleteBrandDialogState extends State<DeleteBrandDialog> {
  Brand? selectedBrand;
  bool moveToNoMarca = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar Marca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Seguro que deseas eliminar la marca "${widget.brand.name}"?'),
          const SizedBox(height: 12),
          if (widget.equipmentCount > 0) ...[
            Text('Equipos asociados a esta marca:'),
            const SizedBox(height: 6),
            Text(
              'Total: ${widget.equipmentCount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('¿Qué deseas hacer con estos equipos?'),
            const SizedBox(height: 6),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: moveToNoMarca,
                  onChanged: (v) => setState(() => moveToNoMarca = v ?? true),
                ),
                const Text('Mover a "Sin Marca"'),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: false,
                  groupValue: moveToNoMarca,
                  onChanged: (v) => setState(() => moveToNoMarca = v ?? true),
                ),
                const Text('Mover a otra marca:'),
                const SizedBox(width: 8),
                if (!moveToNoMarca)
                  DropdownButton<Brand>(
                    value: selectedBrand,
                    hint: const Text('Selecciona'),
                    items:
                        widget.otherBrands
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(b.name),
                              ),
                            )
                            .toList(),
                    onChanged: (b) => setState(() => selectedBrand = b),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            widget.onDelete(moveToNoMarca, selectedBrand);
            Navigator.of(context).pop();
          },
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
