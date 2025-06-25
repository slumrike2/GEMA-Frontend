import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir los colores de fondo para cada pantalla
    final List<Color> sidebarColors = [
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
    final List<String> sidebarLogos = [
      'Icon/Status=Yellow.png', // Icono para Mantenimientos
      'Icon/Status=Green.png', // Icono para Equipos y Ubicaciones
      'Icon/Status=Blue.png', // Icono para Cuadrillas
    ];

    final items = [
      _SidebarItem(
        icon: Icons.build,
        label: 'Mantenimientos',
        isSelected: selectedIndex == 0,
        selectedColor: selectedItemColors[0],
        onTap: () => onItemSelected(0),
      ),
      _SidebarItem(
        icon: Icons.devices,
        label: 'Equipos y Ubicaciones',
        isSelected: selectedIndex == 1,
        selectedColor: selectedItemColors[1],
        onTap: () => onItemSelected(1),
      ),
      _SidebarItem(
        icon: Icons.group,
        label: 'Cuadrillas',
        isSelected: selectedIndex == 2,
        selectedColor: selectedItemColors[2],
        onTap: () => onItemSelected(2),
      ),
    ];

    return Container(
      width: MediaQuery.of(context).size.width * 0.15,
      color: sidebarColors[selectedIndex],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Logo dinámico
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.12, // Ajusta el porcentaje según lo que necesites
              child: Image.asset(
                sidebarLogos[selectedIndex],
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...items,
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
