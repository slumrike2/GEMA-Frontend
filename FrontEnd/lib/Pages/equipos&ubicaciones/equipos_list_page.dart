import 'package:flutter/material.dart' hide SearchBar;
import '../../Models/backend_types.dart';
import 'package:frontend/Components/tag.dart';
import 'package:frontend/Components/search_bar.dart';
import 'package:frontend/Components/action_button.dart';
import 'package:frontend/Services/equipment_service.dart';
//import 'package:frontend/Modals/change_equipment_state_modal.dart';
import 'package:frontend/Modals/confirm_delete_equipment_modal.dart';

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
  //Equipment? _changingStateEquipment;
  //bool _showChangeStateModal = false;

  //Para eliminar
  Equipment? _deletingEquipment;
  bool _showDeleteModal = false;

  /*void _onChangeEquipmentState(Equipment equipment) {
    setState(() {
      _changingStateEquipment = equipment;
      _showChangeStateModal = true;
    });
  }*/

  /*Future<void> _handleSaveState(String newState) async {
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
  }*/

  void _onDeleteEquipmentRequest(Equipment equipment) {
    setState(() {
      _deletingEquipment = equipment;
      _showDeleteModal = true;
    });
  }

  void _confirmDeleteEquipment() {
    if (_deletingEquipment != null) {
      widget.onDeleteEquipment(_deletingEquipment!);
    }
    setState(() {
      _showDeleteModal = false;
      _deletingEquipment = null;
    });
  }

  void _cancelDeleteEquipment() {
    setState(() {
      _showDeleteModal = false;
      _deletingEquipment = null;
    });
  }

  // Función para construir la jerarquía de ubicaciones padre
  String _buildLocationHierarchy(String? locationCode) {
    if (locationCode == null || locationCode.isEmpty) return "-";
    
    List<String> hierarchy = [];
    String? currentCode = locationCode;
    
    while (currentCode != null && currentCode.isNotEmpty) {
      hierarchy.add(currentCode);
      // Buscar el padre de la ubicación actual
      final parentLocation = widget.operationalLocations.firstWhere(
        (loc) => loc.technicalCode == currentCode,
        orElse: () => TechnicalLocation(
          technicalCode: '',
          name: '',
          type: 0,
          parentTechnicalCode: null,
        ),
      );
      currentCode = parentLocation.parentTechnicalCode;
    }
    
    // Invertir la lista para mostrar desde la raíz hasta la ubicación actual
    hierarchy = hierarchy.reversed.toList();
    return hierarchy.join(" > ");
  }

  // Función para obtener el orden de prioridad de los estados
  int _getStatePriority(EquipmentState? state) {
    if (state == null) return 999; // Estados nulos al final
    
    switch (state) {
      case EquipmentState.instalado:
        return 0;
      case EquipmentState.en_mantenimiento:
        return 1;
      case EquipmentState.mantenimiento_pendiente:
        return 2;
      case EquipmentState.en_reparaciones:
        return 3;
      case EquipmentState.reparaciones_pendientes:
        return 4;
      case EquipmentState.en_inventario:
        return 5;
      case EquipmentState.descomisionado:
        return 6;
      case EquipmentState.transferencia_pendiente:
        return 7;
    }
  }

  // Función para ordenar equipos por estado y luego alfabéticamente
  List<Equipment> _sortEquipments(List<Equipment> equipments) {
    final sorted = List<Equipment>.from(equipments);
    sorted.sort((a, b) {
      // Primero ordenar por estado
      final stateA = _getStatePriority(a.state);
      final stateB = _getStatePriority(b.state);
      
      if (stateA != stateB) {
        return stateA.compareTo(stateB);
      }
      
      // Si tienen el mismo estado, ordenar alfabéticamente por nombre
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    
    return sorted;
  }

  int? _expandedIdx;
  String _search = '';
  bool _showAllEquipments = false; // Nuevo: controla si mostrar todos los equipos
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
      // Cerrar cualquier equipo expandido cuando se actualiza la lista
      setState(() {
        _expandedIdx = null;
      });
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
    // Filtrar equipos por ubicación seleccionada (si no se muestra todo)
    List<Equipment> locationFilteredEquipments = _showAllEquipments 
        ? widget.equipments 
        : widget.equipments.where((e) {
            if (widget.selectedLocation == null) {
              // Si no hay ubicación seleccionada, mostrar equipos sin ubicación
              return e.technicalLocation == null || e.technicalLocation!.isEmpty;
            }
            return e.technicalLocation == widget.selectedLocation!.technicalCode;
          }).toList();
    
    // Filtrar por búsqueda
    final filteredEquipments = locationFilteredEquipments.where((e) {
          final q = _search.toLowerCase();
          return e.name.toLowerCase().contains(q) ||
              e.technicalCode.toLowerCase().contains(q) ||
              e.serialNumber.toLowerCase().contains(q);
        }).toList();
    
    // Ordenar equipos por estado y luego alfabéticamente
    final sortedEquipments = _sortEquipments(filteredEquipments);
    
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
                  Row(
                    children: [
                      Expanded(
                        child: SearchBar(
                    hintText: 'Buscar por nombre, código técnico o serie...',
                    onChanged: (v) => setState(() => _search = v),
                    initialValue: _search,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _showAllEquipments,
                            onChanged: (value) {
                              setState(() {
                                _showAllEquipments = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Mostrar todo',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!hasLocation && !_showAllEquipments)
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
                              'Selecciona una ubicación en el panel superior para habilitar la asignación de equipos.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child:
                        sortedEquipments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.build,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _showAllEquipments 
                                          ? 'No hay equipos en el sistema.'
                                          : hasLocation
                                              ? 'No hay equipos en esta ubicación.'
                                              : 'No hay equipos sin ubicación asignada.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              itemCount: sortedEquipments.length,
                              separatorBuilder:
                                  (context, idx) => const SizedBox(height: 18),
                              itemBuilder: (context, idx) {
                                final equipment = sortedEquipments[idx];
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
                                      () => _onDeleteEquipmentRequest(equipment),
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
                                  onMoveEquipment:
                                      hasLocation &&
                                              equipment.technicalLocation != null &&
                                              equipment.technicalLocation!.isNotEmpty &&
                                              widget.selectedLocation != null &&
                                              equipment.technicalLocation != widget.selectedLocation!.technicalCode
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
                                  //onChangeEquipmentState:
                                      //_onChangeEquipmentState,
                                  buildLocationHierarchy: _buildLocationHierarchy,
                                  onDeleteRequest: _onDeleteEquipmentRequest,
                                );
                              },
                            ),
                  ),


                ],
              ),
            ),
            /*if (_showChangeStateModal && _changingStateEquipment != null)
              ChangeEquipmentStateModal(
                currentState: _changingStateEquipment!.state?.name ?? '',
                possibleStates:
                    EquipmentState.values.map((e) => e.name).toList(),
                onSave: _handleSaveState,
                onCancel:
                    () => setState(() {
                      _showChangeStateModal = false;
                      _changingStateEquipment = null;
                    }),
              ),*/
              //Mostrar modal de eliminacion de equipos
            if (_showDeleteModal && _deletingEquipment != null)
              ConfirmDeleteEquipmentModal(
                technicalCode: _deletingEquipment!.technicalCode,
                onConfirm: _confirmDeleteEquipment,
                onCancel: _cancelDeleteEquipment,
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
  final VoidCallback? onMoveEquipment; // Nuevo parámetro para mudar equipo
  //final void Function(Equipment) onChangeEquipmentState;
  final String Function(String?) buildLocationHierarchy;
  final void Function(Equipment) onDeleteRequest;
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
    this.onMoveEquipment,
    //required this.onChangeEquipmentState,
    required this.buildLocationHierarchy,
    required this.onDeleteRequest,
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
                              // Información del equipo (izquierda)
                              Expanded(
                                child: Row(
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
                                  ],
                                ),
                              ),
                              
                              // Botones de acción (derecha)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  if (onAssignTechnical != null) const SizedBox(width: 8),

                              if (equipment.technicalLocation != null &&
                                      equipment.technicalLocation!.isNotEmpty &&
                                      selectedLocation != null &&
                                      equipment.technicalLocation != selectedLocation!.technicalCode &&
                                      onMoveEquipment != null)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Tooltip(
                                        message: 'Mudar equipo a esta ubicación',
                                    child: GestureDetector(
                                          onTap: onMoveEquipment,
                                      child: Tag(
                                        label: '',
                                        iconData: Icons.local_shipping,
                                        color: Colors.blue,
                                            onTap: onMoveEquipment,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (equipment.technicalLocation != null &&
                                      equipment.technicalLocation!.isNotEmpty &&
                                      selectedLocation != null &&
                                      equipment.technicalLocation != selectedLocation!.technicalCode &&
                                      onMoveEquipment != null) const SizedBox(width: 8),

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
                                  if (onAssignOperational != null) const SizedBox(width: 8),

                                  // Icono de expandir
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.grey,
                                  ),
                                ],
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
                          'Código ubicación: ${buildLocationHierarchy(equipment.technicalLocation)}',
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
                              onPressed: () => onDeleteRequest(equipment),
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
