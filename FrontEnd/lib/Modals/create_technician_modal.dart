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
        _personalIdController
            .clear(); // Sin personalId en User, queda vacío para llenar manualmente
      } else {
        _nameController.clear();
        _personalIdController.clear();
        _contactController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add_alt_1, color: Color(0xFF2293B4)),
                  const SizedBox(width: 8),
                  const Text(
                    'Agregar Miembro al Equipo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Crear o modificar información de una persona',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre Completo'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Nombre del técnico',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Ingrese el nombre del técnico'
                                      : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cédula de Identidad'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _personalIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '12345678',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Ingrese la identificación';
                            if (!RegExp(r'^\d+$').hasMatch(v))
                              return 'Solo números';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value:
                    widget.especialidades.contains(_speciality)
                        ? _speciality
                        : null,
                items:
                    widget.especialidades
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _speciality = v),
                decoration: const InputDecoration(
                  labelText: 'Especialidad/Cargo',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Seleccione especialidad'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        hintText: '+58 424-1234567',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone, size: 20),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Ingrese contacto'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      enabled: false,
                      controller: TextEditingController(
                        text: _selectedUser?.email ?? '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        hintText: 'tecnico@empresa.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
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
                          data['uuid'] = _selectedUser!.uuid;
                        }
                        widget.onCreate(data);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2293B4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Agregar Miembro'),
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
