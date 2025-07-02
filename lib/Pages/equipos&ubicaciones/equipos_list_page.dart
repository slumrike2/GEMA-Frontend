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

  @override
  Widget build(BuildContext context) {
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
                              controller: widget.equipmentNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                              ),
                            ),
                            TextField(
                              controller: widget.equipmentSerialController,
                              decoration: const InputDecoration(
                                labelText: 'Número de Serie',
                              ),
                            ),

                            TextField(
                              controller: _technicalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Código Técnico',
                              ),
                            ),
                            _loadingBrands
                                ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                                : DropdownButtonFormField<Brand>(
                                  value: _selectedBrand,
                                  items:
                                      _brands
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
                            onPressed: () async {
                              // Validación simple
                              if (_technicalCodeController.text.isEmpty ||
                                  widget.equipmentNameController.text.isEmpty ||
                                  widget
                                      .equipmentSerialController
                                      .text
                                      .isEmpty ||
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
                                name: widget.equipmentNameController.text,
                                serialNumber:
                                    widget.equipmentSerialController.text,
                                brandId: _selectedBrand!.id!,
                              );
                              await EquipmentService.create(
                                newEquipment.toJson(),
                              );
                              _handleCreateEquipment();
                              Navigator.of(context).pop();
                              // Limpiar campos
                              _technicalCodeController.clear();
                              widget.equipmentNameController.clear();
                              widget.equipmentSerialController.clear();
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
                  widget.equipment.technicalLocation == null || widget.equipment.technicalLocation!.isEmpty
                      ? Tag(
                          label: 'Sin ubicación',
                          color: Colors.red,
                        )
                      : Tag(label: widget.equipment.technicalLocation!),
                  const SizedBox(width: 8),
                  Tag(
                    label: widget.equipment.state != null
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
