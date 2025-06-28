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
  final String state;
  Equipment({
    required this.name,
    required this.locationCode,
    required this.state,
  });
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
  Equipment(name: 'Bombillo-1', locationCode: 'MD2-21', state: 'installed'),
  Equipment(name: 'Bombillo-2', locationCode: 'MD2-22', state: 'in_stock'),
  Equipment(
    name: 'Bombillo-3',
    locationCode: 'MD2-23',
    state: 'maintenance_pending',
  ),
  Equipment(name: 'Cam-1', locationCode: 'MD2-24', state: 'in_maintenance'),
  Equipment(name: 'Cam-2', locationCode: 'MD2-25', state: 'installed'),
  Equipment(name: 'Cam-3', locationCode: 'MD2-28', state: 'in_stock'),
  Equipment(name: 'Cam-4', locationCode: 'MD2-27', state: 'decommissioned'),
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

class _InicioEquiposUbicacionesState extends State<InicioEquiposUbicaciones>
    with SingleTickerProviderStateMixin {
  int selectedSection = 0; // 0: Ubicaciones, 1: Equipos
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

  // Equipment management state
  List<Equipment> equipmentList = List.from(mockEquipments);
  Equipment? editingEquipment;
  final _equipmentNameController = TextEditingController();
  final _equipmentLocationController = TextEditingController();

  void onCreateEquipment() {
    setState(() {
      equipmentList.add(
        Equipment(
          name: _equipmentNameController.text,
          locationCode: _equipmentLocationController.text,
          state: 'in_stock', // Default state
        ),
      );
      _equipmentNameController.clear();
      _equipmentLocationController.clear();
    });
  }

  void onDeleteEquipment(Equipment eq) {
    setState(() {
      equipmentList.remove(eq);
    });
  }

  void onAssignEquipment(Equipment eq, String newLocation) {
    setState(() {
      int idx = equipmentList.indexOf(eq);
      if (idx != -1) {
        equipmentList[idx] = Equipment(
          name: eq.name,
          locationCode: newLocation,
          state: eq.state,
        );
      }
    });
  }

  @override
  void dispose() {
    _equipmentNameController.dispose();
    _equipmentLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Ubicaciones'),
                  selected: selectedSection == 0,
                  onSelected: (_) => setState(() => selectedSection = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Equipos'),
                  selected: selectedSection == 1,
                  onSelected: (_) => setState(() => selectedSection = 1),
                ),
              ],
            ),
          ),
          if (selectedSection == 0) ...[
            // Ubicaciones section (existing)
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
                              ...currentEquipments.map(
                                (e) => Tag(label: e.name),
                              ),
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
                        const _ActionButton(text: 'Ver Mantenimientos'),
                        const SizedBox(width: 8),
                        const _ActionButton(text: 'Modificar'),
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
          ] else ...[
            // Equipos section (custom tile list with hover effect)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gestión de Equipos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Crear Nuevo Equipo'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _equipmentNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre',
                                          ),
                                        ),
                                        TextField(
                                          controller:
                                              _equipmentLocationController,
                                          decoration: const InputDecoration(
                                            labelText: 'Código de Ubicación',
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          onCreateEquipment();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Crear'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: const Text('Crear Equipo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: equipmentList.length,
                      itemBuilder: (context, idx) {
                        final e = equipmentList[idx];
                        return _EquipmentTile(
                          equipment: e,
                          onDelete: () => onDeleteEquipment(e),
                          onEdit: () {
                            _equipmentNameController.text = e.name;
                            _equipmentLocationController.text = e.locationCode;
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Editar Equipo'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _equipmentNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre',
                                          ),
                                        ),
                                        TextField(
                                          controller:
                                              _equipmentLocationController,
                                          decoration: const InputDecoration(
                                            labelText: 'Código de Ubicación',
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            int idx2 = equipmentList.indexOf(e);
                                            if (idx2 != -1) {
                                              equipmentList[idx2] = Equipment(
                                                name:
                                                    _equipmentNameController
                                                        .text,
                                                locationCode:
                                                    _equipmentLocationController
                                                        .text,
                                                state: e.state,
                                              );
                                            }
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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

class _EquipmentTile extends StatefulWidget {
  final Equipment equipment;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _EquipmentTile({
    required this.equipment,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_EquipmentTile> createState() => _EquipmentTileState();
}

class _EquipmentTileState extends State<_EquipmentTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.equipment.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Tag(label: widget.equipment.locationCode),
                        const SizedBox(width: 8),
                        Tag(label: widget.equipment.state),
                      ],
                    ),
                  ),
                ),
                // The sliding green area with icons, full height
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _hovering ? 96 : 0,
                  // Remove fixed height, use constraints to fill vertically
                  child: _hovering
                      ? SizedBox.expand(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: widget.onEdit,
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: widget.onDelete,
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            // Animated green border, full height
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              right: 0,
              top: 0,
              bottom: 0,
              width: _hovering ? 6 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
