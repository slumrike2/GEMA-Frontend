import 'package:flutter/material.dart' hide SearchBar;
import '../../Models/backend_types.dart';
import 'package:frontend/Components/tag.dart';
import 'package:frontend/Components/search_bar.dart';
import 'package:frontend/Components/action_button.dart';
import 'package:frontend/Services/equipment_service.dart';

class EquiposListPage extends StatefulWidget {
  final void Function(Equipment) onDeleteEquipment;
  final void Function(
    Equipment, {
    required bool isOperational,
    required String locationCode,
  })
  onAssignEquipment;
  final void Function(Equipment) onEditEquipment;
  final VoidCallback onCreateEquipment;
  final VoidCallback onCreateMarca; // NEW
  final List<Equipment> equipments;
  final List<Brand> brands;
  final List<TechnicalLocation> operationalLocations;
  final TechnicalLocation? selectedLocation;

  const EquiposListPage({
    super.key,
    required this.onDeleteEquipment,
    required this.onAssignEquipment,
    required this.onEditEquipment,
    required this.onCreateEquipment,
    required this.onCreateMarca, // NEW
    required this.equipments,
    required this.brands,
    this.operationalLocations = const [],
    this.selectedLocation,
  });

  @override
  _EquiposListPageState createState() => _EquiposListPageState();
}

class _EquiposListPageState extends State<EquiposListPage> {
  Equipment? _changingStateEquipment;
  bool _showChangeStateModal = false;

  void _onChangeEquipmentState(Equipment equipment) {
    setState(() {
      _changingStateEquipment = equipment;
      _showChangeStateModal = true;
    });
  }

  Future<void> _handleSaveState(String newState) async {
    if (_changingStateEquipment == null) return;
    try {
      await EquipmentService.updateState(
        _changingStateEquipment!.uuid!,
        newState,
      );
      setState(() {
        _showChangeStateModal = false;
        _changingStateEquipment = null;
      });
      // Refetch or update the equipment list after state change
      widget.onEditEquipment(_changingStateEquipment!);
    } catch (e) {
      setState(() {
        _showChangeStateModal = false;
        _changingStateEquipment = null;
      });
    }
  }

  int? _expandedIdx;
  String _search = '';
  // Mapa para almacenar las ubicaciones operativas de cada equipo
  final Map<String, List<String>> _operationalLocationsMap = {};
  bool _loadingOperationalLocations = false;

  @override
  void initState() {
    super.initState();
    _fetchAllOperationalLocations();
  }

  @override
  void didUpdateWidget(covariant EquiposListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.equipments != widget.equipments) {
      _fetchAllOperationalLocations();
    }
  }

  Future<void> _fetchAllOperationalLocations() async {
    setState(() {
      _loadingOperationalLocations = true;
    });
    final Map<String, List<String>> newMap = {};
    for (final equipment in widget.equipments) {
      if (equipment.uuid != null) {
        try {
          final locations = await EquipmentService.getOperationalLocations(
            equipment.uuid!,
          );
          newMap[equipment.uuid!] = locations;
        } catch (_) {
          newMap[equipment.uuid!] = [];
        }
      }
    }
    setState(() {
      _operationalLocationsMap.clear();
      _operationalLocationsMap.addAll(newMap);
      _loadingOperationalLocations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredEquipments =
        widget.equipments.where((e) {
          final q = _search.toLowerCase();
          return e.name.toLowerCase().contains(q) ||
              e.technicalCode.toLowerCase().contains(q) ||
              e.serialNumber.toLowerCase().contains(q);
        }).toList();
    final bool hasLocation = widget.selectedLocation != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBar(
                    hintText: 'Buscar por nombre, código técnico o serie...',
                    onChanged: (v) => setState(() => _search = v),
                    initialValue: _search,
                  ),
                  const SizedBox(height: 12),
                  if (!hasLocation)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.yellow[700]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selecciona una ubicación en el panel izquierdo para habilitar la asignación de equipos.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child:
                        filteredEquipments.isEmpty
                            ? const Center(child: Text('No hay equipos.'))
                            : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              itemCount: filteredEquipments.length,
                              separatorBuilder:
                                  (context, idx) => const SizedBox(height: 18),
                              itemBuilder: (context, idx) {
                                final equipment = filteredEquipments[idx];
                                final operationalCodes =
                                    _operationalLocationsMap[equipment.uuid] ??
                                    [];
                                return _EquipmentTile(
                                  equipment: equipment,
                                  isExpanded: _expandedIdx == idx,
                                  onTap:
                                      () => setState(() {
                                        _expandedIdx =
                                            _expandedIdx == idx ? null : idx;
                                      }),
                                  onDelete:
                                      () => widget.onDeleteEquipment(equipment),
                                  onEdit:
                                      () => widget.onEditEquipment(equipment),
                                  operationalLocationCodes: operationalCodes,
                                  dependants:
                                      widget.equipments
                                          .where(
                                            (eq) =>
                                                eq.dependsOn == equipment.uuid,
                                          )
                                          .toList(),
                                  dependsOf:
                                      widget.equipments
                                          .where(
                                            (eq) =>
                                                eq.uuid == equipment.dependsOn,
                                          )
                                          .toList(),
                                  selectedLocation: widget.selectedLocation,
                                  onAssignTechnical:
                                      hasLocation &&
                                              (equipment.technicalLocation ==
                                                      null ||
                                                  equipment
                                                      .technicalLocation!
                                                      .isEmpty)
                                          ? () {
                                            widget.onAssignEquipment(
                                              equipment,
                                              isOperational: false,
                                              locationCode:
                                                  widget
                                                      .selectedLocation
                                                      ?.technicalCode ??
                                                  '',
                                            );
                                          }
                                          : null,
                                  onAssignOperational:
                                      hasLocation
                                          ? () {
                                            widget.onAssignEquipment(
                                              equipment,
                                              isOperational: true,
                                              locationCode:
                                                  widget
                                                      .selectedLocation
                                                      ?.technicalCode ??
                                                  '',
                                            );
                                          }
                                          : null,
                                  onChangeEquipmentState:
                                      _onChangeEquipmentState,
                                );
                              },
                            ),
                  ),

                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Crear Equipo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: widget.onCreateEquipment,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_business, color: Colors.blue),
                    label: const Text('Crear Marca'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: widget.onCreateMarca,
                  ),
                ],
              ),
            ),
            
          ],
        );
      },
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  final bool isExpanded;
  final List<String> operationalLocationCodes;
  final List<Equipment> dependants;
  final List<Equipment> dependsOf;
  final TechnicalLocation? selectedLocation;
  final VoidCallback? onAssignTechnical;
  final VoidCallback? onAssignOperational;
  final void Function(Equipment) onChangeEquipmentState;
  const _EquipmentTile({
    required this.equipment,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    required this.isExpanded,
    required this.operationalLocationCodes,
    required this.dependants,
    required this.dependsOf,
    required this.selectedLocation,
    this.onAssignTechnical,
    this.onAssignOperational,
    required this.onChangeEquipmentState,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
            boxShadow:
                isExpanded
                    ? [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                    : [],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                equipment.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              equipment.technicalLocation == null ||
                                      equipment.technicalLocation!.isEmpty
                                  ? Tag(
                                    label: 'Sin ubicación',
                                    color: Colors.red,
                                  )
                                  : Tag(label: equipment.technicalLocation!),
                              const SizedBox(width: 8),
                              Tag(
                                label:
                                    equipment.state != null
                                        ? equipment.state!.name.replaceAll(
                                          '_',
                                          ' ',
                                        )
                                        : '',
                              ),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Container(),
                              ), // Push buttons to the right

                              if (onAssignTechnical != null)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    message:
                                        'Asignar este equipo a la ubicación actual',
                                    child: GestureDetector(
                                      onTap: onAssignTechnical,
                                      child: Tag(
                                        label: '',
                                        iconData: Icons.location_on,
                                        color: Colors.blue,
                                        onTap: onAssignTechnical,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),

                              if (equipment.technicalLocation != null &&
                                  equipment.technicalLocation!.isNotEmpty)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    message: 'Mudar equipo a otra ubicación',
                                    child: GestureDetector(
                                      onTap: () {
                                        //!TODO: Implementar lógica de mudanza
                                      },
                                      child: Tag(
                                        label: '',
                                        iconData: Icons.local_shipping,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              if (onAssignOperational != null)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                    message:
                                        'Asignar este equipo como operativo en la ubicación actual',
                                    child: GestureDetector(
                                      onTap: onAssignOperational,
                                      child: Tag(
                                        label: '',
                                        iconData: Icons.link,
                                        color: Colors.blue,
                                        onTap: onAssignOperational,
                                      ),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre: ${equipment.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Código técnico: ${equipment.technicalCode}'),
                        Text(
                          'Ubicación principal: ${equipment.technicalLocation ?? "Sin ubicación"}',
                        ),
                        Text(
                          'Código ubicación: ${equipment.technicalLocation ?? "-"}',
                        ),
                        const SizedBox(height: 4),
                        Text('Ubicaciones operativas:'),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final code in operationalLocationCodes)
                              Chip(label: Text(code)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Dependientes:'),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (int i = 0; i < dependants.length; i++)
                              Chip(
                                label: Text(
                                  '${dependants[i].name} (${dependants[i].technicalCode})',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Depende de:'),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final dep in dependsOf)
                              Chip(
                                label: Text(
                                  '${dep.name} (${dep.technicalCode})',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estado: ${equipment.state != null ? equipment.state!.name.replaceAll('_', ' ') : "-"}',
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ActionButton(
                              icon: Icons.edit,
                              label: 'Editar',
                              backgroundColor: Colors.green[600]!,
                              onPressed: onEdit,
                            ),
                            const SizedBox(width: 8),
                            ActionButton(
                              icon: Icons.delete,
                              label: 'Eliminar',
                              backgroundColor: Colors.red,
                              onPressed: onDelete,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
