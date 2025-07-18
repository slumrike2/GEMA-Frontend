import 'package:flutter/material.dart';

class CreateTechnicalTeamModal extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onCreate;
  final VoidCallback onCancel;
  final Map<String, dynamic>? initialData;
  final List<String> especialidades;

  const CreateTechnicalTeamModal({
    super.key,
    required this.onCreate,
    required this.onCancel,
    required this.especialidades,
    this.initialData,
  });

  @override
  State<CreateTechnicalTeamModal> createState() => _CreateTechnicalTeamModalState();
}

class _CreateTechnicalTeamModalState extends State<CreateTechnicalTeamModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _especialidad;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData?['name'] ?? '',
    );
    _especialidad = widget.initialData?['speciality'] ?? 
      (widget.especialidades.isNotEmpty ? widget.especialidades.first : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData != null ? 'Modificar Equipo Técnico' : 'Crear Equipo Técnico'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del equipo'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingrese el nombre del equipo'
                    : null,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _especialidad,
                decoration: const InputDecoration(labelText: 'Especialidad'),
                items: widget.especialidades
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _especialidad = v),
                validator: (v) => v == null ? 'Seleccione una especialidad' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreate({
                'name': _nameController.text.trim(),
                'speciality': _especialidad,
                // Si tienes más campos, agrégalos aquí
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
