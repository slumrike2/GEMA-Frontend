import 'package:flutter/material.dart';
import 'package:frontend/Components/sidebar.dart';

class MantenimientosScreen extends StatelessWidget {
  const MantenimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedIndex: 0),
          Expanded(
            child: Center(
              child: Text(
                'Bienvenido, Administrador1. \nEsta es la pantalla de Mantenimientos, la cual aun no está definida.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}