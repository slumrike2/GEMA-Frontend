import 'package:flutter/material.dart';
import 'package:frontend/Components/location_filter.dart';

class EquiposUbicacionesScreen extends StatelessWidget {
  const EquiposUbicacionesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Text(
                'Ubicaciones Técnicas y Equipos',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
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
                  const SizedBox(height: 16),
                  // Panel extraído
                  EquiposUbicacionesPanel(controller: searchController),
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
