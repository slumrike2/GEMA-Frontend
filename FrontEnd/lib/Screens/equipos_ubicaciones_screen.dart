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

  @override
  void initState() {
    super.initState();
    _fetchAll();
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
            child: SingleChildScrollView(
              child: Column(
                  children: [
                  // --- SECCIÓN UBICACIONES ---
                  Container(
                    height: 300, // Altura fija para la sección de ubicaciones
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                        children: [
                        // Header de Ubicaciones
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                                    ),
                              const SizedBox(width: 8),
                              const Text(
                                'Filtro de Ubicaciones',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                  color: Colors.white,
                                          ),
                                        ),
                              const Spacer(),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'create_location':
                                      setState(() {
                                        _showCreateUbicacion = true;
                                        _showCreateEquipo = false;
                                      });
                                      break;
                                    case 'create_location_type':
                                      setState(() {
                                        _showCreateLocationType = true;
                                        _showCreateUbicacion = false;
                                        _showCreateEquipo = false;
                                      });
                                      break;
                                    case 'delete_location':
                                      // TODO: Implementar funcionalidad de borrar ubicación
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Funcionalidad de borrar ubicación no implementada'),
                                        ),
                                      );
                                      break;
                                    case 'delete_location_type':
                                      // TODO: Implementar funcionalidad de borrar tipo de ubicación
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Funcionalidad de borrar tipo de ubicación no implementada'),
                                        ),
                                      );
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<String>(
                                    value: 'create_location',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Crear Ubicación'),
                                  ],
                                ),
                              ),
                                  const PopupMenuItem<String>(
                                    value: 'create_location_type',
                                    child: Row(
                                      children: [
                                        Icon(Icons.category, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Crear Tipo de Ubicación'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete_location',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Borrar Ubicación'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete_location_type',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_sweep, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Borrar Tipo de Ubicación'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Contenido de Ubicaciones
                                Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                                  child: UbicacionesListPage(
                              currentPossibleLocations: _currentPossibleLocations,
                                    selectedLocations: _selectedLocations,
                                    onSelectLocation: _onSelectLocation,
                                    onRemoveLocation: _onRemoveLocation,
                                    currentEquipments: _currentEquipments,
                                    allEquipments: _equipments,
                              onCreateLocation: () {}, // Ya no se usa
                              onCreateLocationType: () {}, // Ya no se usa
                            ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- SECCIÓN EQUIPOS ---
                  Container(
                    height: 500, // Altura fija para la sección de equipos
                                      decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                    child: Column(
                      children: [
                        // Header de Equipos
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.build,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Equipos en la Ubicación',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'create_equipment':
                                      setState(() {
                                        _showCreateEquipo = true;
                                        _showCreateUbicacion = false;
                                      });
                                      break;
                                    case 'create_marca':
                                      setState(() {
                                        _showCreateMarca = true;
                                        _showCreateEquipo = false;
                                        _showCreateUbicacion = false;
                                      });
                                      break;
                                    case 'delete_marca':
                                      // TODO: Implementar funcionalidad de borrar marca
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Funcionalidad de borrar marca no implementada'),
                                        ),
                                      );
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<String>(
                                    value: 'create_equipment',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Crear Equipo'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'create_marca',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_business, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Crear Marca'),
                        ],
                      ),
                    ),
                                  const PopupMenuItem<String>(
                                    value: 'delete_marca',
                                child: Row(
                                  children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Borrar Marca'),
                                      ],
                                          ),
                                        ),
                                ],
                              ),
                                  ],
                                ),
                              ),
                        // Contenido de Equipos
                                Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                    selectedLocation.technicalCode != null) {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar asociación'),
                                                content: Text(
                                                  isOperational == true
                                                      ? '¿Deseas asociar el equipo "${equipment.name}" a la ubicación operativa "${selectedLocation.name}"?'
                                                      : '¿Deseas asociar el equipo "${equipment.name}" a la ubicación técnica "${selectedLocation.name}"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                                  ),
                                                  ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Confirmar'),
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                          content: Text('Error al asociar: $e'),
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
                              onCreateEquipment: () {}, // Ya no se usa
                              onCreateMarca: () {}, // Ya no se usa
                                    equipments: _equipments,
                                    brands: _brands,
                                    operationalLocations: _locations,
                              selectedLocation: _selectedLocations.isNotEmpty
                                            ? _selectedLocations.last
                                            : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32), // Espacio adicional al final para scroll
                  ],
              ),
            ),
          ),
        ),
        // Modales
        if (_showCreateUbicacion)
          Center(
            child: CreateUbicacionModal(
              locationTypes: _locationTypes,
              parentLocations: _locations,
              selectedLocation: _selectedLocations.isNotEmpty
                      ? _selectedLocations.last
                  : null,
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
              allEquipments: _equipments,
              technicalLocations: _locations,
              onUpdate: (data) async {
                setState(() => _editingEquipment = null);
                
                // Actualizar información básica del equipo (sin dependencias)
                final basicData = Map<String, dynamic>.from(data);
                basicData.remove('dependentEquipments');
                await EquipmentService.update(data['uuid'], basicData);
                
                // Actualizar dependencias si están presentes
                if (data.containsKey('dependentEquipments')) {
                  final dependentEquipments = data['dependentEquipments'] as List<String>;
                  
                  // Obtener equipos que actualmente dependen de este equipo
                  final currentDependents = _equipments
                      .where((eq) => eq.dependsOn == data['uuid'])
                      .map((eq) => eq.uuid!)
                      .toList();
                  
                  // Remover dependencias de equipos que ya no deben depender
                  for (final equipmentUuid in currentDependents) {
                    if (!dependentEquipments.contains(equipmentUuid)) {
                      await EquipmentService.updateEquipmentDependency(equipmentUuid, null);
                    }
                  }
                  
                  // Agregar dependencias a equipos que deben depender
                  for (final equipmentUuid in dependentEquipments) {
                    if (!currentDependents.contains(equipmentUuid)) {
                      await EquipmentService.updateEquipmentDependency(equipmentUuid, data['uuid']);
                    }
                  }
                }
                
                _fetchAll();
              },
              onCancel: () => setState(() => _editingEquipment = null),
            ),
          ),
      ],
    );
  }
}
