import 'package:flutter/material.dart';

class CreateUserModal extends StatefulWidget {
  final void Function(String email, String role) onCreate;
  final String? initialEmail;
  final String? initialRole;
  final bool isEdit;
  const CreateUserModal({
    super.key,
    required this.onCreate,
    this.initialEmail,
    this.initialRole,
    this.isEdit = false,
  });

  @override
  State<CreateUserModal> createState() => CreateUserModalState();
}

class CreateUserModalState extends State<CreateUserModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  String _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Editar usuario' : 'Crear nuevo usuario'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
              keyboardType: TextInputType.emailAddress,

              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Campo requerido';
                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                ).hasMatch(value.trim())) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: [
                DropdownMenuItem(value: 'user', child: Text('Usuario')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreate(_emailController.text.trim(), _selectedRole);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.isEdit ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
