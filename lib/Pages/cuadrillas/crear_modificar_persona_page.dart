import 'package:flutter/material.dart';

class CrearModificarPersonaPage extends StatefulWidget {
  const CrearModificarPersonaPage({super.key});

  @override
  State<CrearModificarPersonaPage> createState() =>
      _CrearModificarPersonaPageState();
}

class _CrearModificarPersonaPageState extends State<CrearModificarPersonaPage> {
  final TextEditingController cedulaController = TextEditingController(
    text: '17849203',
  );
  final TextEditingController nombreController = TextEditingController(
    text: 'Arturo Martínez',
  );
  final TextEditingController cuadrillaController = TextEditingController(
    text: 'Cuadrilla 1',
  );

  void _onBuscar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Buscar persona (endpoint)')));
  }

  void _onGuardar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado (endpoint)')));
  }

  void _onEliminar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Eliminado (endpoint)')));
  }

  @override
  Widget build(BuildContext context) {
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
                'Crear/Modificar Persona',
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
                      onPressed: _onBuscar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2293B4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Buscar'),
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
                  const Text('Cuadrilla', style: TextStyle(fontSize: 15)),
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
                ElevatedButton(
                  onPressed: _onEliminar,
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
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _onGuardar,
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
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
