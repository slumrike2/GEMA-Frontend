import 'package:flutter/material.dart';
import '../Components/sidebar.dart';
import 'mantenimientos_screen.dart';
import 'equipos_ubicaciones_screen.dart';
import 'cuadrillas_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedPage,
            onItemSelected: (index) {
              setState(() {
                _selectedPage = index;
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedPage,
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
