import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Components/searchable_combobox.dart';
import 'package:frontend/Services/equipment_service.dart';

class CrearEquipoModal extends StatefulWidget {
  final List<Brand> brands;
  final List<TechnicalLocation> locations;
  final void Function(Map<String, dynamic>) onCreate;
  final VoidCallback refetchEquipments;

  const CrearEquipoModal({
    super.key,
    required this.brands,
    required this.locations,
    required this.refetchEquipments,
    required this.onCreate,
  });

  @override
  State<CrearEquipoModal> createState() => _CrearEquipoModalState();
}

class _CrearEquipoModalState extends State<CrearEquipoModal> {
  final _formKey = GlobalKey<FormState>();
  String codigo = '';
  String serie = '';
  String nombre = '';
  Brand? marca;
  String estado = 'en_inventario';
  TechnicalLocation? ubicacion;
  String descripcion = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
        ), // Set your desired max width
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Crear Nuevo Equipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Código',
                          hintText: 'Ej: AC-001',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                        onChanged: (v) => setState(() => codigo = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Serie',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => setState(() => serie = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Nombre descriptivo',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onChanged: (v) => setState(() => nombre = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Brand>(
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        value: marca,
                        items:
                            widget.brands
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(
                                      b.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (b) => setState(() => marca = b),
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        value: estado,
                        items: const [
                          DropdownMenuItem(
                            value: 'instalado',
                            child: Text(
                              'Instalado',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en_mantenimiento',
                            child: Text(
                              'En Mantenimiento',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'mantenimiento_pendiente',
                            child: Text(
                              'Mantenimiento Pendiente',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en_reparaciones',
                            child: Text(
                              'En Reparaciones',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'reparaciones_pendientes',
                            child: Text(
                              'Reparaciones Pendientes',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en_inventario',
                            child: Text(
                              'En Inventario',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'descomisionado',
                            child: Text(
                              'Descomisionado',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'transferencia_pendiente',
                            child: Text(
                              'Transferencia Pendiente',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                        onChanged:
                            (v) =>
                                setState(() => estado = v ?? 'en_inventario'),
                        validator: (v) => v == null ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ubicación Física (SearchableComboBox)
                SearchableComboBox<TechnicalLocation>(
                  labelText: 'Ubicación Física (Opcional)',
                  hintText: 'Buscar ubicación...',
                  value: ubicacion,
                  items: [
                    DropdownMenuItem<TechnicalLocation>(
                      value: null,
                      child: const Text(
                        'Sin asignar (en inventario)',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    ...widget.locations.map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(
                          l.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => ubicacion = v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción del equipo',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  onChanged: (v) => setState(() => descripcion = v),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            await EquipmentService.create({
                              'technicalCode': codigo,
                              'serialNumber': serie,
                              'name': nombre,
                              'brandId': marca?.id,
                              'state': estado,
                              'technicalLocation': ubicacion?.technicalCode,
                              'description': descripcion,
                            });
                            widget.onCreate({
                              'codigo': codigo,
                              'serie': serie,
                              'nombre': nombre,
                              'marca': marca,
                              'estado': estado,
                              'ubicacion': ubicacion,
                              'descripcion': descripcion,
                            });
                            if (widget.refetchEquipments != null) {
                              widget.refetchEquipments!();
                            }
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al crear equipo: $e'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Crear Equipo'),
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
