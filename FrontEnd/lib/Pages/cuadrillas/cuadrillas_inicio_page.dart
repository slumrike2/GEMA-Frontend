import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';

class CuadrillasInicioPage extends StatelessWidget {
  final List<TechnicalTeam> cuadrillas;
  final VoidCallback onCrearCuadrilla;
  final VoidCallback onCrearOModificarPersona;
  final void Function(TechnicalTeam) onVerMantenimientos;
  final void Function(TechnicalTeam) onModificar;

  const CuadrillasInicioPage({
    super.key,
    required this.cuadrillas,
    required this.onCrearCuadrilla,
    required this.onCrearOModificarPersona,
    required this.onVerMantenimientos,
    required this.onModificar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
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
              // Botones superiores
              Padding(
                padding: const EdgeInsets.only(right: 35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onCrearCuadrilla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196B6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text("Crear Cuadrilla"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onCrearOModificarPersona,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196B6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text("Crear o Modificar Persona"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Cuadrillas
              ...cuadrillas.map((cuadrilla) {
                final nombre = cuadrilla.name.isNotEmpty ? cuadrilla.name : 'Sin nombre';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado cuadrilla
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF93D7F3),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(17),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
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
                              if (cuadrilla.speciality != null && cuadrilla.speciality!.isNotEmpty)
                                Text(
                                  "Especialidad: ${cuadrilla.speciality}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF22356A),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => onVerMantenimientos(cuadrilla),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2293B4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 7,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text("Ver Mantenimientos"),
                            ),
                            const SizedBox(width: 22),
                            ElevatedButton(
                              onPressed: () => onModificar(cuadrilla),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2293B4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 7,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
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
    );
  }
}
