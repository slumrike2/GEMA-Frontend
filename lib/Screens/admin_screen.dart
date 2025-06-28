import 'package:flutter/material.dart';
import 'package:frontend/Screens/equipos_ubicaciones_screen.dart';
import '../Components/sidebar.dart';
import 'mantenimientos_screen.dart';

import 'cuadrillas_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const String routeName = '/admin';
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0; // O calcula según la ruta

  @override
  Widget build(BuildContext context) {
    // Puedes obtener el índice según la pantalla actual si lo necesitas

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              if (selectedIndex != index) {
                setState(() {
                  selectedIndex = index;
                });
              }
            },
          ),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                MantenimientosScreen(),
                EquiposUbicacionesScreen(),
                CuadrillasScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
