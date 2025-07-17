import 'package:flutter/material.dart';
import '../Models/backend_types.dart'; // Importa aquí tu modelo User

class CreateTechnicianModal extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onCreate;
  final VoidCallback onCancel;
  final List<String> especialidades;
  final List<User>? usuariosDisponibles; // Usuarios para dropdown (opcional)

  const CreateTechnicianModal({
    super.key,
    required this.onCreate,
    required this.onCancel,
    required this.especialidades,
    this.usuariosDisponibles,
  });

  @override
  State<CreateTechnicianModal> createState() => _CreateTechnicianModalState();
}

class _CreateTechnicianModalState extends State<CreateTechnicianModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _personalIdController;
  late TextEditingController _contactController;
  late TextEditingController _nameController;
  String? _speciality;

  User? _selectedUser; // Usuario seleccionado en dropdown

  @override
  void initState() {
    super.initState();
    _personalIdController = TextEditingController();
    _contactController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _personalIdController.dispose();
    _contactController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onUserSelected(User? user) {
    setState(() {
      _selectedUser = user;
      if (user != null) {
        // Usa ?? '' para evitar valores nulos
        _nameController.text = user.name ?? '';
        _contactController.text = user.email ?? '';
        _personalIdController.clear(); // Sin personalId en User, queda vacío para llenar manualmente
      } else {
        _nameController.clear();
        _personalIdController.clear();
        _contactController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Técnico'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.usuariosDisponibles != null && widget.usuariosDisponibles!.isNotEmpty) ...[
                  DropdownButtonFormField<User>(
                    decoration: const InputDecoration(labelText: 'Seleccionar usuario'),
                    items: widget.usuariosDisponibles!
                        .map((u) => DropdownMenuItem<User>(
                              value: u,
                              child: Text((u.name?.isNotEmpty ?? false) ? u.name! : (u.email ?? 'Sin nombre')),
                            ))
                        .toList(),
                    onChanged: _onUserSelected,
                    value: _selectedUser,
                    validator: (v) => (v == null) ? 'Seleccione un usuario' : null,
                  ),
                  const SizedBox(height: 12),
                ],

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ingrese el nombre del técnico' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _personalIdController,
                  decoration: const InputDecoration(labelText: 'Cédula / Identificación'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingrese la identificación';
                    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Solo números';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contacto (teléfono/email)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese contacto' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: widget.especialidades.contains(_speciality) ? _speciality : null,
                  items: widget.especialidades
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _speciality = v),
                  decoration: const InputDecoration(labelText: 'Especialidad'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Seleccione especialidad' : null,
                ),
              ],
            ),
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
              final data = {
                'name': _nameController.text.trim(),
                'personalId': _personalIdController.text.trim(),
                'contact': _contactController.text.trim(),
                'speciality': _speciality,
              };
              if (_selectedUser != null) {
                data['uuid'] = _selectedUser!.uuid; // Pasa el UUID del usuario seleccionado
              }
              widget.onCreate(data);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
