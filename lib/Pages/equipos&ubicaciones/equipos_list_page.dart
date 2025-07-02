import 'package:flutter/material.dart';
import '../../Models/backend_types.dart';
import 'package:frontend/Components/tag.dart';
import '../../Services/equipment_service.dart';
import '../../Services/brand_service.dart';

class EquiposListPage extends StatefulWidget {
  final void Function(Equipment) onDeleteEquipment;
  final void Function(Equipment, String) onAssignEquipment;
  final void Function(Equipment) onEditEquipment;
  final VoidCallback onCreateEquipment;
  final TextEditingController equipmentNameController;
  final TextEditingController equipmentLocationController;
  final TextEditingController equipmentSerialController;
  final TextEditingController equipmentBrandIdController;

  const EquiposListPage({
    super.key,
    required this.onDeleteEquipment,
    required this.onAssignEquipment,
    required this.onEditEquipment,
    required this.onCreateEquipment,
    required this.equipmentNameController,
    required this.equipmentLocationController,
    required this.equipmentSerialController,
    required this.equipmentBrandIdController,
  });

  @override
  State<EquiposListPage> createState() => _EquiposListPageState();
}

class _EquiposListPageState extends State<EquiposListPage> {
  List<Brand> _brands = [];
  Brand? _selectedBrand;
  bool _loadingBrands = false;
  final TextEditingController _technicalCodeController =
      TextEditingController();
  List<Equipment> _equipmentList = [];
  bool _loadingEquipments = false;
  bool _showCreate = false;

  // --- Dependencias selector ---
  String searchQuery = '';
  Equipment? selectedDependency;
  List<Equipment> get filteredEquipments {
    return _equipmentList.where((eq) {
      final query = searchQuery.toLowerCase();
      return (eq.name.toLowerCase().contains(query) ||
          eq.technicalCode.toLowerCase().contains(query));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _fetchEquipments();
  }

  Future<void> _fetchBrands() async {
    setState(() => _loadingBrands = true);
    try {
      final brands = await BrandService.getAll();
      setState(() {
        _brands = brands;
        if (_brands.isNotEmpty) {
          _selectedBrand = _brands.first;
        }
      });
    } catch (e) {
      // Manejo de error opcional
    } finally {
      setState(() => _loadingBrands = false);
    }
  }

  Future<void> _fetchEquipments() async {
    setState(() => _loadingEquipments = true);
    try {
      final equipments = await EquipmentService.getAll();
      setState(() {
        _equipmentList = equipments;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() => _loadingEquipments = false);
    }
  }

  void _handleCreateEquipment() async {
    await _fetchEquipments();
    widget.onCreateEquipment();
  }

  void _handleDeleteEquipment(Equipment e) async {
    await EquipmentService.delete(e.technicalCode);
    await _fetchEquipments();
    widget.onDeleteEquipment(e);
  }

  void _handleShowCreate() {
    setState(() {
      _showCreate = true;
    });
  }

  void _handleCancelCreate() {
    setState(() {
      _showCreate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCreate) {
      return EquipmentCreateWidget(
        brands: _brands,
        initialBrand: _selectedBrand,
        allEquipments: _equipmentList,
        onCreated: () {
          _handleCreateEquipment();
          _handleCancelCreate();
        },
        onCancel: _handleCancelCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gestión de Equipos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_brands.isEmpty || _equipmentList.isEmpty) {
                  await Future.wait([_fetchBrands(), _fetchEquipments()]);
                }
                if (!mounted) return;
                _handleShowCreate();
              },
              child: const Text('Crear Equipo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _loadingEquipments
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _equipmentList.length,
              itemBuilder: (context, idx) {
                final e = _equipmentList[idx];
                return _EquipmentTile(
                  equipment: e,
                  onDelete: () => _handleDeleteEquipment(e),
                  onEdit: () => widget.onEditEquipment(e),
                );
              },
            ),
      ],
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  widget.equipment.technicalLocation == null ||
                          widget.equipment.technicalLocation!.isEmpty
                      ? Tag(label: 'Sin ubicación', color: Colors.red)
                      : Tag(label: widget.equipment.technicalLocation!),
                  const SizedBox(width: 8),
                  Tag(
                    label:
                        widget.equipment.state != null
                            ? widget.equipment.state!.name.replaceAll('_', ' ')
                            : '',
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para visualizar dependencias en forma de árbol
class _DependencyTreeView extends StatelessWidget {
  final Equipment root;
  final List<Equipment> allEquipments;
  const _DependencyTreeView({required this.root, required this.allEquipments});

  @override
  Widget build(BuildContext context) {
    List<Equipment> children =
        allEquipments.where((e) => e.dependsOn == root.uuid).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.device_hub, size: 18, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Text(
              root.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 6),
            Text(
              '(${root.technicalCode})',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        if (children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 18, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  children
                      .map(
                        (child) => _DependencyTreeView(
                          root: child,
                          allEquipments: allEquipments,
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }
}

// EquipmentCreateWidget: not a full page, but a widget to embed in your page layout
class EquipmentCreateWidget extends StatefulWidget {
  final List<Brand> brands;
  final Brand? initialBrand;
  final List<Equipment> allEquipments;
  final VoidCallback onCreated;
  final VoidCallback onCancel;

  const EquipmentCreateWidget({
    super.key,
    required this.brands,
    required this.initialBrand,
    required this.allEquipments,
    required this.onCreated,
    required this.onCancel,
  });

  @override
  State<EquipmentCreateWidget> createState() => _EquipmentCreateWidgetState();
}

class _EquipmentCreateWidgetState extends State<EquipmentCreateWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _technicalCodeController =
      TextEditingController();
  Brand? _selectedBrand;
  String searchQuery = '';
  Equipment? selectedDependency;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand;
  }

  List<Equipment> get filteredEquipments {
    final query = searchQuery.toLowerCase();
    return widget.allEquipments.where((eq) {
      return eq.name.toLowerCase().contains(query) ||
          eq.technicalCode.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double availableHeight = MediaQuery.of(context).size.height - 120;
    // Construir la cadena de dependencias horizontal
    List<Equipment> dependencyChain = [];
    Equipment? current = selectedDependency;
    while (current != null) {
      dependencyChain.add(current);
      final nextUuid = current.dependsOn;
      if (nextUuid == null) break;
      Equipment? next;
      for (final e in widget.allEquipments) {
        if (e.uuid == nextUuid) {
          next = e;
          break;
        }
      }
      if (next == null) break;
      current = next;
    }
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          SizedBox(
            height: availableHeight > 400 ? availableHeight : 400,
            child: Row(
              children: [
                // Left: Form fields
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: widget.onCancel,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Crear Nuevo Equipo',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _serialController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Serie',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _technicalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Código Técnico',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Brand>(
                        value: _selectedBrand,
                        items:
                            widget.brands
                                .map(
                                  (b) => DropdownMenuItem<Brand>(
                                    value: b,
                                    child: Text(b.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (brand) {
                          setState(() {
                            _selectedBrand = brand;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: widget.onCancel,
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_technicalCodeController.text.isEmpty ||
                                  _nameController.text.isEmpty ||
                                  _serialController.text.isEmpty ||
                                  _selectedBrand == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor, complete todos los campos.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              final newEquipment = Equipment(
                                technicalCode: _technicalCodeController.text,
                                name: _nameController.text,
                                serialNumber: _serialController.text,
                                brandId: _selectedBrand!.id!,
                                dependsOn: selectedDependency?.uuid,
                              );
                              await EquipmentService.create(
                                newEquipment.toJson(),
                              );
                              widget.onCreated();
                            },
                            child: const Text('Crear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right: Dependency selector
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Depende de:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre o código...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: filteredEquipments.length + 1,
                            itemBuilder: (context, idx) {
                              if (idx == 0) {
                                return ListTile(
                                  title: const Text(
                                    'Sin dependencia',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  trailing:
                                      selectedDependency == null
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                          : null,
                                  onTap: () {
                                    setState(() {
                                      selectedDependency = null;
                                    });
                                  },
                                );
                              }
                              final eq = filteredEquipments[idx - 1];
                              return ListTile(
                                title: Text(eq.name),
                                subtitle: Text('Código: ${eq.technicalCode}'),
                                trailing:
                                    selectedDependency?.uuid == eq.uuid
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                        : null,
                                onTap: () {
                                  setState(() {
                                    selectedDependency = eq;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Árbol de dependencias horizontal
          if (selectedDependency != null && dependencyChain.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < dependencyChain.length; i++) ...[
                    Text(
                      dependencyChain[i].name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (i < dependencyChain.length - 1)
                      Row(
                        children: const [
                          SizedBox(width: 8),
                          Text(
                            '<- depende',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
