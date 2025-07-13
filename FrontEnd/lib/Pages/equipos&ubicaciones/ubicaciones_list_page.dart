import 'package:flutter/material.dart';
import 'package:frontend/Components/search_bar.dart' as custom;
import '../../Models/backend_types.dart';
import 'package:frontend/Components/tag.dart';
import 'package:frontend/Components/action_button.dart';

class UbicacionesListPage extends StatelessWidget {
  final List<TechnicalLocation> currentPossibleLocations;
  final List<TechnicalLocation> selectedLocations;
  final void Function(TechnicalLocation) onSelectLocation;
  final void Function(TechnicalLocation) onRemoveLocation;
  final List<Equipment> currentEquipments;
  final List<Equipment> allEquipments;
  final VoidCallback onCreateLocation;
  final VoidCallback onCreateLocationType;

  const UbicacionesListPage({
    super.key,
    required this.currentPossibleLocations,
    required this.selectedLocations,
    required this.onSelectLocation,
    required this.onRemoveLocation,
    required this.currentEquipments,
    required this.allEquipments,
    required this.onCreateLocation,
    required this.onCreateLocationType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              custom.SearchBar(
                hintText: 'Buscar...',
                onChanged: (v) {
                  // TODO: Implement search/filter logic for locations if needed
                },
                initialValue: '',
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Equipos',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ActionButton(
                icon: Icons.add,
                label: 'Crear Ubicación',
                backgroundColor: Colors.green,
                onPressed: onCreateLocation,
              ),
              const SizedBox(height: 8),
              ActionButton(
                icon: Icons.category,
                label: 'Crear Tipo de Ubicación',
                backgroundColor: Colors.blue,
                onPressed: onCreateLocationType,
              ),
            ],
          ),
        );
      },
    );
  }
}
