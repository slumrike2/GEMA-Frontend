import 'package:flutter/material.dart';
import '../../Services/technician_service.dart';
import '../../Services/technical_team_service.dart';
import '../../Services/technician_speciality_service.dart';

class CrearModificarPersonaPage extends StatefulWidget {
  final Map<String, dynamic>? personaData;
  final VoidCallback? onSuccess;

  const CrearModificarPersonaPage({
    super.key,
    this.personaData,
    this.onSuccess,
  });

  @override
  State<CrearModificarPersonaPage> createState() =>
      _CrearModificarPersonaPageState();
}

class _CrearModificarPersonaPageState extends State<CrearModificarPersonaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _personalIdController;
  late TextEditingController _contactController;
  late TextEditingController _nameController;
  String? _selectedSpeciality;
  String? _selectedTechnicalTeamUuid;

  List<String> especialidades = [];
  List<Map<String, dynamic>> technicalTeams = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _personalIdController =
        TextEditingController(text: widget.personaData?['personalId']?.toString() ?? '');
    _contactController =
        TextEditingController(text: widget.personaData?['contact']?.toString() ?? '');
    _nameController =
        TextEditingController(text: widget.personaData?['name']?.toString() ?? '');

    _selectedSpeciality = widget.personaData?['speciality']?.toString();
    _selectedTechnicalTeamUuid = widget.personaData?['technicalTeamId']?.toString();

    _loadDataFromAPI();
  }

  Future<void> _loadDataFromAPI() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        TechnicianSpecialityService.getAll(),
        TechnicalTeamService.getAll(),
      ]);
      final especs = List<String>.from(results[0]);
      final teams = List<Map<String, dynamic>>.from(results[1]);

      if (!mounted) return;
      setState(() {
        especialidades = especs;
        technicalTeams = teams;

        if (!especialidades.contains(_selectedSpeciality)) {
          _selectedSpeciality = null;
        }
        if (_selectedTechnicalTeamUuid != null &&
            !technicalTeams.any((t) => t["id"].toString() == _selectedTechnicalTeamUuid)) {
          _selectedTechnicalTeamUuid = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _onGuardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => isLoading = true);

    final data = {
      "name": _nameController.text.trim(),
      "personalId": _personalIdController.text.trim(),
      "contact": _contactController.text.trim(),
      "speciality": _selectedSpeciality,
      "technicalTeamId": _selectedTechnicalTeamUuid,
    };

    try {
      if (widget.personaData?['uuid'] != null) {
        await TechnicianService.update(widget.personaData!['uuid'].toString(), data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico actualizado exitosamente')),
        );
      } else {
        await TechnicianService.create(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico creado exitosamente')),
        );
      }
      widget.onSuccess?.call();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _onEliminar() async {
    if (widget.personaData?['uuid'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede eliminar un técnico que no existe')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar este técnico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      await TechnicianService.delete(widget.personaData!['uuid'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Técnico eliminado exitosamente')),
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _personalIdController.dispose();
    _contactController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personaData == null ? 'Crear Técnico' : 'Modificar Técnico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campos formulario
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _personalIdController,
                decoration: const InputDecoration(
                  labelText: 'Cédula / Identificación',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese la identificación';
                  if (!RegExp(r'^\d+$').hasMatch(v)) return 'Solo números';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contacto (teléfono/email)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingrese el contacto' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: especialidades.contains(_selectedSpeciality)
                    ? _selectedSpeciality
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                  border: OutlineInputBorder(),
                ),
                items: especialidades
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSpeciality = v),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Seleccione especialidad' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: technicalTeams.any((t) => t['id'].toString() == _selectedTechnicalTeamUuid)
                    ? _selectedTechnicalTeamUuid
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Equipo Técnico',
                  border: OutlineInputBorder(),
                ),
                items: technicalTeams
                    .map((t) => DropdownMenuItem<String>(
                          value: t['id'].toString(),
                          child: Text(t['name'] ?? 'Sin nombre'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTechnicalTeamUuid = v),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.personaData != null)
                    ElevatedButton(
                      onPressed: _onEliminar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5443),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  if (widget.personaData != null) const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _onGuardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2293B4),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text('Guardar'),
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
