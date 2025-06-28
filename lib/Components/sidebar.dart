import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Definir los colores de fondo para cada pantalla
    final List<Color> sidebarColors = [
      const Color(0xFF0A3444), // Azul para la primera pantalla
      const Color(0xFF002811), // Verde para la segunda pantalla
      const Color(0xFF2C2001), // Amarillo para la tercera pantalla
    ];

    final items = [
      _SidebarItem(
        icon: Icons.build,
        label: 'Mantenimientos',
        isSelected: selectedIndex == 0,
        onTap: () => onItemSelected(0),
      ),
      _SidebarItem(
        icon: Icons.devices,
        label: 'Equipos y Ubicaciones',
        isSelected: selectedIndex == 1,
        onTap: () => onItemSelected(1),
      ),
      _SidebarItem(
        icon: Icons.group,
        label: 'Cuadrillas',
        isSelected: selectedIndex == 2,
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
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Icon(Icons.construction, size: 48, color: Colors.white),
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
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
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
          color: isSelected ? const Color(0xFF2D9CDB) : Colors.transparent,
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
