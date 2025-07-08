import 'package:flutter/material.dart';
import '../../Services/technical_location_service.dart';
import '../../Services/equipment_service.dart';
import '../../Models/backend_types.dart';
import 'equipos_list_page.dart';
import 'ubicaciones_list_page.dart';
import '../../Services/technical_location_type_service.dart';

class InicioEquiposUbicaciones extends StatefulWidget {
  final VoidCallback? onCrearEquipo;
  final VoidCallback? onCrearUbicacion;
  final VoidCallback? onTiposUbicacion;
  const InicioEquiposUbicaciones({
    super.key,
    this.onCrearEquipo,
    this.onCrearUbicacion,
    this.onTiposUbicacion,
  });

  @override
  State<InicioEquiposUbicaciones> createState() =>
      _InicioEquiposUbicacionesState();
}

class _InicioEquiposUbicacionesState extends State<InicioEquiposUbicaciones>
    with SingleTickerProviderStateMixin {
  int selectedSection = 0; // 0: Ubicaciones, 1: Equipos
  List<TechnicalLocation> allLocations = [];
  List<Equipment> allEquipments = [];
  List<TechnicalLocation> selectedLocations = [];
  bool isLoading = false;
  List<LocationType> locationTypes = [];
  String? _selectedLocationTypeName;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchLocationTypes();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final locationsFuture = TechnicalLocationService.getAll();
      final equipmentsFuture = EquipmentService.getAll();
      final results = await Future.wait([locationsFuture, equipmentsFuture]);
      setState(() {
        allLocations = results[0] as List<TechnicalLocation>;
        allEquipments = results[1] as List<Equipment>;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      // Optionally show error
    }
  }

  Future<void> _fetchLocationTypes() async {
    try {
      final types = await TechnicalLocationTypeService.getAll();
      setState(() {
        locationTypes = types;
        if (locationTypes.isNotEmpty && _selectedLocationTypeName == null) {
          _selectedLocationTypeName = locationTypes.first.name;
        }
      });
    } catch (e) {
      print('Error fetching location types: $e');
    }
  }

  Future<bool?> onCreateLocationTypeDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final nameTemplateController = TextEditingController();
    final codeTemplateController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nuevo Tipo de Ubicación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: nameTemplateController,
                  decoration: const InputDecoration(
                    labelText: 'Plantilla de Nombre',
                  ),
                ),
                TextField(
                  controller: codeTemplateController,
                  decoration: const InputDecoration(
                    labelText: 'Plantilla de Código',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      nameTemplateController.text.trim().isEmpty ||
                      codeTemplateController.text.trim().isEmpty) {
                    return;
                  }
                  await onCreateLocationType(
                    nameController.text.trim(),
                    nameTemplateController.text.trim(),
                    codeTemplateController.text.trim(),
                  );
                  Navigator.pop(context, true);
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
    nameController.dispose();
    nameTemplateController.dispose();
    codeTemplateController.dispose();
    return result;
  }

  Future<void> onCreateLocationType(
    String name,
    String nameTemplate,
    String codeTemplate,
  ) async {
    try {
      await TechnicalLocationTypeService.createWithTemplates(
        name,
        nameTemplate,
        codeTemplate,
      );
      await _fetchLocationTypes();
      setState(() {
        _selectedLocationTypeName = name;
      });
    } catch (e) {
      print('Error creating location type: $e');
    }
  }

  List<TechnicalLocation> get currentPossibleLocations {
    if (selectedLocations.isEmpty) {
      // Show root children

      return allLocations.where((l) => l.technicalCode == 'SEDE').toList();
    } else {
      // Show children of the last selected location
      return allLocations
          .where(
            (l) =>
                l.parentTechnicalCode == selectedLocations.last.technicalCode,
          )
          .toList();
    }
  }

  List<Equipment> get currentEquipments {
    if (selectedLocations.isEmpty) return [];
    return allEquipments
        .where(
          (e) => e.technicalLocation == selectedLocations.last.technicalCode,
        )
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
  List<Equipment> equipmentList = [];
  Equipment? editingEquipment;
  final _equipmentNameController = TextEditingController();
  final _equipmentLocationController = TextEditingController();
  final _equipmentSerialController = TextEditingController();
  final _equipmentBrandIdController = TextEditingController();

  void onCreateEquipment() {
    setState(() {
      equipmentList.add(
        Equipment(
          technicalCode:
              DateTime.now().millisecondsSinceEpoch
                  .toString(), // Unique code for demo
          name: _equipmentNameController.text,
          serialNumber:
              _equipmentSerialController.text.isNotEmpty
                  ? _equipmentSerialController.text
                  : 'SN-${DateTime.now().millisecondsSinceEpoch}',
          brandId: int.tryParse(_equipmentBrandIdController.text) ?? 1,
          technicalLocation: _equipmentLocationController.text,
        ),
      );
      _equipmentNameController.clear();
      _equipmentLocationController.clear();
      _equipmentSerialController.clear();
      _equipmentBrandIdController.clear();
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
          technicalCode: eq.technicalCode,
          name: eq.name,
          serialNumber: eq.serialNumber,
          brandId: eq.brandId,
          technicalLocation: newLocation,
          state: eq.state,
        );
      }
    });
  }

  // Location creation state
  final _locationNameController = TextEditingController();
  final _locationCodeController = TextEditingController();

  Future<void> onCreateLocation() async {
    final parent =
        selectedLocations.isNotEmpty
            ? selectedLocations.last.technicalCode
            : null;
    final newLocation = TechnicalLocation(
      name: _locationNameController.text,
      technicalCode: _locationCodeController.text,
      type: locationTypes.indexWhere(
        (t) =>
            t.name ==
            (_selectedLocationTypeName ??
                (locationTypes.isNotEmpty ? locationTypes.first.name : '')),
      ),
      parentTechnicalCode: parent,
    );
    try {
      await TechnicalLocationService.create(newLocation.toJson());
      await _fetchData();
    } catch (e) {
      print('Error creating location: $e');
    }
    setState(() {
      _locationNameController.clear();
      _locationCodeController.clear();
      _selectedLocationTypeName =
          locationTypes.isNotEmpty ? locationTypes.first.name : null;
    });
  }

  @override
  void dispose() {
    _equipmentNameController.dispose();
    _equipmentLocationController.dispose();
    _equipmentSerialController.dispose();
    _equipmentBrandIdController.dispose();
    _locationNameController.dispose();
    _locationCodeController.dispose();
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
                const Spacer(),
                if (selectedSection == 0) ...[
                  ElevatedButton(
                    onPressed: widget.onTiposUbicacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tipos de Ubicación'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Crear Ubicación'),
                              content: SizedBox(
                                width: 600,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Form
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: _locationNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Nombre',
                                            ),
                                          ),
                                          TextField(
                                            controller: _locationCodeController,
                                            decoration: const InputDecoration(
                                              labelText: 'Código Técnico',
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: DropdownButtonFormField<
                                                  String
                                                >(
                                                  value:
                                                      _selectedLocationTypeName,
                                                  items:
                                                      locationTypes
                                                          .map(
                                                            (type) =>
                                                                DropdownMenuItem(
                                                                  value:
                                                                      type.name,
                                                                  child: Text(
                                                                    type.name,
                                                                  ),
                                                                ),
                                                          )
                                                          .toList(),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _selectedLocationTypeName =
                                                          val;
                                                    });
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Tipo de Ubicación',
                                                      ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                tooltip: 'Agregar nuevo tipo',
                                                onPressed: () async {
                                                  await onCreateLocationTypeDialog(
                                                    context,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Right: Location tree
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Jerarquía actual:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          ...selectedLocations.map(
                                            (loc) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2.0,
                                                  ),
                                              child: Text(
                                                '${loc.name} (${loc.technicalCode})',
                                              ),
                                            ),
                                          ),
                                          if (selectedLocations.isEmpty)
                                            const Text(
                                              'Nivel raíz (sin padre)',
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await onCreateLocation();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Crear'),
                                ),
                              ],
                            ),
                      );
                    },
                    child: const Text('Crear Ubicación'),
                  ),
                ],
                if (selectedSection == 1)
                  ElevatedButton(
                    onPressed: widget.onCrearEquipo,
                    child: const Text('Crear Equipo'),
                  ),
              ],
            ),
          ),
          if (selectedSection == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: UbicacionesListPage(
                currentPossibleLocations: currentPossibleLocations,
                selectedLocations: selectedLocations,
                onSelectLocation: onSelectLocation,
                onRemoveLocation: onRemoveLocation,
                currentEquipments: currentEquipments,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: EquiposListPage(
                onDeleteEquipment: onDeleteEquipment,
                onAssignEquipment: onAssignEquipment,
                onEditEquipment: (e) {
                  _equipmentNameController.text = e.name;
                  _equipmentLocationController.text = e.technicalLocation ?? '';
                  _equipmentSerialController.text = e.serialNumber;
                  _equipmentBrandIdController.text = e.brandId.toString();
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
                                controller: _equipmentLocationController,
                                decoration: const InputDecoration(
                                  labelText: 'Código de Ubicación',
                                ),
                              ),
                              TextField(
                                controller: _equipmentSerialController,
                                decoration: const InputDecoration(
                                  labelText: 'Serial Number',
                                ),
                              ),
                              TextField(
                                controller: _equipmentBrandIdController,
                                decoration: const InputDecoration(
                                  labelText: 'Brand ID',
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
                                      technicalCode: e.technicalCode,
                                      name: _equipmentNameController.text,
                                      serialNumber:
                                          _equipmentSerialController.text,
                                      brandId:
                                          int.tryParse(
                                            _equipmentBrandIdController.text,
                                          ) ??
                                          1,
                                      technicalLocation:
                                          _equipmentLocationController.text,
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
                onCreateEquipment: onCreateEquipment,
                equipmentNameController: _equipmentNameController,
                equipmentLocationController: _equipmentLocationController,
                equipmentSerialController: _equipmentSerialController,
                equipmentBrandIdController: _equipmentBrandIdController,
              ),
            ),
        ],
      ),
    );
  }
}
