import 'package:flutter/material.dart';

class CreateUserModal extends StatefulWidget {
  final void Function(String username, String email, String password) onCreate;
  final String? initialUsername;
  final String? initialEmail;
  final String? initialPassword;
  final bool isEdit;
  const CreateUserModal({
    super.key,
    required this.onCreate,
    this.initialUsername,
    this.initialEmail,
    this.initialPassword,
    this.isEdit = false,
  });

  @override
  State<CreateUserModal> createState() => _CreateUserModalState();
}

class _CreateUserModalState extends State<CreateUserModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialUsername ?? '',
    );
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController(
      text: widget.initialPassword ?? '',
    );
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
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Campo requerido'
                          : null,
            ),

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
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
              validator:
                  (value) =>
                      value == null || value.length < 6
                          ? 'Mínimo 6 caracteres'
                          : null,
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
              widget.onCreate(
                _usernameController.text.trim(),
                _emailController.text.trim(),
                _passwordController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.isEdit ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
