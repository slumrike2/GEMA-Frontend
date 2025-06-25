import 'package:flutter/material.dart';
import 'package:frontend/Components/sidebar.dart';
import 'package:frontend/Components/location_filter.dart';

class ModCrearUbicacionScreen extends StatelessWidget {
  const ModCrearUbicacionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final TextEditingController codigoController = TextEditingController();
    final TextEditingController nombreController = TextEditingController();

    int selectedIndex = 1;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedIndex: selectedIndex),
          Expanded(
            child: Container(
              color: const Color(0xFFD6ECE0),
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0), // Espacio al final
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          child: const Text(
                            'Modificar o Crear Ubicación',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Texto "Ubicación padre"
                              const Text(
                                'Ubicación padre',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Filtro de Ubicaciones
                              EquiposUbicacionesPanel(controller: searchController),
                              const SizedBox(height: 24),
                              // Input para Código Técnico con botón Buscar al lado
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: codigoController,
                                      decoration: const InputDecoration(
                                        labelText: 'Código Técnico',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: () {
                                      // Acción para buscar por código técnico
                                    },
                                    child: const Text('Buscar'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Input para Nombre
                              TextField(
                                controller: nombreController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Botones de acción al final
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: () {
                                      // Acción para eliminar ubicación
                                    },
                                    child: const Text('Eliminar'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: () {
                                      // Acción para guardar ubicación
                                    },
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}