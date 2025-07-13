import 'package:flutter/material.dart';
import '../Models/backend_types.dart';

class EditEquipoModal extends StatefulWidget {
  final Equipment equipment;
  final List<Brand> brands;
  final void Function(Map<String, dynamic> data) onUpdate;
  final VoidCallback onCancel;

  const EditEquipoModal({
    super.key,
    required this.equipment,
    required this.brands,
    required this.onUpdate,
    required this.onCancel,
  });

  @override
  State<EditEquipoModal> createState() => _EditEquipoModalState();
}

class _EditEquipoModalState extends State<EditEquipoModal> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  late String _serial;
  String? _description;
  int? _brandId;
  EquipmentState? _state;

  @override
  void initState() {
    super.initState();
    _name = widget.equipment.name;
    _code = widget.equipment.technicalCode;
    _serial = widget.equipment.serialNumber;
    _description = widget.equipment.description;
    _brandId = widget.equipment.brandId;
    _state = widget.equipment.state ?? EquipmentState.en_inventario;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade100, width: 2),
      ),
      elevation: 8,
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
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (v) => setState(() => _name = v),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _code,
                  decoration: InputDecoration(
                    labelText: 'Código Técnico',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (v) => setState(() => _code = v),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un código' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _serial,
                  decoration: InputDecoration(
                    labelText: 'Número de Serie',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (v) => setState(() => _serial = v),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese un número de serie' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _brandId,
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  items: widget.brands
                      .map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _brandId = v),
                  validator: (v) => v == null ? 'Seleccione una marca' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  onChanged: (v) => setState(() => _description = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EquipmentState>(
                  value: _state,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  items: EquipmentState.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name.replaceAll('_', ' ')),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _state = v ?? EquipmentState.en_inventario),
                ),
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
                            'name': _name,
                            'technicalCode': _code,
                            'serialNumber': _serial,
                            'brandId': _brandId,
                            if (_description != null && _description!.isNotEmpty) 'description': _description,
                            'state': _state?.name,
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
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
