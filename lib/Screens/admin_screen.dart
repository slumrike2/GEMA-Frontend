import 'package:flutter/material.dart';
import 'package:frontend/Screens/equipos_ubicaciones_screen.dart';
import '../Components/sidebar.dart';
import 'mantenimientos_screen.dart';

import 'cuadrillas_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    // Puedes obtener el índice según la pantalla actual si lo necesitas
    int selectedIndex = 0; // O calcula según la ruta

    return Scaffold(
      body: Row(
        children: [
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
