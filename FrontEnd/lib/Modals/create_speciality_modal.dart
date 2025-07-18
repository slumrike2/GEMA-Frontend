import 'package:flutter/material.dart';

class CreateSpecialityModal extends StatefulWidget {
  final void Function(String especialidad) onCreate;
  final VoidCallback onCancel;

  const CreateSpecialityModal({
    super.key,
    required this.onCreate,
    required this.onCancel,
  });

  @override
  State<CreateSpecialityModal> createState() => _CreateSpecialityModalState();
}

class _CreateSpecialityModalState extends State<CreateSpecialityModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _especialidadController = TextEditingController();

  @override
  void dispose() {
    _especialidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Especialidad'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _especialidadController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la especialidad',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingrese un nombre de especialidad';
            }
            return null;
          },
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
              widget.onCreate(_especialidadController.text.trim());
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
