import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/Screens/equipos_ubicaciones_screen.dart';
import 'mantenimientos_screen.dart';
import 'cuadrillas_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const String routeName = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0;

  // Cambia el orden si quieres que el color coincida con el orden de las pantallas
  final List<Color> navColors = [
    const Color(0xFF37B4E3), // Mantenimientos
    const Color(0xFF007934), // Equipos y Ubicaciones
    const Color(0xFFFCC430), // Cuadrillas
  ];

  final List<Image> navImages = [
    Image.asset('assets/images/IconMantenimientos.png'),
    Image.asset('assets/images/IconEquiposUbicaciones.png'),
    Image.asset('assets/images/IconCuadrillas.png'),
  ];

  final List<IconData> navIcons = [
    Icons.build,
    Icons.devices,
    Icons.group,
  ];

  final List<String> navLabels = [
    'Mantenimientos',
    'Equipos y Ubicaciones',
    'Cuadrillas',
  ];

  void _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: 200,
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            backgroundColor: navColors[selectedIndex],
            leading: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 64,
                    child: navImages[selectedIndex],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Panel',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.black, size: 28),
                tooltip: 'Cerrar sesión',
                onPressed: _handleLogout,
              ),
            ),
            destinations: List.generate(
              navIcons.length,
              (i) => NavigationRailDestination(
                icon: Icon(navIcons[i], color: Colors.black),
                selectedIcon: Icon(navIcons[i], color: Colors.black),
                label: Text(
                  navLabels[i],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: i == selectedIndex ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.black,
              size: 28,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Colors.black,
              size: 28,
            ),
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(width: 1, thickness: 1),
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
