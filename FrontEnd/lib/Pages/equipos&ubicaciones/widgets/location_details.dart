import 'package:flutter/material.dart';
import 'package:frontend/Components/custom_card.dart';
import 'package:frontend/Components/status_chip.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:frontend/utils/template_processor.dart';

class LocationDetails extends StatelessWidget {
  final TechnicalLocation location;
  final Map<String, TechnicalLocation> locations;
  final Map<String, Equipment> equipment;
  final Map<String, LocationType> locationTypes;
  final Map<int, Brand> brands;
  final List<EquipmentOperationalLocation> operationalLocations;
  final String Function(String) getFullPath;

  const LocationDetails({
    super.key,
    required this.location,
    required this.locations,
    required this.equipment,
    required this.locationTypes,
    required this.brands,
    required this.operationalLocations,
    required this.getFullPath,
  });

  @override
  Widget build(BuildContext context) {
    final typeName = TemplateProcessor.getLocationTypeName(
      location.type,
      locationTypes,
    );
    final icon =
        AppConstants.locationTypeIcons[typeName] ??
        AppConstants.locationTypeIcons["default"]!;

    // Equipment physically in this location
    final equipmentInLocation = TemplateProcessor.getEquipmentInLocation(
      location.technicalCode,
      equipment,
    );

    // Equipment operating in this location
    final equipmentOperating =
        TemplateProcessor.getEquipmentOperatingInLocation(
          location.technicalCode,
          equipment,
          operationalLocations,
        );

    // Child locations
    final childLocations =
        TemplateProcessor.getChildLocations(location.technicalCode, locations)
            .map((code) => locations[code])
            .where((loc) => loc != null)
            .cast<TechnicalLocation>()
            .toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getFullPath(location.technicalCode),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        typeName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
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
            ],
          ),

          const SizedBox(height: 24),

          // Basic Information
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Código Técnico',
                  location.technicalCode,
                  isCode: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Tipo de Ubicación', typeName)),
            ],
          ),

          const SizedBox(height: 16),

          // Child Locations
          if (childLocations.isNotEmpty) ...[
            _buildSectionTitle('Ubicaciones Hijas (${childLocations.length})'),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: childLocations.length,
                itemBuilder: (context, index) {
                  final child = childLocations[index];
                  final childTypeName = TemplateProcessor.getLocationTypeName(
                    child.type,
                    locationTypes,
                  );
                  final childIcon =
                      AppConstants.locationTypeIcons[childTypeName] ??
                      AppConstants.locationTypeIcons["default"]!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(childIcon, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            child.name,
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
                            child.technicalCode,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 4),
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
                            childTypeName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Divider(),
          const SizedBox(height: 16),

          // Equipment Information
          Row(
            children: [
              Expanded(
                child: _buildEquipmentSection(
                  '📍 Equipos Instalados Físicamente',
                  equipmentInLocation,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEquipmentSection(
                  '⚙️ Equipos Operando Aquí',
                  equipmentOperating,
                  Colors.green,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildEquipmentSection(
    String title,
    List<Equipment> equipmentList,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${equipmentList.length})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              equipmentList.isEmpty
                  ? Center(
                    child: Text(
                      title.contains('Físicamente')
                          ? 'No hay equipos instalados físicamente'
                          : 'No hay equipos operando en esta ubicación',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: equipmentList.length,
                    itemBuilder: (context, index) {
                      final eq = equipmentList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.build, size: 16, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eq.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    TemplateProcessor.getBrandName(
                                      eq.brandId,
                                      brands,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (eq.state != null)
                              StatusChip(equipmentState: eq.state),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
