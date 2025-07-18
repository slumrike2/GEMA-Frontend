import 'package:flutter/material.dart';
import 'package:frontend/Components/custom_card.dart';
import 'package:frontend/Components/status_chip.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:frontend/utils/template_processor.dart';

class EquipmentItem extends StatelessWidget {
  final Equipment equipment;
  final Map<int, Brand> brands;
  final Map<String, TechnicalLocation> locations;
  final bool isSelected;
  final VoidCallback onSelect;

  const EquipmentItem({
    super.key,
    required this.equipment,
    required this.brands,
    required this.locations,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: CustomCard(
        isSelected: isSelected,
        child: Row(
          children: [
            const Icon(Icons.build, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          equipment.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          equipment.technicalCode,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${TemplateProcessor.getBrandName(equipment.brandId, brands)} • ${equipment.serialNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (equipment.technicalLocation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${TemplateProcessor.getLocationName(equipment.technicalLocation, locations)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (equipment.state != null)
                  StatusChip(equipmentState: equipment.state),
                if (equipment.state == EquipmentState.transferencia_pendiente &&
                    equipment.transferLocation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_shipping,
                        size: 12,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '→ ${TemplateProcessor.getLocationName(equipment.transferLocation, locations)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
