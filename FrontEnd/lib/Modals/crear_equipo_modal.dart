import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Components/searchable_combobox.dart';
import 'package:frontend/Services/equipment_service.dart';
import 'package:collection/collection.dart';

class CrearEquipoModal extends StatefulWidget {
  final List<Brand> brands;
  final List<TechnicalLocation> locations;
  final void Function(Map<String, dynamic> data, {Equipment? originalEquipment})
  onSubmit;
  final VoidCallback refetchEquipments;
  final bool isEdit;
  final Equipment? initialEquipment;

  const CrearEquipoModal({
    super.key,
    required this.brands,
    required this.locations,
    required this.refetchEquipments,
    required this.onSubmit,
    this.isEdit = false,
    this.initialEquipment,
  });

  static Future<void> showEdit({
    required BuildContext context,
    required List<Brand> brands,
    required List<TechnicalLocation> locations,
    required Equipment equipment,
    required VoidCallback refetchEquipments,
    required void Function(
      Map<String, dynamic> data, {
      Equipment? originalEquipment,
    })
    onSubmit,
  }) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => CrearEquipoModal(
            brands: brands,
            locations: locations,
            refetchEquipments: refetchEquipments,
            onSubmit: onSubmit,
            isEdit: true,
            initialEquipment: equipment,
          ),
    );
  }

  @override
  State<CrearEquipoModal> createState() => _CrearEquipoModalState();
}

class _CrearEquipoModalState extends State<CrearEquipoModal> {
  final _formKey = GlobalKey<FormState>();
  late String codigo;
  late String serie;
  late String nombre;
  Brand? marca;
  late String estado;
  TechnicalLocation? ubicacion;
  late String descripcion;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialEquipment != null) {
      final eq = widget.initialEquipment!;
      codigo = eq.technicalCode;
      serie = eq.serialNumber;
      nombre = eq.name;
      marca = widget.brands.firstWhereOrNull((b) => b.id == eq.brandId);
      estado = eq.state?.name ?? 'en_inventario';
      ubicacion = widget.locations.firstWhereOrNull(
        (l) => l.technicalCode == eq.technicalLocation,
      );
      descripcion = eq.description ?? '';
    } else {
      codigo = '';
      serie = '';
      nombre = '';
      marca = null;
      estado = 'en_inventario';
      ubicacion = null;
      descripcion = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final codigoController = TextEditingController(text: codigo);
    final serieController = TextEditingController(text: serie);
    final nombreController = TextEditingController(text: nombre);
    final descripcionController = TextEditingController(text: descripcion);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
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
                    Text(
                      widget.isEdit ? 'Editar Equipo' : 'Crear Nuevo Equipo',
                      style: const TextStyle(
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
                        controller: codigoController,
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
                        controller: serieController,
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
                  controller: nombreController,
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
                        value: marca,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
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
                        value: estado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
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
                  controller: descripcionController,
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
                          final data = {
                            'technicalCode': codigo,
                            'serialNumber': serie,
                            'name': nombre,
                            'brandId': marca?.id,
                            'state': estado,
                            'technicalLocation': ubicacion?.technicalCode,
                            'description': descripcion,
                          };
                          if (widget.isEdit &&
                              widget.initialEquipment != null) {
                            // Show confirmation dialog
                            final before = widget.initialEquipment!;
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('Confirmar cambios'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Antes:'),
                                        Text('Código: ${before.technicalCode}'),
                                        Text('Serie: ${before.serialNumber}'),
                                        Text('Nombre: ${before.name}'),
                                        Text('Marca: ${before.brandId}'),
                                        Text(
                                          'Estado: ${before.state?.name ?? ''}',
                                        ),
                                        Text(
                                          'Ubicación: ${before.technicalLocation ?? "(ninguna)"}',
                                        ),
                                        Text(
                                          'Descripción: ${before.description ?? ''}',
                                        ),
                                        const SizedBox(height: 12),
                                        const Text('Después:'),
                                        Text(
                                          'Código: ${data['technicalCode']}',
                                        ),
                                        Text('Serie: ${data['serialNumber']}'),
                                        Text('Nombre: ${data['name']}'),
                                        Text('Marca: ${data['brandId']}'),
                                        Text('Estado: ${data['state']}'),
                                        Text(
                                          'Ubicación: ${data['technicalLocation'] ?? "(ninguna)"}',
                                        ),
                                        Text(
                                          'Descripción: ${data['description'] ?? ''}',
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(true),
                                        child: const Text('Confirmar'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirmed != true) return;
                          }
                          try {
                            if (widget.isEdit &&
                                widget.initialEquipment != null) {
                              await EquipmentService.update(
                                widget.initialEquipment!.uuid!,
                                Equipment.fromJson({
                                  ...data,
                                  'uuid': widget.initialEquipment!.uuid,
                                }),
                              );
                            } else {
                              await EquipmentService.create(data);
                            }
                            widget.onSubmit(
                              data,
                              originalEquipment: widget.initialEquipment,
                            );
                            widget.refetchEquipments();
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al ${widget.isEdit ? 'editar' : 'crear'} equipo: $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        widget.isEdit ? 'Guardar Cambios' : 'Crear Equipo',
                      ),
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
