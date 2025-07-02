import 'package:flutter/material.dart';
import '../../Services/technical_team_service.dart';
import '../../Services/technician_service.dart';

class CrearModificarCuadrillaPage extends StatefulWidget {
  final Map<String, dynamic>? cuadrillaData;
  const CrearModificarCuadrillaPage({super.key, this.cuadrillaData});

  @override
  State<CrearModificarCuadrillaPage> createState() =>
      _CrearModificarCuadrillaPageState();
}

class _CrearModificarCuadrillaPageState
    extends State<CrearModificarCuadrillaPage> {
  late TextEditingController _liderController;
  late TextEditingController _especialidadController;
  List<Map<String, String>> miembros = [];
  List<TextEditingController> _nombreControllers = [];
  List<TextEditingController> _ciControllers = [];
  
  // Listas para cargar datos desde la API
  List<dynamic> technicalTeams = [];
  List<dynamic> technicians = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _liderController = TextEditingController(
      text: widget.cuadrillaData?["nombre"]?.split(": ").last ?? "",
    );
    _especialidadController = TextEditingController(
      text: widget.cuadrillaData?["especialidad"] ?? "",
    );
    
    // Inicializar miembros vacíos o con datos existentes
    if (widget.cuadrillaData?["miembros"] != null) {
      miembros = List<Map<String, String>>.from(widget.cuadrillaData!["miembros"]);
    } else {
      miembros = [];
    }
    
    _initControllers();
    _loadDataFromAPI();
  }

  // Cargar datos desde la API
  Future<void> _loadDataFromAPI() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Cargar equipos técnicos y técnicos en paralelo
      final teamsFuture = TechnicalTeamService.getAll();
      final techniciansFuture = TechnicianService.getAll();
      
      final results = await Future.wait([teamsFuture, techniciansFuture]);
      
      setState(() {
        technicalTeams = results[0];
        technicians = results[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  void _initControllers() {
    _nombreControllers = [];
    _ciControllers = [];
    for (var m in miembros) {
      _nombreControllers.add(TextEditingController(text: m["nombre"] ?? ""));
      _ciControllers.add(TextEditingController(text: m["ci"] ?? ""));
    }
  }

  void _onAgregarMiembro() {
    setState(() {
      miembros.add({"nombre": "", "ci": ""});
      _nombreControllers.add(TextEditingController());
      _ciControllers.add(TextEditingController());
    });
  }

  void _onEliminarMiembro(int index) {
    setState(() {
      miembros.removeAt(index);
      _nombreControllers[index].dispose();
      _ciControllers[index].dispose();
      _nombreControllers.removeAt(index);
      _ciControllers.removeAt(index);
    });
  }

  Future<void> _onGuardar() async {
    if (_liderController.text.isEmpty || _especialidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos requeridos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Preparar datos de la cuadrilla
      final crewData = {
        'leader': _liderController.text,
        'speciality': _especialidadController.text,
        'members': miembros.where((m) => m['nombre']?.isNotEmpty == true && m['ci']?.isNotEmpty == true).toList(),
      };

      if (widget.cuadrillaData?['id'] != null) {
        // Actualizar equipo técnico existente
        await TechnicalTeamService.update(widget.cuadrillaData!['id'], crewData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo técnico actualizado exitosamente')),
        );
      } else {
        // Crear nuevo equipo técnico
        await TechnicalTeamService.create(crewData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo técnico creado exitosamente')),
        );
      }
      
      // Regresar a la página anterior
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onEliminar() async {
    if (widget.cuadrillaData?['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede eliminar una cuadrilla que no existe')),
      );
      return;
    }

    // Mostrar diálogo de confirmación
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
        await TechnicalTeamService.delete(widget.cuadrillaData!['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo técnico eliminado exitosamente')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _liderController.dispose();
    _especialidadController.dispose();
    for (var c in _nombreControllers) {
      c.dispose();
    }
    for (var c in _ciControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
              child:         const Text(
          'Crear/Modificar Equipo Técnico',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w400,
            fontFamily: "Arial",
          ),
        ),
            ),
            const SizedBox(height: 32),
            // Campo líder
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
                        const Text(
                          "Líder del Equipo Técnico",
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _liderController,
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
                  const Text("Especialidad", style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _especialidadController,
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
            // Miembros de la cuadrilla
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
                  const Text(
                    "Miembros del Equipo Técnico",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(miembros.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _nombreControllers[i],
                              onChanged: (val) => miembros[i]["nombre"] = val,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _ciControllers[i],
                              onChanged: (val) => miembros[i]["ci"] = val,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "CI",
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFFA5242),
                            ),
                            onPressed: () => _onEliminarMiembro(i),
                            tooltip: 'Eliminar miembro',
                          ),
                        ],
                      ),
                    );
                  }),
                  Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF2293B4),
                        size: 28,
                      ),
                      onPressed: _onAgregarMiembro,
                      tooltip: 'Agregar miembro',
                    ),
                  ),
                ],
              ),
            ),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.cuadrillaData?['id'] != null)
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
                if (widget.cuadrillaData?['id'] != null) const SizedBox(width: 20),
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
                  child: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
