import 'package:flutter/material.dart';

class CreateTechnicianModal extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onCreate;
  final VoidCallback onCancel;
  final Map<String, dynamic>? initialData; // Opcional: para editar en el futuro

  const CreateTechnicianModal({
    super.key,
    required this.onCreate,
    required this.onCancel,
    this.initialData,
  });

  @override
  State<CreateTechnicianModal> createState() => _CreateTechnicianModalState();
}

class _CreateTechnicianModalState extends State<CreateTechnicianModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _personalIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _personalIdController = TextEditingController(text: widget.initialData?['personalId'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData != null ? 'Editar Técnico' : 'Registrar Técnico'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingrese el nombre del técnico'
                    : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _personalIdController,
                decoration: const InputDecoration(labelText: 'Cédula / Identificación'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingrese la identificación'
                    : null,
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
                'personalId': _personalIdController.text.trim(),
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
