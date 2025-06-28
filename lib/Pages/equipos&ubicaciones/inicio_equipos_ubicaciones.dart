import 'package:flutter/material.dart';
import 'package:frontend/Components/tag.dart';

// Mock data for technical locations and equipments
class TechnicalLocation {
  final String technicalCode;
  final String name;
  final String? parentTechnicalCode;
  TechnicalLocation({
    required this.technicalCode,
    required this.name,
    this.parentTechnicalCode,
  });
}

class Equipment {
  final String name;
  final String locationCode;
  Equipment({required this.name, required this.locationCode});
}

final List<TechnicalLocation> mockLocations = [
  TechnicalLocation(
    technicalCode: 'root',
    name: 'Planta',
    parentTechnicalCode: null,
  ),
  TechnicalLocation(
    technicalCode: 'MD2',
    name: 'Módulo 2',
    parentTechnicalCode: 'root',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-2',
    name: 'Piso 2',
    parentTechnicalCode: 'MD2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-21',
    name: 'MD2-21',
    parentTechnicalCode: 'MD2-2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-22',
    name: 'MD2-22',
    parentTechnicalCode: 'MD2-2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-23',
    name: 'MD2-23',
    parentTechnicalCode: 'MD2-2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-24',
    name: 'MD2-24',
    parentTechnicalCode: 'MD2-2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-25',
    name: 'MD2-25',
    parentTechnicalCode: 'MD2-2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-28',
    name: 'MD2-28',
    parentTechnicalCode: 'MD2-2',
  ),
  TechnicalLocation(
    technicalCode: 'MD2-27',
    name: 'MD2-27',
    parentTechnicalCode: 'MD2-2',
  ),
];

final List<Equipment> mockEquipments = [
  Equipment(name: 'Bombillo-1', locationCode: 'MD2-21'),
  Equipment(name: 'Bombillo-2', locationCode: 'MD2-22'),
  Equipment(name: 'Bombillo-3', locationCode: 'MD2-23'),
  Equipment(name: 'Cam-1', locationCode: 'MD2-24'),
  Equipment(name: 'Cam-2', locationCode: 'MD2-25'),
  Equipment(name: 'Cam-3', locationCode: 'MD2-28'),
  Equipment(name: 'Cam-4', locationCode: 'MD2-27'),
];

class InicioEquiposUbicaciones extends StatefulWidget {
  final VoidCallback? onCrearEquipo;
  final VoidCallback? onCrearUbicacion;
  const InicioEquiposUbicaciones({
    super.key,
    this.onCrearEquipo,
    this.onCrearUbicacion,
  });

  @override
  State<InicioEquiposUbicaciones> createState() =>
      _InicioEquiposUbicacionesState();
}

class _InicioEquiposUbicacionesState extends State<InicioEquiposUbicaciones> {
  List<TechnicalLocation> selectedLocations = [];

  List<TechnicalLocation> get currentPossibleLocations {
    if (selectedLocations.isEmpty) {
      // Show root children
      return mockLocations
          .where((l) => l.parentTechnicalCode == 'root')
          .toList();
    } else {
      // Show children of the last selected location
      return mockLocations
          .where(
            (l) =>
                l.parentTechnicalCode == selectedLocations.last.technicalCode,
          )
          .toList();
    }
  }

  List<Equipment> get currentEquipments {
    if (selectedLocations.isEmpty) return [];
    return mockEquipments
        .where((e) => e.locationCode == selectedLocations.last.technicalCode)
        .toList();
  }

  void onSelectLocation(TechnicalLocation loc) {
    setState(() {
      selectedLocations.add(loc);
    });
  }

  void onRemoveLocation(TechnicalLocation loc) {
    setState(() {
      int idx = selectedLocations.indexOf(loc);
      if (idx != -1) {
        selectedLocations = selectedLocations.sublist(0, idx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Ubicaciones Técnicas y Equipos',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filtros (selected locations)
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
                // Ubicaciones Hijas y Equipos
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
                        children: [
                          ...currentEquipments.map((e) => Tag(label: e.name)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(text: 'Ver Mantenimientos'),
                    const SizedBox(width: 8),
                    _ActionButton(text: 'Modificar'),
                    const SizedBox(width: 8),
                    _ActionButton(
                      text: 'Crear Nuevo Equipo',
                      onPressed: widget.onCrearEquipo,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      text: 'Crear Nueva Ubicación',
                      onPressed: widget.onCrearUbicacion,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const _ActionButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed ?? () {},
      child: Text(text),
    );
  }
}
