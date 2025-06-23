import 'package:flutter/material.dart';
import 'package:frontend/Components/tag.dart';

class EquiposUbicacionesScreen extends StatelessWidget {
  const EquiposUbicacionesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD6ECE0),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Ubicaciones Técnicas y Equipos',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buscar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filtros
                  Row(
                    children: [
                      Tag(label: 'Módulo 2', onRemove: () {}),
                      const SizedBox(width: 8),
                      Tag(label: 'Piso 2', onRemove: () {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Ubicaciones Hijas y Equipos
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
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
                            Tag(label: 'A2-22', onTap: () {}),
                            Tag(label: 'A2-23', onTap: () {}),
                            Tag(label: 'A2-24', onTap: () {}),
                            Tag(label: 'A2-25', onTap: () {}),
                            Tag(label: 'A2-28', onTap: () {}),
                            Tag(label: 'A2-27', onTap: () {}),
                            Tag(label: 'A2-21', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Equipos',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Tag(label: 'Botillos-1', onTap: () {}),
                            Tag(label: 'Botillos-2', onTap: () {}),
                            Tag(label: 'Bombillos-3', onTap: () {}),
                            Tag(label: 'Cam-1', onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(text: 'Ver Mantenimientos'),
                      const SizedBox(width: 8),
                      _ActionButton(text: 'Modificar'),
                      const SizedBox(width: 8),
                      _ActionButton(text: 'Crear Nuevo Equipo'),
                      const SizedBox(width: 8),
                      _ActionButton(text: 'Crear Nueva Ubicación'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  const _ActionButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onPressed: () {},
      child: Text(text),
    );
  }
}
