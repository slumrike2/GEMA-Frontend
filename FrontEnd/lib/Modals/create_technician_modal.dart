import 'package:flutter/material.dart';
import 'package:frontend/Services/technician_service.dart';
import '../Models/backend_types.dart';
import 'package:frontend/Services/user_service.dart';

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
  User? _liderInfo;

  Future<void> _fetchLiderInfo(String uuid) async {
    try {
      final user = await UserService.getById(uuid);
      setState(() {
        _liderInfo = user;
      });
    } catch (e) {
      setState(() {
        _liderInfo = null;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _personalIdController;
  late TextEditingController _contactController;
  String? _speciality;
  User? _selectedUser;
  List<User> _usuarios = [];
  bool _loadingUsuarios = false;

  @override
  void initState() {
    super.initState();
    _personalIdController = TextEditingController();
    _contactController = TextEditingController();
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    setState(() => _loadingUsuarios = true);
    try {
      final usuarios = await UserService.getAvailableUsers();
      final existingUsers = await TechnicianService.getAll();

      // Filtra los usuarios para excluir los que ya existen en existingUsers (por uuid)
      final existingUuids = existingUsers.map((u) => u['uuid']).toSet();
      usuarios.removeWhere((u) => existingUuids.contains(u.uuid));

      setState(() {
        _usuarios = usuarios;
        _loadingUsuarios = false;
      });
    } catch (e) {
      setState(() => _loadingUsuarios = false);
    }
  }

  @override
  void dispose() {
    _personalIdController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _onUserSelected(User? user) {
    setState(() {
      _selectedUser = user;
      _personalIdController.clear();
      _contactController.clear();
      _liderInfo = null;
    });
    if (user != null && user.uuid != null) {
      _fetchLiderInfo(user.uuid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 480,
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
              // Nombre como dropdown
              const Text('Nombre Completo'),
              const SizedBox(height: 4),
              DropdownButtonFormField<User>(
                value: _selectedUser,
                isExpanded: true,
                items:
                    _usuarios
                        .map(
                          (u) => DropdownMenuItem<User>(
                            value: u,
                            child: Text(u.name),
                          ),
                        )
                        .toList(),
                onChanged: _loadingUsuarios ? null : _onUserSelected,
                decoration: const InputDecoration(
                  hintText: 'Selecciona un usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Seleccione un usuario' : null,
                disabledHint:
                    _loadingUsuarios
                        ? const Text('Cargando usuarios...')
                        : null,
              ),
              const SizedBox(height: 12),
              // Correo y datos del líder (solo lectura)
              const Text('Correo Electrónico'),
              const SizedBox(height: 4),
              TextFormField(
                enabled: false,
                controller: TextEditingController(
                  text: _liderInfo?.email ?? _selectedUser?.email ?? '',
                ),
                decoration: const InputDecoration(
                  hintText: 'tecnico@empresa.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, size: 20),
                ),
              ),
              if (_liderInfo != null) ...[
                const SizedBox(height: 8),
                Text('Nombre: ${_liderInfo?.name ?? '-'}'),
                // Only show available fields
              ],
              const SizedBox(height: 12),
              // Cédula
              const Text('Cédula de Identidad'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _personalIdController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                buildCounter:
                    (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      int? maxLength,
                    }) => null,
                decoration: const InputDecoration(
                  hintText: '12345678',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Ingrese la identificación';
                  if (!RegExp(r'^\d+$').hasMatch(v)) return 'Solo números';
                  return null;
                },
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
              TextFormField(
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
                          'name': _selectedUser?.name ?? '',
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
