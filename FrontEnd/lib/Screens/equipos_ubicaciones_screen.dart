import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Models/initial_data.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/equipment_details.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/location_details.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/tipo_details.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/navigation_panel.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:frontend/utils/template_processor.dart';

class EquiposUbicacionesScreen extends StatefulWidget {
  const EquiposUbicacionesScreen({super.key});

  @override
  State<EquiposUbicacionesScreen> createState() =>
      _EquiposUbicacionesScreenState();
}

class _EquiposUbicacionesScreenState extends State<EquiposUbicacionesScreen> {
  // Data
  Map<String, TechnicalLocation> locations = Map.from(
    InitialData.technicalLocations,
  );
  Map<String, Equipment> equipment = Map.from(InitialData.equipment);
  Map<int, Brand> brands = Map.from(InitialData.brands);
  Map<String, LocationType> locationTypes = Map.from(InitialData.locationTypes);
  List<EquipmentOperationalLocation> operationalLocations = List.from(
    InitialData.operationalLocations,
  );

  // UI State
  String searchTerm = "";
  Set<String> expandedNodes = {"SEDE-GY", "EDIF-A"};
  String? selectedItem;
  String selectedType = "location";
  String activeTab = "locations";
  String? hoveredNodeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation Panel
                  SizedBox(
                    width: 600,
                    child: NavigationPanel(
                      searchTerm: searchTerm,
                      onSearchChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                      activeTab: activeTab,
                      onTabChanged: (value) {
                        setState(() {
                          activeTab = value;
                        });
                      },
                      locations: locations,
                      equipment: equipment,
                      brands: brands,
                      locationTypes: locationTypes,
                      expandedNodes: expandedNodes,
                      selectedItem: selectedItem,
                      selectedType: selectedType,
                      hoveredNodeId: hoveredNodeId,
                      getFullPath:
                          (code) =>
                              TemplateProcessor.getFullPath(code, locations),
                      onToggleExpanded:
                          (code) => () {
                            setState(() {
                              if (expandedNodes.contains(code)) {
                                expandedNodes.remove(code);
                              } else {
                                expandedNodes.add(code);
                              }
                            });
                          },
                      onSelectItem: (code, type) {
                        setState(() {
                          selectedItem = code;
                          selectedType = type;
                        });
                      },
                      onMouseEnter:
                          (code) => () {
                            setState(() {
                              hoveredNodeId = code;
                            });
                          },
                      onMouseLeave: () {
                        setState(() {
                          hoveredNodeId = null;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Details Panel
                  Expanded(
                    child: SizedBox(
                      width: 600, // Increased width for details panel
                      child: SingleChildScrollView(child: _buildDetailsPanel()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    if (activeTab == "types") {
      return LocationTypesPage(
        onClose: () {
          setState(() {
            activeTab = "locations";
          });
        },
      );
    }
    if (selectedItem == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Selecciona una ubicación o equipo',
                style: AppTextStyles.subtitle(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'para ver sus detalles y opciones de gestión',
                style: AppTextStyles.bodySmall(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedType == "location") {
      final location = locations[selectedItem!];
      if (location == null) return const SizedBox.shrink();

      return LocationDetails(
        location: location,
        locations: locations,
        equipment: equipment,
        locationTypes: locationTypes,
        brands: brands,
        operationalLocations: operationalLocations,
        getFullPath: (code) => TemplateProcessor.getFullPath(code, locations),
      );
    } else {
      final eq = equipment[selectedItem!];
      if (eq == null) return const SizedBox.shrink();

      return EquipmentDetails(
        equipment: eq,
        locations: locations,
        brands: brands,
        operationalLocations: operationalLocations,
        getFullPath: (code) => TemplateProcessor.getFullPath(code, locations),
      );
    }
  }
}
