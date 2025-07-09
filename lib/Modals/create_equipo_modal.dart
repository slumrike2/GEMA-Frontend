import 'package:flutter/material.dart';
import '../Models/backend_types.dart';

class CreateEquipoModal extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onCreate;
  final VoidCallback onCancel;
  final List<Brand> brands;

  const CreateEquipoModal({
    super.key,
    required this.onCreate,
    required this.onCancel,
    required this.brands,
  });

  @override
  State<CreateEquipoModal> createState() => _CreateEquipoModalState();
}

class _CreateEquipoModalState extends State<CreateEquipoModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _code = '';
  String _serial = '';
  String? _description;
  int? _brandId;
  EquipmentState _state = EquipmentState.en_inventario;

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
                    const Icon(Icons.precision_manufacturing, color: Colors.green, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'Crear Equipo',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
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
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
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
                const SizedBox(height: 16),
                TextFormField(
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
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.green[50],
                  ),
                  value: _state,
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
                          widget.onCreate({
                            'name': _name,
                            'technicalCode': _code,
                            'serialNumber': _serial,
                            'brandId': _brandId,
                            if (_description != null && _description!.isNotEmpty) 'description': _description,
                            'state': _state.name,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Crear'),
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
