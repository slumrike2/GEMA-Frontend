import 'package:flutter/material.dart';
import '../../Models/backend_types.dart';
import '../../Modals/create_technician_modal.dart';
import 'package:frontend/Services/technician_service.dart';
import 'package:frontend/Services/user_service.dart';
import 'package:frontend/Services/technician_speciality_service.dart';

class CuadrillasInicioPage extends StatefulWidget {
  final List<TechnicalTeam> cuadrillas;
  final VoidCallback onCrearCuadrilla;
  final Future<void> Function() onRefresh;
  final void Function(TechnicalTeam) onVerMantenimientos;
  final void Function(TechnicalTeam) onModificar;

  const CuadrillasInicioPage({
    super.key,
    required this.cuadrillas,
    required this.onCrearCuadrilla,
    required this.onRefresh,
    required this.onVerMantenimientos,
    required this.onModificar,
  });

  @override
  State<CuadrillasInicioPage> createState() => _CuadrillasInicioPageState();
}

class _CuadrillasInicioPageState extends State<CuadrillasInicioPage> {
  bool _loadingModal = false;
  List<User> _usuariosDisponibles = [];
  List<String> _especialidades = [];

  Future<void> _abrirModalCrearModificarPersona() async {
    setState(() => _loadingModal = true);

    try {
      final especialidades = await TechnicianSpecialityService.getAll();
      final usuariosDisponibles = await UserService.getAvailableUsers();

      if (!mounted) return;

      setState(() {
        _especialidades = especialidades;
        _usuariosDisponibles = usuariosDisponibles;
        _loadingModal = false;
      });

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: CreateTechnicianModal(
            especialidades: _especialidades,
            usuariosDisponibles: _usuariosDisponibles,
            onCreate: (data) async {
              try {
                // Convertimos todos los campos a String
                final cleanData = data.map((k, v) =>
                    MapEntry(k, v?.toString()));

                await TechnicianService.create(cleanData);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Técnico creado/actualizado')),
                );
                Navigator.of(context).pop();
                await widget.onRefresh();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear técnico: $e')),
                );
              }
            },
            onCancel: () {
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingModal = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos para técnico: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(35, 8, 0, 12),
                    child: Text(
                      'Cuadrillas',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: "Arial",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: widget.onCrearCuadrilla,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196B6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          ),
                          child: const Text("Crear Cuadrilla"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _loadingModal ? null : _abrirModalCrearModificarPersona,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196B6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          ),
                          child: const Text("Crear o Modificar Persona"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  ...widget.cuadrillas.map((cuadrilla) {
                    final String nombre = cuadrilla.name?.toString().trim().isNotEmpty == true
                        ? cuadrilla.name!.toString()
                        : 'Sin nombre';
                    final String? especialidad = cuadrilla.speciality?.toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF93D7F3),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      nombre,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF22356A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (especialidad != null && especialidad.isNotEmpty)
                                    Text(
                                      "Especialidad: $especialidad",
                                      style: const TextStyle(fontSize: 16, color: Color(0xFF22356A)),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => widget.onVerMantenimientos(cuadrilla),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2293B4),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                                    textStyle: const TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                  ),
                                  child: const Text("Ver Mantenimientos"),
                                ),
                                const SizedBox(width: 22),
                                ElevatedButton(
                                  onPressed: () => widget.onModificar(cuadrilla),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2293B4),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                                    textStyle: const TextStyle(fontSize: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                  ),
                                  child: const Text("Modificar"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
        if (_loadingModal)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
