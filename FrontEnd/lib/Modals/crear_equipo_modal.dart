import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Components/searchable_combobox.dart';
import 'package:frontend/constants/app_constnats.dart';

class CrearEquipoModal extends StatefulWidget {
  final List<Brand> brands;
  final List<TechnicalLocation> locations;
  final void Function(Map<String, dynamic>) onCreate;

  const CrearEquipoModal({
    super.key,
    required this.brands,
    required this.locations,
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
  String estado = 'En Inventario';
  TechnicalLocation? ubicacion;
  String descripcion = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color(0xFFF7F3FA),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.precision_manufacturing,
                        color: Color(0xFF219653),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Crear equipo',
                        style: AppTextStyles.title(color: Color(0xFF219653)),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa la información para crear un nuevo equipo.',
                    style: AppTextStyles.bodySmall(color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Código',
                    style: AppTextStyles.label(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Ej: AC-001',
                            prefixIcon: Icon(
                              Icons.qr_code,
                              color: Colors.black54,
                            ),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                          ),
                          style: AppTextStyles.bodySmall(),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty ? 'Requerido' : null,
                          onChanged: (v) => setState(() => codigo = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Serie',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                              color: Colors.black54,
                            ),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                          ),
                          style: AppTextStyles.bodySmall(),
                          onChanged: (v) => setState(() => serie = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nombre',
                    style: AppTextStyles.label(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Nombre descriptivo',
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                    style: AppTextStyles.bodySmall(),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    onChanged: (v) => setState(() => nombre = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Brand>(
                          decoration: const InputDecoration(
                            hintText: 'Marca',
                            prefixIcon: Icon(
                              Icons.label_outline,
                              color: Colors.black54,
                            ),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                          ),
                          style: AppTextStyles.bodySmall(),
                          value: marca,
                          items:
                              widget.brands
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(
                                        b.name,
                                        style: AppTextStyles.bodySmall(),
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
                            hintText: 'Estado',
                            prefixIcon: Icon(
                              Icons.settings,
                              color: Colors.black54,
                            ),
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                          ),
                          style: AppTextStyles.bodySmall(),
                          value: estado,
                          items: const [
                            DropdownMenuItem(
                              value: 'En Inventario',
                              child: Text(
                                'En Inventario',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'En Uso',
                              child: Text(
                                'En Uso',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'En Mantenimiento',
                              child: Text(
                                'En Mantenimiento',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                          onChanged:
                              (v) =>
                                  setState(() => estado = v ?? 'En Inventario'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ubicación física',
                    style: AppTextStyles.label(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  SearchableComboBox<TechnicalLocation>(
                    labelText: 'Ubicación Física (Opcional)',
                    hintText: 'Buscar ubicación...',
                    value: ubicacion,
                    items: [
                      DropdownMenuItem<TechnicalLocation>(
                        value: null,
                        child: Text(
                          'Sin asignar (en inventario)',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ),
                      ...widget.locations.map(
                        (l) => DropdownMenuItem(
                          value: l,
                          child: Text(l.name, style: AppTextStyles.bodySmall()),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => ubicacion = v),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Descripción',
                    style: AppTextStyles.label(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Descripción del equipo',
                      prefixIcon: Icon(
                        Icons.description_outlined,
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                    style: AppTextStyles.bodySmall(),
                    maxLines: 2,
                    onChanged: (v) => setState(() => descripcion = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F2),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: AppTextStyles.button(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.botonGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            widget.onCreate({
                              'codigo': codigo,
                              'serie': serie,
                              'nombre': nombre,
                              'marca': marca,
                              'estado': estado,
                              'ubicacion': ubicacion,
                              'descripcion': descripcion,
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          'Crear equipo',
                          style: AppTextStyles.button(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
