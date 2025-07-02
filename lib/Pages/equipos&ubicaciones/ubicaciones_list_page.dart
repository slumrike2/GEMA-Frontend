import 'package:flutter/material.dart';
import '../../Models/backend_types.dart';
import 'package:frontend/Components/tag.dart';
import '../../Services/technical_location_service.dart';
import '../../Services/equipment_service.dart';

class UbicacionesListPage extends StatelessWidget {
  final List<TechnicalLocation> allLocations;
  final List<TechnicalLocation> selectedLocations;
  final void Function(TechnicalLocation) onSelectLocation;
  final void Function(TechnicalLocation) onRemoveLocation;
  final List<Equipment> currentEquipments;

  const UbicacionesListPage({
    super.key,
    required this.allLocations,
    required this.selectedLocations,
    required this.onSelectLocation,
    required this.onRemoveLocation,
    required this.currentEquipments,
  });

  List<TechnicalLocation> get currentPossibleLocations {
    if (selectedLocations.isEmpty) {
      return allLocations
          .where((l) => l.parentTechnicalCode == 'root')
          .toList();
    } else {
      return allLocations
          .where(
            (l) =>
                l.parentTechnicalCode == selectedLocations.last.technicalCode,
          )
          .toList();
    }
  }

  Future<void> _createLocation(BuildContext context) async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final typeController = TextEditingController();
    final parentController = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Crear Nueva Ubicación Técnica'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código Técnico',
                  ),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Tipo (número)'),
                ),
                TextField(
                  controller: parentController,
                  decoration: const InputDecoration(labelText: 'Código Padre'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newLoc = TechnicalLocation(
                    technicalCode: codeController.text,
                    name: nameController.text,
                    type: int.tryParse(typeController.text) ?? 0,
                    parentTechnicalCode: parentController.text,
                  );
                  await TechnicalLocationService.create(newLoc.toJson());
                  Navigator.of(context).pop();
                },
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ubicaciones Técnicas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            ElevatedButton(
              onPressed: () => _createLocation(context),
              child: const Text('Crear Ubicación'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ...selectedLocations.map(
              (loc) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tag(
                  label: loc.name,
                  onRemove: () async {
                    await TechnicalLocationService.delete(loc.technicalCode);
                    onRemoveLocation(loc);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Ubicaciones Hijas',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...currentPossibleLocations.map(
                    (loc) => Tag(
                      label: loc.name,
                      onTap: () => onSelectLocation(loc),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Equipos',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [...currentEquipments.map((e) => Tag(label: e.name))],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
