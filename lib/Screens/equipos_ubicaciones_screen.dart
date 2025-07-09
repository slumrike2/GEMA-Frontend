import 'package:flutter/material.dart';
import '../Pages/equipos&ubicaciones/ubicaciones_list_page.dart';
import '../Pages/equipos&ubicaciones/equipos_list_page.dart';
import '../../Models/backend_types.dart';
import '../../Services/technical_location_service.dart';
import '../../Services/equipment_service.dart';
import '../../Services/brand_service.dart';
import '../../Services/technical_location_type_service.dart';
import '../Modals/create_ubicacion_modal.dart';
import '../Modals/create_equipo_modal.dart';
import '../Modals/edit_equipo_modal.dart';
import '../Modals/create_marca_modal.dart';
import '../Modals/create_location_type_modal.dart';
import 'package:http/http.dart' as http;

class EquiposUbicacionesScreen extends StatefulWidget {
  const EquiposUbicacionesScreen({super.key});

  @override
  State<EquiposUbicacionesScreen> createState() =>
      _EquiposUbicacionesScreenState();
}

class _EquiposUbicacionesScreenState extends State<EquiposUbicacionesScreen> {
  int _selectedTab = 0; // 0: ubicaciones, 1: equipos

  List<TechnicalLocation> _locations = [];
  List<Equipment> _equipments = [];
  List<LocationType> _locationTypes = [];
  List<Brand> _brands = [];
  bool _loading = false;

  List<TechnicalLocation> _selectedLocations = [];

  bool _showCreateUbicacion = false;
  bool _showCreateEquipo = false;
  bool _showGraphMockup = false;
  bool _showCreateMarca = false;
  bool _showCreateLocationType = false;

  Equipment? _editingEquipment;

  // Move pane state to class fields for persistence
  double leftPaneFraction = 0.4;
  double rightPaneFraction = 0.6;
  bool leftMinimized = false;
  bool rightMinimized = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
    // Initialize pane state
    leftPaneFraction = 0.4;
    rightPaneFraction = 0.6;
    leftMinimized = false;
    rightMinimized = false;
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final locationsFuture = TechnicalLocationService.getAll();
      final equipmentsFuture = EquipmentService.getAll();
      final locationTypesFuture = TechnicalLocationTypeService.getAll();
      final brandsFuture = BrandService.getAll();
      final results = await Future.wait([
        locationsFuture,
        equipmentsFuture,
        locationTypesFuture,
        brandsFuture,
      ]);
      setState(() {
        _locations = results[0] as List<TechnicalLocation>;
        _equipments = results[1] as List<Equipment>;
        _locationTypes = results[2] as List<LocationType>;
        _brands = results[3] as List<Brand>;
      });
    } catch (e) {
      // Optionally handle error
    } finally {
      setState(() => _loading = false);
    }
  }

  List<TechnicalLocation> get _currentPossibleLocations {
    if (_selectedLocations.isEmpty) {
      // Show only root (SEDE)
      return _locations.where((l) => l.technicalCode == 'SEDE').toList();
    } else {
      // Show children of the last selected location
      final parent = _selectedLocations.last.technicalCode;
      return _locations.where((l) => l.parentTechnicalCode == parent).toList();
    }
  }

  List<Equipment> get _currentEquipments {
    if (_selectedLocations.isEmpty) return [];
    final currentCode = _selectedLocations.last.technicalCode;
    return _equipments
        .where((e) => e.technicalLocation == currentCode)
        .toList();
  }

  void _onSelectLocation(TechnicalLocation loc) {
    setState(() {
      _selectedLocations.add(loc);
    });
  }

  void _onRemoveLocation(TechnicalLocation loc) {
    setState(() {
      int idx = _selectedLocations.indexOf(loc);
      if (idx != -1) {
        _selectedLocations = _selectedLocations.sublist(0, idx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- SPLIT VIEW LAYOUT ---
    // Use persistent state fields for pane sizes/minimized/maximized
    return Stack(
      children: [
        Container(
          color: const Color(0xFFD6ECE0),
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                double leftWidth;
                double rightWidth;
                if (leftMinimized && !rightMinimized) {
                  leftWidth = 48.0;
                  rightWidth = totalWidth - leftWidth;
                } else if (!leftMinimized && rightMinimized) {
                  rightWidth = 48.0;
                  leftWidth = totalWidth - rightWidth;
                } else if (leftMinimized && rightMinimized) {
                  // Both minimized: split equally (shouldn't happen, but fallback)
                  leftWidth = totalWidth / 2;
                  rightWidth = totalWidth / 2;
                } else {
                  // Both visible: default split
                  leftWidth = totalWidth * 0.4;
                  rightWidth = totalWidth * 0.6;
                }
                return Row(
                  children: [
                    // --- LEFT PANE: UBICACIONES ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: leftWidth,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 48,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        leftMinimized
                                            ? Icons.chevron_right
                                            : Icons.chevron_left,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          leftMinimized = !leftMinimized;
                                          if (leftMinimized)
                                            rightMinimized = false;
                                        });
                                      },
                                    ),
                                    if (!leftMinimized)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Ubicaciones',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    if (leftMinimized) const SizedBox(width: 0),
                                  ],
                                ),
                              ),
                              if (!leftMinimized)
                                Expanded(
                                  child: UbicacionesListPage(
                                    currentPossibleLocations:
                                        _currentPossibleLocations,
                                    selectedLocations: _selectedLocations,
                                    onSelectLocation: _onSelectLocation,
                                    onRemoveLocation: _onRemoveLocation,
                                    currentEquipments: _currentEquipments,
                                    allEquipments: _equipments,
                                    onCreateLocation:
                                        () => setState(() {
                                          _showCreateUbicacion = true;
                                          _showCreateEquipo = false;
                                        }),
                                    // Add button for creating location type
                                    onCreateLocationType:
                                        () => setState(() {
                                          _showCreateLocationType = true;
                                          _showCreateUbicacion = false;
                                          _showCreateEquipo = false;
                                        }),
                                  ),
                                ),
                            ],
                          ),
                          if (leftMinimized)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      leftMinimized = false;
                                      rightMinimized = false;
                                    });
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      width: 36,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(2, 0),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Text(
                                          'Ubicaciones',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.deepPurple,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // --- RIGHT PANE: EQUIPOS ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: rightWidth,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 48,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        rightMinimized
                                            ? Icons.chevron_left
                                            : Icons.chevron_right,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          rightMinimized = !rightMinimized;
                                          if (rightMinimized)
                                            leftMinimized = false;
                                        });
                                      },
                                    ),
                                    if (!rightMinimized)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Equipos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    if (rightMinimized)
                                      const SizedBox(width: 0),
                                  ],
                                ),
                              ),
                              if (!rightMinimized)
                                Expanded(
                                  child: EquiposListPage(
                                    onDeleteEquipment: (_) => _fetchAll(),
                                    onAssignEquipment: (
                                      equipment, {
                                      required bool isOperational,
                                      required String locationCode,
                                    }) async {
                                      final selectedLocation =
                                          _selectedLocations.isNotEmpty
                                              ? _selectedLocations.last
                                              : null;
                                      if (selectedLocation != null &&
                                          equipment.uuid != null &&
                                          selectedLocation.technicalCode !=
                                              null) {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text(
                                                  'Confirmar asociación',
                                                ),
                                                content: Text(
                                                  isOperational == true
                                                      ? '¿Deseas asociar el equipo "${equipment.name}" a la ubicación operativa "${selectedLocation.name}"?'
                                                      : '¿Deseas asociar el equipo "${equipment.name}" a la ubicación técnica "${selectedLocation.name}"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Confirmar',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            if (isOperational == true) {
                                              await EquipmentService.assignOperationalLocation(
                                                equipment.uuid!,
                                                locationCode,
                                              );
                                            } else {
                                              await EquipmentService.assignTechnicalLocation(
                                                equipment.uuid!,
                                                locationCode,
                                              );
                                            }
                                            _fetchAll();
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error al asociar: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    onEditEquipment: (equipment) {
                                      setState(() {
                                        _editingEquipment = equipment;
                                      });
                                    },
                                    onCreateEquipment: () {
                                      setState(() {
                                        _showCreateEquipo = true;
                                        _showCreateUbicacion = false;
                                      });
                                    },
                                    onCreateMarca: () {
                                      setState(() {
                                        _showCreateMarca = true;
                                        _showCreateEquipo = false;
                                        _showCreateUbicacion = false;
                                      });
                                    },
                                    equipments: _equipments,
                                    brands: _brands,
                                    operationalLocations: _locations,
                                    selectedLocation:
                                        _selectedLocations.isNotEmpty
                                            ? _selectedLocations.last
                                            : null,
                                  ),
                                ),
                            ],
                          ),
                          if (rightMinimized)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rightMinimized = false;
                                      leftMinimized = false;
                                    });
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      width: 36,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(-2, 0),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          'Equipos',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.deepPurple,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (_showCreateUbicacion)
          Center(
            child: CreateUbicacionModal(
              locationTypes: _locationTypes,
              parentLocations: _locations,
              selectedLocation:
                  _selectedLocations.isNotEmpty
                      ? _selectedLocations.last
                      : null, // Pass selected location
              onCreate: (data) async {
                setState(() => _showCreateUbicacion = false);
                await TechnicalLocationService.create(data);
                _fetchAll();
              },
              onCancel: () => setState(() => _showCreateUbicacion = false),
            ),
          ),
        if (_showCreateEquipo || _showCreateMarca)
          Center(
            child: Stack(
              children: [
                if (_showCreateEquipo)
                  CreateEquipoModal(
                    brands: _brands,
                    onCreate: (data) async {
                      setState(() => _showCreateEquipo = false);
                      await EquipmentService.create(data);
                      _fetchAll();
                    },
                    onCancel: () => setState(() => _showCreateEquipo = false),
                  ),
                if (_showCreateMarca)
                  CreateMarcaModal(
                    onCreate: (name) async {
                      setState(() => _showCreateMarca = false);
                      await BrandService.create({'name': name});
                      await _fetchAll();
                    },
                    onCancel: () => setState(() => _showCreateMarca = false),
                  ),
              ],
            ),
          ),
        if (_showCreateLocationType)
          Center(
            child: CreateLocationTypeModal(
              onCreate: (data) async {
                setState(() => _showCreateLocationType = false);
                await TechnicalLocationTypeService.create(data['name']);
                _fetchAll();
              },
              onCancel: () => setState(() => _showCreateLocationType = false),
            ),
          ),
        if (_editingEquipment != null)
          Center(
            child: EditEquipoModal(
              equipment: _editingEquipment!,
              brands: _brands,
              onUpdate: (data) async {
                setState(() => _editingEquipment = null);
                await EquipmentService.update(data['uuid'], data);
                _fetchAll();
              },
              onCancel: () => setState(() => _editingEquipment = null),
            ),
          ),
      ],
    );
  }
}
