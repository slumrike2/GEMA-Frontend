import 'package:flutter/material.dart';
import '../Models/backend_types.dart';
import '../Components/searchable_combobox.dart';

class EditEquipoModal extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onUpdate;
  final VoidCallback onCancel;
  final Equipment equipment;
  final List<Brand> brands;
  final List<Equipment> allEquipments; // Lista de todos los equipos para seleccionar dependientes
  final List<TechnicalLocation> technicalLocations; // Lista de ubicaciones técnicas para construir jerarquías

  const EditEquipoModal({
    super.key,
    required this.onUpdate,
    required this.onCancel,
    required this.equipment,
    required this.brands,
    required this.allEquipments,
    required this.technicalLocations,
  });

  @override
  State<EditEquipoModal> createState() => _EditEquipoModalState();
}

class _EditEquipoModalState extends State<EditEquipoModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _serialController;
  late TextEditingController _descriptionController;
  int? _brandId;
  EquipmentState _state = EquipmentState.en_inventario;
  
  // Lista de equipos dependientes seleccionados
  List<String> _selectedDependentEquipments = [];
  String? _selectedEquipmentToAdd;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.equipment.name);
    _codeController = TextEditingController(text: widget.equipment.technicalCode);
    _serialController = TextEditingController(text: widget.equipment.serialNumber);
    _descriptionController = TextEditingController(text: widget.equipment.description ?? '');
    _brandId = widget.equipment.brandId;
    _state = widget.equipment.state ?? EquipmentState.en_inventario;
    
    // Inicializar equipos dependientes existentes
    _selectedDependentEquipments = widget.allEquipments
        .where((eq) => eq.dependsOn == widget.equipment.uuid)
        .map((eq) => eq.uuid!)
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _serialController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Obtener equipos disponibles para agregar como dependientes
  List<Equipment> get _availableEquipments {
    return widget.allEquipments
        .where((eq) => 
            eq.uuid != widget.equipment.uuid && // No puede depender de sí mismo
            !_selectedDependentEquipments.contains(eq.uuid) && // No agregar duplicados
            eq.dependsOn != widget.equipment.uuid) // No agregar si ya depende
        .toList();
  }

  // Construir la jerarquía completa de ubicación para un equipo
  String _buildLocationHierarchy(String? locationCode) {
    if (locationCode == null || locationCode.isEmpty) return "Sin ubicación";
    
    List<String> hierarchy = [];
    String? currentCode = locationCode;
    
    while (currentCode != null && currentCode.isNotEmpty) {
      hierarchy.add(currentCode);
      // Buscar el padre de la ubicación actual
      final parentLocation = widget.technicalLocations.firstWhere(
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

  // Agregar equipo dependiente
  void _addDependentEquipment() {
    if (_selectedEquipmentToAdd != null) {
      setState(() {
        _selectedDependentEquipments.add(_selectedEquipmentToAdd!);
        _selectedEquipmentToAdd = null;
      });
    }
  }

  // Eliminar equipo dependiente
  void _removeDependentEquipment(String equipmentUuid) {
    setState(() {
      _selectedDependentEquipments.remove(equipmentUuid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => widget.onCancel(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside the modal
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700, // Aumentado para acomodar la tabla
                  maxHeight: 800, // Aumentado para acomodar más contenido
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
        borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade100, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.orange, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'Editar Equipo',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                            
                            // Información básica del equipo
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                                      fillColor: Colors.orange[50],
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
                ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código Técnico',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                                      fillColor: Colors.orange[50],
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un código' : null,
                                  ),
                                ),
                              ],
                ),
                const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _serialController,
                  decoration: InputDecoration(
                    labelText: 'Número de Serie',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                                      fillColor: Colors.orange[50],
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un número de serie' : null,
                ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                                      fillColor: Colors.orange[50],
                  ),
                                    value: _brandId,
                  items: widget.brands
                      .map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _brandId = v),
                  validator: (v) => v == null ? 'Seleccione una marca' : null,
                                  ),
                                ),
                              ],
                ),
                const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Descripción (opcional)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<EquipmentState>(
                              decoration: InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.orange[50],
                              ),
                              value: _state,
                              items: EquipmentState.values
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s.name.replaceAll('_', ' '),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _state = v ?? EquipmentState.en_inventario),
                            ),
                            const SizedBox(height: 24),
                            
                            // Sección de equipos dependientes
                            const Text(
                              'Equipos Dependientes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            
                            // Agregar nuevo equipo dependiente
                            Row(
                              children: [
                                Expanded(
                                  child: SearchableComboBox<String>(
                                    labelText: 'Seleccionar equipo para agregar como dependiente',
                                    hintText: 'Escribe para buscar por nombre, código o ubicación...',
                                    value: _selectedEquipmentToAdd,
                                    items: _availableEquipments
                                        .map((eq) => DropdownMenuItem(
                                              value: eq.uuid,
                                              child: Text('${eq.name} (${eq.technicalCode}) - ${_buildLocationHierarchy(eq.technicalLocation)}'),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _selectedEquipmentToAdd = v),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _selectedEquipmentToAdd != null ? _addDependentEquipment : null,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Tabla de equipos dependientes
                            if (_selectedDependentEquipments.isNotEmpty) ...[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    // Header de la tabla
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Expanded(flex: 2, child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                                          Expanded(flex: 2, child: Text('Código Técnico', style: TextStyle(fontWeight: FontWeight.bold))),
                                          Expanded(flex: 1, child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                    ),
                                    // Filas de la tabla
                                    ...(_selectedDependentEquipments.map((equipmentUuid) {
                                      final equipment = widget.allEquipments.firstWhere((eq) => eq.uuid == equipmentUuid);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: Colors.grey[300]!)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(equipment.name),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(equipment.technicalCode),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () => _removeDependentEquipment(equipmentUuid),
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                tooltip: 'Eliminar dependencia',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList()),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No hay equipos dependientes seleccionados',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                            
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onUpdate({
                            'uuid': widget.equipment.uuid,
                                        'name': _nameController.text,
                                        'technicalCode': _codeController.text,
                                        'serialNumber': _serialController.text,
                            'brandId': _brandId,
                                        if (_descriptionController.text.isNotEmpty) 'description': _descriptionController.text,
                                        'state': _state.name,
                                        'dependentEquipments': _selectedDependentEquipments, // Lista de UUIDs de equipos dependientes
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                                  child: const Text('Actualizar'),
                    ),
                  ],
                ),
              ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
