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

  final List<IconData> _navIcons = [Icons.build, Icons.devices, Icons.group];
  final List<String> _navLabels = [
    'Mantenimientos',
    'Equipos y Ubicaciones',
    'Cuadrillas',
  ];

  @override
  Widget build(BuildContext context) {
    // Definir los colores de fondo para cada pantalla
    final List<Color> navColors = [
      const Color(0xFF2C2001), // Amarillo para Mantenimientos
      const Color(0xFF002811), // Verde para ubicaciones y equipos
      const Color(0xFF0A3444), // Azul para personal y cuadrillas
    ];

    final List<Color> selectedItemColors = [
      const Color.fromARGB(255, 255, 198, 39), // Amarillo para Mantenimientos
      const Color.fromARGB(255, 0, 121, 52), // Verde para Equipos y Ubicaciones
      const Color.fromARGB(255, 65, 180, 229), // Azul para Cuadrillas
    ];

    // Lista de iconos del sidebar
    final List<String> navLogos = [
      'Icon/Status=Yellow.png', // Icono para Mantenimientos
      'Icon/Status=Green.png', // Icono para Equipos y Ubicaciones
      'Icon/Status=Blue.png', // Icono para Cuadrillas
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: 200,
            selectedIndex: selectedIndex,
            indicatorColor: Colors.transparent,
            
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            backgroundColor: navColors[selectedIndex],
            leading: LayoutBuilder(
              builder: (context, constraints) {
                // Calcula el tamaño del icono como un porcentaje del ancho de la barra
                final double iconSize = (constraints.maxWidth * 0.8).clamp(32, 150);
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: [
                      Image.asset(
                        navLogos[selectedIndex],
                        width: iconSize,
                        height: iconSize/2,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Panel',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
            destinations: List.generate(
              _navIcons.length,
              (i) => NavigationRailDestination(
                indicatorColor: Colors.transparent,
                icon: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: i == selectedIndex ? selectedItemColors[i] : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        _navIcons[i],
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _navLabels[i],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: i == selectedIndex ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                label: const SizedBox.shrink(),
              ),
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
