import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';

enum DeleteTypeAction { cascade, moveToOtherType, keepAndEditLater }

class DeleteTypeDialog extends StatefulWidget {
  final LocationType type;
  final int locationCount;
  final List<LocationType> otherTypes;
  final List<String> locationsToDelete;
  final void Function(DeleteTypeAction action, LocationType? selectedType)
  onDelete;

  const DeleteTypeDialog({
    Key? key,
    required this.type,
    required this.locationCount,
    required this.otherTypes,
    required this.locationsToDelete,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DeleteTypeDialog> createState() => _DeleteTypeDialogState();
}

class _DeleteTypeDialogState extends State<DeleteTypeDialog> {
  DeleteTypeAction action = DeleteTypeAction.cascade;
  LocationType? selectedType;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar Tipo de Ubicación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Seguro que deseas eliminar el tipo "${widget.type.name}"?'),
          const SizedBox(height: 12),
          if (widget.locationCount > 0) ...[
            Text('Ubicaciones asociadas a este tipo:'),
            const SizedBox(height: 6),
            Text(
              'Total: ${widget.locationCount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('¿Qué deseas hacer con estas ubicaciones?'),
            const SizedBox(height: 6),
            RadioListTile<DeleteTypeAction>(
              value: DeleteTypeAction.cascade,
              groupValue: action,
              onChanged: (v) => setState(() => action = v!),
              title: const Text(
                'Eliminar en cascada (se eliminarán todas las ubicaciones listadas)',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.locationsToDelete
                      .take(5)
                      .map((loc) => Text('• $loc')),
                  if (widget.locationsToDelete.length > 5)
                    Text('...y ${widget.locationsToDelete.length - 5} más'),
                ],
              ),
            ),
            RadioListTile<DeleteTypeAction>(
              value: DeleteTypeAction.moveToOtherType,
              groupValue: action,
              onChanged: (v) => setState(() => action = v!),
              title: const Text('Mover a otro tipo'),
              subtitle: Row(
                children: [
                  DropdownButton<LocationType>(
                    value: selectedType,
                    hint: const Text('Selecciona tipo'),
                    items:
                        widget.otherTypes
                            .map(
                              (t) => DropdownMenuItem<LocationType>(
                                value: t,
                                child: Text(t.name),
                              ),
                            )
                            .toList(),
                    onChanged: (t) => setState(() => selectedType = t),
                  ),
                ],
              ),
            ),
            RadioListTile<DeleteTypeAction>(
              value: DeleteTypeAction.keepAndEditLater,
              groupValue: action,
              onChanged: (v) => setState(() => action = v!),
              title: const Text('Mantener y cambiar individualmente después'),
              subtitle: const Text(
                'Las ubicaciones quedarán sin tipo y deberás asignarles uno manualmente más tarde.',
              ),
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
            widget.onDelete(action, selectedType);
            Navigator.of(context).pop();
          },
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
