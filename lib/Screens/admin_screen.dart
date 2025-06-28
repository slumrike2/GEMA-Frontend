import 'package:flutter/material.dart';
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
  // bool _railExtended = true; // No longer needed

  final List<IconData> _navIcons = [Icons.build, Icons.devices, Icons.group];
  final List<String> _navLabels = [
    'Mantenimientos',
    'Equipos y Ubicaciones',
    'Cuadrillas',
  ];

  @override
  Widget build(BuildContext context) {
    // Color list for each index
    final List<Color> navColors = [
      Color(0xFFFCC430), // Cuadrillas
      Color(0xFF007934), // Equipos y Ubicaciones
      Color(0xFF37B4E3), // Mantenimientos
    ];
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
                children: const [
                  Icon(Icons.construction, size: 40, color: Colors.black),
                  SizedBox(height: 8),
                  Text(
                    'Panel',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            destinations: List.generate(
              _navIcons.length,
              (i) => NavigationRailDestination(
                icon: Icon(
                  _navIcons[i],
                  color: i == selectedIndex ? Colors.black : Colors.black,
                ),
                selectedIcon: Icon(_navIcons[i], color: Colors.black),
                label: Text(
                  _navLabels[i],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight:
                        i == selectedIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
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
