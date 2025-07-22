import 'package:flutter/material.dart';
import '../Services/technical_team_service.dart';
import '../Services/technician_service.dart';
import '../Services/technician_speciality_service.dart';
import '../Services/user_service.dart';
import '../Models/backend_types.dart';
import 'create_technician_modal.dart';
import 'create_speciality_modal.dart';

List<Map<String, dynamic>> users = [];

class CrearModificarCuadrillaPage extends StatefulWidget {
  final Map<String, dynamic>? cuadrillaData;
  final VoidCallback? onSuccess;

  const CrearModificarCuadrillaPage({
    super.key,
    this.cuadrillaData,
    this.onSuccess,
  });

  @override
  State<CrearModificarCuadrillaPage> createState() =>
      _CrearModificarCuadrillaPageState();
}

class _CrearModificarCuadrillaPageState
    extends State<CrearModificarCuadrillaPage> {
  late TextEditingController _nameController;

  // Lista solo con UUIDs de técnicos seleccionados como miembros
  List<String?> miembros = [];

  List<Map<String, dynamic>> technicians = [];
  List<String> especialidades = [];
  String? _especialidadSeleccionada;
  String? _liderSeleccionadoUuid;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.cuadrillaData?["name"]?.toString() ?? "",
    );
    _especialidadSeleccionada = widget.cuadrillaData?["speciality"]?.toString();
    _liderSeleccionadoUuid = widget.cuadrillaData?["leaderId"]?.toString();

    if (widget.cuadrillaData?["members"] != null) {
      // Inicializamos miembros con UUIDs de técnicos si existen
      miembros = List<String?>.from(
        widget.cuadrillaData!["members"].map((m) => m["uuid"]?.toString()),
      );
    } else {
      miembros = [];
    }
    _loadDataFromAPI();
  }

  Future<void> _loadDataFromAPI() async {
    setState(() {
      isLoading = true;
    });
    try {
      final techniciansFuture = TechnicianService.getAll();
      final especialidadesFuture = TechnicianSpecialityService.getAll();
      final usersFuture = UserService.getAll();
      final results = await Future.wait([
        techniciansFuture,
        especialidadesFuture,
        usersFuture,
      ]);
      final techs = List<Map<String, dynamic>>.from(results[0]);
      final especs = List<String>.from(results[1]);
      final usersList = List<User>.from(results[2]);
      // Convert users to map for easier lookup
      users =
          usersList
              .map(
                (u) => {
                  'uuid': u.uuid ?? '',
                  'name': u.name ?? '',
                  'email': u.email ?? '',
                },
              )
              .map((m) => m.map((k, v) => MapEntry(k, v.toString())))
              .toList();

      if (!mounted) return;
      setState(() {
        // Map technician name/email from users
        technicians =
            techs.map((t) {
              final Map<String, String> user = users
                  .cast<Map<String, String>>()
                  .firstWhere(
                    (u) => u['uuid'] == t['uuid'],
                    orElse:
                        () => <String, String>{
                          'name': 'Sin nombre',
                          'email': '',
                        },
                  );
              return {
                ...t,
                'name': user['name'] ?? (t['name']?.toString() ?? 'Sin nombre'),
                'email': user['email'] ?? (t['email']?.toString() ?? ''),
              };
            }).toList();
        especialidades = especs;

        if (!especialidades.contains(_especialidadSeleccionada)) {
          _especialidadSeleccionada = null;
        }
        if (_liderSeleccionadoUuid != null &&
            !technicians.any(
              (t) => t["uuid"].toString() == _liderSeleccionadoUuid,
            )) {
          _liderSeleccionadoUuid = null;
        }

        // Validar que los miembros seleccionados sigan existiendo
        miembros =
            miembros.where((uuid) {
              return uuid != null &&
                  technicians.any((t) => t["uuid"].toString() == uuid);
            }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  void _onAgregarMiembro() {
    setState(() {
      miembros.add(null); // sin técnico seleccionado inicialmente
    });
  }

  Future<void> _onEliminarMiembro(int index) async {
    if (index < 0 || index >= miembros.length) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Está seguro de que desea eliminar este miembro?',
            ),
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

    if (confirm == true) {
      setState(() {
        miembros.removeAt(index);
      });
    }
  }

  Future<void> _onGuardar() async {
    if (_nameController.text.isEmpty ||
        _especialidadSeleccionada == null ||
        especialidades.isEmpty ||
        technicians.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete todos los campos y asegúrese de que existan técnicos y especialidades',
          ),
        ),
      );
      return;
    }
    // Validar líder seleccionado
    if (_liderSeleccionadoUuid == null ||
        _liderSeleccionadoUuid == '' ||
        _liderSeleccionadoUuid == 'default') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un líder válido para la cuadrilla'),
        ),
      );
      return;
    }

    // Validar que todos los miembros tengan técnico seleccionado
    if (miembros.any((uuid) => uuid == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un técnico para cada miembro del equipo'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Construir lista de miembros con datos completos de técnicos seleccionados
      final formattedMembers =
          miembros.map((uuid) {
            final tech = technicians.firstWhere(
              (t) => t['uuid'].toString() == uuid,
            );
            return {
              "uuid": uuid,
              "name": tech['name'] ?? '',
              "personalId": tech['personalId'] ?? '',
            };
          }).toList();

      final teamData = {
        "name": _nameController.text.trim(),
        "speciality": _especialidadSeleccionada,
        "leaderId": _liderSeleccionadoUuid,
        "members": formattedMembers,
      };

      if (widget.cuadrillaData?['id'] != null) {
        await TechnicalTeamService.update(
          widget.cuadrillaData!['id'].toString(),
          teamData,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipo técnico actualizado exitosamente'),
          ),
        );
      } else {
        await TechnicalTeamService.create(teamData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo técnico creado exitosamente')),
        );
      }

      widget.onSuccess?.call();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _onEliminar() async {
    if (widget.cuadrillaData?['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar una cuadrilla que no existe'),
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Está seguro de que desea eliminar esta cuadrilla?',
            ),
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

    if (confirm == true) {
      setState(() {
        isLoading = true;
      });
      try {
        await TechnicalTeamService.delete(
          widget.cuadrillaData!['id'].toString(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipo técnico eliminado exitosamente'),
          ),
        );
        widget.onSuccess?.call();
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  // Modales para crear técnico y especialidad
  Future<void> _openCrearTecnicoModal() async {
    await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => CreateTechnicianModal(
            especialidades: especialidades,
            onCreate: (data) async {
              try {
                await TechnicianService.create(data);
                if (!mounted) return;
                Navigator.of(context).pop();
                await _loadDataFromAPI();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear técnico: $e')),
                );
              }
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
    );
  }

  Future<void> _openCrearEspecialidadModal() async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => CreateSpecialityModal(
            onCreate: (especialidad) async {
              try {
                await TechnicianSpecialityService.create(especialidad);
                if (!mounted) return;
                Navigator.of(context).pop(especialidad);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear especialidad: $e')),
                );
              }
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
    );
    if (result != null && mounted) {
      await _loadDataFromAPI();
      setState(() {
        _especialidadSeleccionada = result;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 540, minWidth: 350),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups, color: Color(0xFF2293B4)),
                  const SizedBox(width: 8),
                  const Text(
                    'Crear Nueva Cuadrilla',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Crea una nueva cuadrilla de trabajo especificando la información del equipo y su líder.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              // Información de la Cuadrilla
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2293B4),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Información de la Cuadrilla',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre de la Cuadrilla'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Ej: Cuadrilla 1: Arturo Márquez',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Especialidad'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value:
                              especialidades.contains(_especialidadSeleccionada)
                                  ? _especialidadSeleccionada
                                  : null,
                          items:
                              especialidades
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              especialidades.isEmpty
                                  ? null
                                  : (v) => setState(
                                    () => _especialidadSeleccionada = v,
                                  ),
                          decoration: const InputDecoration(
                            hintText: 'Seleccionar especialidad',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Descripción (Opcional)'),
              const SizedBox(height: 4),
              TextField(
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Descripción de las responsabilidades de la cuadrilla...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              // Información del Líder
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2293B4),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Información del Líder',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre Completo'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value:
                              technicians.any(
                                    (t) =>
                                        t["uuid"].toString() ==
                                        _liderSeleccionadoUuid,
                                  )
                                  ? _liderSeleccionadoUuid
                                  : null,
                          items:
                              technicians
                                  .map(
                                    (t) => DropdownMenuItem<String>(
                                      value: t["uuid"].toString(),
                                      child: Text(
                                        t["name"] ??
                                            t["nombre"] ??
                                            'Sin nombre',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              technicians.isEmpty
                                  ? null
                                  : (v) => setState(
                                    () => _liderSeleccionadoUuid = v,
                                  ),
                          decoration: const InputDecoration(
                            hintText: 'Nombre del líder',
                            border: OutlineInputBorder(),
                          ),
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
                        TextField(
                          controller: TextEditingController(
                            text:
                                _liderSeleccionadoUuid != null
                                    ? (technicians.firstWhere(
                                          (t) =>
                                              t["uuid"].toString() ==
                                              _liderSeleccionadoUuid,
                                          orElse: () => {},
                                        )['personalId'] ??
                                        '')
                                    : '',
                          ),
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: '12345678',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                        text:
                            _liderSeleccionadoUuid != null
                                ? (technicians.firstWhere(
                                      (t) =>
                                          t["uuid"].toString() ==
                                          _liderSeleccionadoUuid,
                                      orElse: () => {},
                                    )['contact'] ??
                                    '')
                                : '',
                      ),
                      enabled: false,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone, size: 20),
                        hintText: '+58 414-1234567',
                        border: OutlineInputBorder(),
                        labelText: 'Teléfono',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                        text:
                            _liderSeleccionadoUuid != null
                                ? (technicians.firstWhere(
                                      (t) =>
                                          t["uuid"].toString() ==
                                          _liderSeleccionadoUuid,
                                      orElse: () => {},
                                    )['email'] ??
                                    '')
                                : '',
                      ),
                      enabled: false,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, size: 20),
                        hintText: 'lider@empresa.com',
                        border: OutlineInputBorder(),
                        labelText: 'Correo Electrónico',
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed:
                        (isLoading ||
                                technicians.isEmpty ||
                                especialidades.isEmpty)
                            ? null
                            : _onGuardar,
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
                    child: const Text('Crear Cuadrilla'),
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
