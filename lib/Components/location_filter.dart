import 'package:flutter/material.dart';
import 'package:frontend/Components/tag.dart';

class EquiposUbicacionesPanel extends StatelessWidget {
  final TextEditingController? controller;

  const EquiposUbicacionesPanel({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Buscar...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black12),
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
      ],
    );
  }
}