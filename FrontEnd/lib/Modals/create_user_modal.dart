import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class CreateUserModal extends StatefulWidget {
  final void Function(String email, String role, {String? name}) onCreate;
  final String? initialEmail;
  final String? initialRole;
  final String? initialName;
  final bool isEdit;
  const CreateUserModal({
    super.key,
    required this.onCreate,
    this.initialEmail,
    this.initialRole,
    this.initialName,
    this.isEdit = false,
  });

  @override
  State<CreateUserModal> createState() => CreateUserModalState();
}

class CreateUserModalState extends State<CreateUserModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  String _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedRole = widget.initialRole ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Color(0xFF219653), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEdit ? 'Editar usuario' : 'Crear usuario',
                    style: const TextStyle(
                      color: Color(0xFF219653),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
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
                widget.isEdit
                    ? 'Modifica la información del usuario. Los cambios se aplicarán inmediatamente.'
                    : 'Completa la información para crear un nuevo usuario.',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              if (widget.isEdit) ...[
                Text(
                  'Nombre',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.black54,
                    ),
                    hintText: 'Nombre completo',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Correo electrónico
              Text(
                'Correo electrónico',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _emailController,
                enabled: !widget.isEdit,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                  hintText: 'usuario@ejemplo.com',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
              // Rol
              Text(
                'Rol',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined, color: Colors.black54),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Usuario')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFF2F2F2),
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: botonGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onCreate(
                          _emailController.text.trim(),
                          _selectedRole,
                          name: _nameController.text.trim(),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      widget.isEdit ? 'Guardar cambios' : 'Crear usuario',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
