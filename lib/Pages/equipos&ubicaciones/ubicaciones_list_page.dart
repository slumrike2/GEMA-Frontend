import 'package:flutter/material.dart';
import '../../Models/backend_types.dart';
import 'package:frontend/Components/tag.dart';

class UbicacionesListPage extends StatelessWidget {
  final List<TechnicalLocation> currentPossibleLocations;
  final List<TechnicalLocation> selectedLocations;
  final void Function(TechnicalLocation) onSelectLocation;
  final void Function(TechnicalLocation) onRemoveLocation;
  final List<Equipment> currentEquipments;
  final VoidCallback? onCreateLocation;

  const UbicacionesListPage({
    super.key,
    required this.currentPossibleLocations,
    required this.selectedLocations,
    required this.onSelectLocation,
    required this.onRemoveLocation,
    required this.currentEquipments,
    this.onCreateLocation,
  });

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
              onPressed: onCreateLocation,
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
                  onRemove: () => onRemoveLocation(loc),
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
