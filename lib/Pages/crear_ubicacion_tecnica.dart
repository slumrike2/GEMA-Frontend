import 'package:flutter/material.dart';
import '../Components/tag.dart';

class CrearUbicacionTecnica extends StatelessWidget {
  final VoidCallback? onBack;
  const CrearUbicacionTecnica({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6ECE0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (onBack != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: onBack,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Crear/Modificar Ubicación Técnica',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ubicación Padre'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Tag(label: 'Módulo 2'),
                          const SizedBox(width: 8),
                          Tag(label: 'Piso 2'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Ubicaciones Hijas',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Tag(label: 'A2-22'),
                                Tag(label: 'A2-23'),
                                Tag(label: 'A2-24'),
                                Tag(label: 'A2-25'),
                                Tag(label: 'A2-26'),
                                Tag(label: 'A2-27'),
                                Tag(label: 'A2-21'),
                                Tag(label: 'A2-28'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Nombre'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: 'A2-21'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Agregar Equipos'),
                      const SizedBox(height: 8),
                      _EquipoRow(nombre: 'AC-1', tipo: 'Aclimatado'),
                      _EquipoRow(nombre: 'Puertas', tipo: 'Amueblado'),
                      _EquipoRow(nombre: 'Bombillos-1', tipo: 'Iluminación'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Nombre:',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Tipo:',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text('Eliminar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipoRow extends StatelessWidget {
  final String nombre;
  final String tipo;
  const _EquipoRow({required this.nombre, required this.tipo});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Nombre: $nombre')),
        Expanded(child: Text('Tipo: $tipo', textAlign: TextAlign.right)),
      ],
    );
  }
}
