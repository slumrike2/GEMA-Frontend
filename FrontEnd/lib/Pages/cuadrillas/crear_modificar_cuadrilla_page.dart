import 'package:flutter/material.dart';
import '../../Services/technical_team_service.dart';
import '../../Services/technician_service.dart';
import '../../Services/technician_speciality_service.dart';
import '../../Modals/create_technician_modal.dart';
import '../../Modals/create_speciality_modal.dart';

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

class _CrearModificarCuadrillaPageState extends State<CrearModificarCuadrillaPage> {
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
    _nameController =
        TextEditingController(text: widget.cuadrillaData?["name"]?.toString() ?? "");
    _especialidadSeleccionada = widget.cuadrillaData?["speciality"]?.toString();
    _liderSeleccionadoUuid = widget.cuadrillaData?["leaderId"]?.toString();

    if (widget.cuadrillaData?["members"] != null) {
      // Inicializamos miembros con UUIDs de técnicos si existen
      miembros = List<String?>.from(
        widget.cuadrillaData!["members"].map(
          (m) => m["uuid"]?.toString(),
        ),
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
      final results = await Future.wait([techniciansFuture, especialidadesFuture]);
      final techs = List<Map<String, dynamic>>.from(results[0]);
      final especs = List<String>.from(results[1]);

      if (!mounted) return;
      setState(() {
        technicians = techs;
        especialidades = especs;

        if (!especialidades.contains(_especialidadSeleccionada)) {
          _especialidadSeleccionada = null;
        }
        if (_liderSeleccionadoUuid != null &&
            !technicians.any((t) => t["uuid"].toString() == _liderSeleccionadoUuid)) {
          _liderSeleccionadoUuid = null;
        }

        // Validar que los miembros seleccionados sigan existiendo
        miembros = miembros.where((uuid) {
          return uuid != null && technicians.any((t) => t["uuid"].toString() == uuid);
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
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
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar este miembro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar')),
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
        _liderSeleccionadoUuid == null ||
        especialidades.isEmpty ||
        technicians.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Complete todos los campos y asegúrese de que existan técnicos y especialidades'),
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
      final formattedMembers = miembros.map((uuid) {
        final tech = technicians.firstWhere((t) => t['uuid'].toString() == uuid);
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
        await TechnicalTeamService.update(widget.cuadrillaData!['id'].toString(), teamData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo técnico actualizado exitosamente')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
        const SnackBar(content: Text('No se puede eliminar una cuadrilla que no existe')),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar esta cuadrilla?'),
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
        await TechnicalTeamService.delete(widget.cuadrillaData!['id'].toString());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo técnico eliminado exitosamente')),
        );
        widget.onSuccess?.call();
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
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
      builder: (context) => CreateTechnicianModal(
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
      builder: (context) => CreateSpecialityModal(
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Crear/Modificar Equipo Técnico',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Arial",
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Campo Nombre
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nombre del equipo técnico", style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
            ),

            // Campo Especialidad con modal
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Especialidad", style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: especialidades.contains(_especialidadSeleccionada)
                        ? _especialidadSeleccionada
                        : null,
                    items: especialidades
                        .map<DropdownMenuItem<String>>(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: especialidades.isEmpty
                        ? null
                        : (v) => setState(() => _especialidadSeleccionada = v),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  if (especialidades.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debe crear especialidades antes de poder asignar una.',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Especialidad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(180, 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _openCrearEspecialidadModal,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Campo Líder con modal para crear nuevo técnico
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Líder del Equipo Técnico", style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: technicians.any((t) => t["uuid"].toString() == _liderSeleccionadoUuid)
                        ? _liderSeleccionadoUuid
                        : null,
                    items: technicians
                        .map<DropdownMenuItem<String>>(
                          (t) => DropdownMenuItem<String>(
                            value: t["uuid"].toString(),
                            child: Text(t["name"] ?? t["nombre"] ?? 'Sin nombre'),
                          ),
                        )
                        .toList(),
                    onChanged: technicians.isEmpty ? null : (v) => setState(() => _liderSeleccionadoUuid = v),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  if (technicians.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debe crear técnicos antes de poder asignar un líder.',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add_alt),
                            label: const Text('Registrar Técnico'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(180, 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _openCrearTecnicoModal,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Miembros del equipo técnico - dropdown para técnicos existentes
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Miembros del Equipo Técnico", style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  ...List.generate(miembros.length, (i) {
                    final selectedUuid = miembros[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: selectedUuid,
                              items: technicians.map((tech) {
                                return DropdownMenuItem(
                                  value: tech['uuid'].toString(),
                                  child: Text(tech['name'] ?? 'Sin nombre'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  miembros[i] = val;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Seleccionar Técnico',
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                border:
                                    OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                              ),
                              validator: (v) => v == null ? 'Seleccione un técnico' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Text(
                              selectedUuid != null
                                  ? (technicians.firstWhere((t) => t['uuid'].toString() == selectedUuid)['personalId'] ?? '')
                                  : '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 7),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFFA5242)),
                            onPressed: () => _onEliminarMiembro(i),
                            tooltip: 'Eliminar miembro',
                          ),
                        ],
                      ),
                    );
                  }),
                  Center(
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Color(0xFF2293B4), size: 28),
                      onPressed: _onAgregarMiembro,
                      tooltip: 'Agregar miembro',
                    ),
                  ),
                ],
              ),
            ),

            // Botones para eliminar o guardar equipo técnico
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.cuadrillaData?['id'] != null)
                  ElevatedButton(
                    onPressed: isLoading ? null : _onEliminar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5443),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text('Eliminar'),
                  ),
                if (widget.cuadrillaData?['id'] != null) const SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      (isLoading || technicians.isEmpty || especialidades.isEmpty)
                          ? null
                          : _onGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2293B4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
