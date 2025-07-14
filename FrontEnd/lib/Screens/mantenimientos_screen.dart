import 'package:flutter/material.dart';

class MockMaintenance {
  final String equipmentName;
  final String locationCode;
  final bool isUrgent;
  final bool isPending;
  MockMaintenance({
    required this.equipmentName,
    required this.locationCode,
    this.isUrgent = false,
    this.isPending = true,
  });
}

final List<MockMaintenance> mockMaintenances = [
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'AR22',
    isUrgent: true,
    isPending: true,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'AR12',
    isUrgent: false,
    isPending: true,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'AR15',
    isUrgent: false,
    isPending: true,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'A222',
    isUrgent: true,
    isPending: true,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'A225',
    isUrgent: false,
    isPending: true,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'SUM',
    isUrgent: false,
    isPending: true,
  ),
  // Recent
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'AR22',
    isPending: false,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'AR12',
    isPending: false,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'AR15',
    isPending: false,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'A225',
    isPending: false,
  ),
  MockMaintenance(
    equipmentName: 'Aire Acondicionado',
    locationCode: 'SUM',
    isPending: false,
  ),
];

class MantenimientosScreen extends StatelessWidget {
  const MantenimientosScreen({super.key});
  static const String routeName = '/mantenimientos';

  @override
  Widget build(BuildContext context) {
    final pendientes = mockMaintenances.where((m) => m.isPending).toList();
    final recientes = mockMaintenances.where((m) => !m.isPending).toList();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Bienvenido, Administrador1',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 32),
            MaintenanceSection(
              title: 'Mantenimientos Pendientes',
              items: pendientes,
              color: const Color(0xFFFFD54F),
              urgentColor: const Color(0xFFFF8A65),
            ),
            const SizedBox(height: 24),
            MaintenanceSection(
              title: 'Mantenimientos Recientes',
              items: recientes,
              color: const Color(0xFFFFF8E1),
              urgentColor: const Color(0xFFFFF8E1),
            ),
          ],
        ),
      ),
    );
  }
}

class MaintenanceSection extends StatefulWidget {
  final String title;
  final List<MockMaintenance> items;
  final Color color;
  final Color urgentColor;
  const MaintenanceSection({
    super.key,
    required this.title,
    required this.items,
    required this.color,
    required this.urgentColor,
  });

  @override
  State<MaintenanceSection> createState() => _MaintenanceSectionState();
}

class _MaintenanceSectionState extends State<MaintenanceSection> {
  bool expanded = true;

  void _showMaintenanceInfo(MockMaintenance m) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalle de Mantenimiento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Equipo: ${m.equipmentName}'),
                Text('Ubicación: ${m.locationCode}'),
                Text('Urgente: ${m.isUrgent ? 'Sí' : 'No'}'),
                Text('Estado: ${m.isPending ? 'Pendiente' : 'Reciente'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            ...widget.items.map(
              (m) => Container(
                decoration: BoxDecoration(
                  color: m.isUrgent ? widget.urgentColor : widget.color,
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: ListTile(
                  title: Text(
                    '${m.equipmentName} - ${m.locationCode}',
                    style: TextStyle(
                      fontWeight:
                          m.isUrgent ? FontWeight.bold : FontWeight.normal,
                      color: m.isUrgent ? Colors.red[900] : Colors.black,
                    ),
                  ),
                  onTap: () => _showMaintenanceInfo(m),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
