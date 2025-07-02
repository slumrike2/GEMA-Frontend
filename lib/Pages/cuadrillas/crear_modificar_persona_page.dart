import 'package:flutter/material.dart';
import '../../Services/technician_service.dart';
import '../../Services/technical_team_service.dart';
import '../../Services/technician_speciality_service.dart';
import '../../Models/backend_types.dart';

class CrearModificarPersonaPage extends StatefulWidget {
  final Map<String, dynamic>? personaData;
  const CrearModificarPersonaPage({super.key, this.personaData});

  @override
  State<CrearModificarPersonaPage> createState() =>
      _CrearModificarPersonaPageState();
}

class _CrearModificarPersonaPageState extends State<CrearModificarPersonaPage> {
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cuadrillaController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  // Listas para cargar datos desde la API
  List<TechnicalTeam> technicalTeams = [];
  List<String> specialities = [];
  String? selectedSpeciality;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializar con datos existentes si se proporcionan
    if (widget.personaData != null) {
      cedulaController.text = widget.personaData!['personalId'] ?? '';
      nombreController.text = widget.personaData!['name'] ?? '';
      cuadrillaController.text = widget.personaData!['technicalTeam'] ?? '';
      contactController.text = widget.personaData!['contact'] ?? '';
      selectedSpeciality = widget.personaData!['speciality'];
    }

    _loadDataFromAPI();
  }

  // Cargar datos desde la API
  Future<void> _loadDataFromAPI() async {
    setState(() {
      isLoading = true;
    });
    try {
      final teamsFuture = TechnicalTeamService.getAll();
      final specialitiesFuture = TechnicianSpecialityService.getAll();
      final results = await Future.wait([teamsFuture, specialitiesFuture]);
      setState(() {
        technicalTeams = results[0] as List<TechnicalTeam>;
        specialities = List<String>.from(results[1]);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  Future<void> _onBuscar() async {
    if (cedulaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese una cédula para buscar'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final technician = await TechnicianService.getByUuid(
        cedulaController.text,
      );
      setState(() {
        nombreController.text = technician['name'] ?? '';
        cuadrillaController.text = technician['technicalTeam'] ?? '';
        contactController.text = technician['contact'] ?? '';
        selectedSpeciality = technician['speciality'];
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Técnico encontrado')));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al buscar técnico: $e')));
    }
  }

  Future<void> _onGuardar() async {
    if (cedulaController.text.isEmpty || nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Preparar datos del técnico
      final technicianData = {
        'personalId': cedulaController.text,
        'name': nombreController.text,
        'technicalTeam': cuadrillaController.text,
        'contact': contactController.text,
        'speciality': selectedSpeciality,
      };

      if (widget.personaData?['uuid'] != null) {
        // Actualizar técnico existente
        await TechnicianService.update(
          widget.personaData!['uuid'],
          technicianData,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico actualizado exitosamente')),
        );
      } else {
        // Crear nuevo técnico
        await TechnicianService.create(technicianData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico creado exitosamente')),
        );
      }

      // Regresar a la página anterior
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onEliminar() async {
    if (widget.personaData?['uuid'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar un técnico que no existe'),
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Está seguro de que desea eliminar este técnico?',
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
        await TechnicianService.delete(widget.personaData!['uuid']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnico eliminado exitosamente')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    cedulaController.dispose();
    nombreController.dispose();
    cuadrillaController.dispose();
    contactController.dispose();
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
                'Crear/Modificar Técnico',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Arial",
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Campo cédula + buscar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cedula', style: TextStyle(fontSize: 15)),
                        const SizedBox(height: 5),
                        TextField(
                          controller: cedulaController,
                          style: const TextStyle(fontSize: 17),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 9,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onBuscar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2293B4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),
            // Campo nombre
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
                  const Text('Nombre', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: nombreController,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Campo contacto
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
                  const Text('Contacto', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: contactController,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      hintText: 'Teléfono, email, etc.',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Campo especialidad
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
                  const Text('Especialidad', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedSpeciality,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    hint: const Text('Seleccione una especialidad'),
                    items:
                        specialities.map((String speciality) {
                          return DropdownMenuItem<String>(
                            value: speciality,
                            child: Text(speciality),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSpeciality = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Campo cuadrilla
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Equipo Técnico', style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: cuadrillaController,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.personaData?['uuid'] != null)
                  ElevatedButton(
                    onPressed: isLoading ? null : _onEliminar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5443),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text('Eliminar'),
                  ),
                if (widget.personaData?['uuid'] != null)
                  const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _onGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2293B4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
