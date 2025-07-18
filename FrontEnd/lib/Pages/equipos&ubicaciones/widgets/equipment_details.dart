import 'package:flutter/material.dart';
import 'package:frontend/Components/custom_card.dart';
import 'package:frontend/Components/status_chip.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Modals/assign_location_modal.dart';
import 'package:frontend/Modals/schedule_move_modal.dart';
import 'package:frontend/Services/equipment_service.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:frontend/utils/template_processor.dart';

class EquipmentDetails extends StatelessWidget {
  final Equipment equipment;
  final Map<String, TechnicalLocation> locations;
  final Map<int, Brand> brands;
  final List<EquipmentOperationalLocation> operationalLocations;
  final void Function() refetchOperationalLocations;
  final String Function(String) getFullPath;
  final VoidCallback onRefetch;

  const EquipmentDetails({
    super.key,
    required this.equipment,
    required this.locations,
    required this.refetchOperationalLocations,
    required this.brands,
    required this.operationalLocations,
    required this.getFullPath,
    required this.onRefetch,
  });

  void _showAssignLocationModal(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AssignLocationModal(
            onRefetch: onRefetch,
            refetchOperationalLocations: refetchOperationalLocations,
            equipment: equipment,
            locations: locations,
            operationalLocations: operationalLocations,
            onSave: (technicalLocationId, operationalLocationIds) {
              // TODO: Implement save logic (update equipment and operational locations)
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = brands[equipment.brandId];
    final physicalLocation =
        equipment.technicalLocation != null
            ? locations[equipment.technicalLocation!]
            : null;

    // Get operational locations for this equipment
    final operationalLocationCodes =
        operationalLocations
            .where((op) => op.equipmentId == equipment.uuid)
            .map((op) => op.locationId)
            .toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.build, color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${brand?.name ?? "Sin marca"} • ${equipment.serialNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (equipment.state != null)
                          StatusChip(equipmentState: equipment.state),
                        if (equipment.technicalLocation != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '📍 ${TemplateProcessor.getLocationName(equipment.technicalLocation, locations)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Edit functionality
                },
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _showDeleteDialog(context);
                },
                icon: const Icon(Icons.delete),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Basic Information
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Código Técnico',
                  equipment.technicalCode,
                  isCode: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard('Marca', brand?.name ?? "Sin marca"),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          _buildInfoCard(
            'Descripción',
            equipment.description?.isEmpty == false
                ? equipment.description!
                : "Sin descripción",
          ),

          const SizedBox(height: 16),

          // Physical Location
          if (physicalLocation != null) ...[
            _buildInfoCard(
              'Ubicación Física',
              '${physicalLocation.name} (${physicalLocation.technicalCode})',
            ),
            const SizedBox(height: 16),
          ],

          // Transfer Location
          if (equipment.transferLocation != null) ...[
            _buildInfoCard(
              'Ubicación de Transferencia',
              '${TemplateProcessor.getLocationName(equipment.transferLocation, locations)} (${equipment.transferLocation})',
            ),
            const SizedBox(height: 16),
          ],

          // Dependencies
          if (equipment.dependsOn != null) ...[
            _buildInfoCard('Depende de', equipment.dependsOn!),
            const SizedBox(height: 16),
          ],

          // Operational Locations
          if (operationalLocationCodes.isNotEmpty) ...[
            const Text(
              'Ubicaciones Operativas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...operationalLocationCodes.map((locationCode) {
              final location = locations[locationCode];
              if (location == null) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.room, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        location.technicalCode,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],

          const Divider(),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignLocationModal(context),
                  icon: const Icon(Icons.room),
                  label: const Text('Asignar Ubicaciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Builder(
                  builder:
                      (context) => ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => ScheduleMoveModal(
                                  equipment: equipment,
                                  locations: locations,
                                  onScheduleMove: (destinationId, date, notes) {
                                    // TODO: Implement scheduling logic (update equipment transferLocation)
                                  },
                                  onConfirmMove: () {
                                    // TODO: Implement confirmation logic (update equipment state and location)
                                  },
                                ),
                          );
                        },
                        icon: const Icon(Icons.local_shipping),
                        label: Text(
                          equipment.state ==
                                  EquipmentState.transferencia_pendiente
                              ? 'Gestionar Mudanza'
                              : 'Programar Mudanza',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {bool isCode = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: isCode ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar equipo'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este equipo? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await EquipmentService.delete(equipment.uuid ?? '');
                    onRefetch();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Equipo eliminado correctamente'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar el equipo: $e'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
