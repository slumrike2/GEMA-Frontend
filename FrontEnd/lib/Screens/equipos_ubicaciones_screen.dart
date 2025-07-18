import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Services/equipment_operational_location_service.dart';
import 'package:frontend/Services/technical_location_service.dart';
import 'package:frontend/Services/technical_location_type_service.dart';
import 'package:frontend/Services/equipment_service.dart';
import 'package:frontend/Services/brand_service.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/equipment_details.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/location_details.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/tipo_details.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/marca_details.dart';
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
  Map<String, TechnicalLocation> locations = {};
  Map<String, Equipment> equipment = {};
  Map<int, Brand> brands = {};
  Map<String, LocationType> locationTypes = {};
  List<EquipmentOperationalLocation> operationalLocations = [];

  // UI State
  String searchTerm = "";
  Set<String> expandedNodes = {};
  String? selectedItem;
  String selectedType = "location";
  String activeTab = "locations";
  String? hoveredNodeId;

  @override
  void initState() {
    super.initState();
    _fetchLocationsAndTypes();
  }

  Future<void> _fetchLocationsAndTypes() async {
    try {
      final locs = await TechnicalLocationService.getAll();
      final types = await TechnicalLocationTypeService.getAll();
      final equipments = await EquipmentService.getAll();
      final brandsList = await BrandService.getAll();
      final opsLocations = await EquipmentOperationalLocationService.getAll();

      setState(() {
        locations = {for (var l in locs) l.technicalCode: l};
        locationTypes = {for (var t in types) t.name: t};
        equipment = {for (var e in equipments) e.technicalCode: e};
        operationalLocations = opsLocations;
        brands = {
          for (var b in brandsList)
            if (b.id != null) b.id!: b,
        };
        // Expand root nodes by default
        expandedNodes =
            locs
                .where((l) => l.parentTechnicalCode == null)
                .map((l) => l.technicalCode)
                .toSet();
      });
    } catch (e) {
      // Puedes mostrar un error aquí si lo deseas
    }
  }

  _refetchOperationalLocations() async {
    try {
      final ops = await EquipmentOperationalLocationService.getAll();
      setState(() {
        operationalLocations = ops;
      });
    } catch (e) {
      print('Error fetching operational locations: $e');
    }
  }

  _refetchEquipment() async {
    try {
      final equipments = await EquipmentService.getAll();
      setState(() {
        equipment = {for (var e in equipments) e.technicalCode: e};
      });
    } catch (e) {
      print('Error fetching equipment: $e');
    }
  }

  _refetchLocations() async {
    try {
      final locs = await TechnicalLocationService.getAll();
      setState(() {
        locations = {for (var l in locs) l.technicalCode: l};
        // Re-expand root nodes
        expandedNodes =
            locs
                .where((l) => l.parentTechnicalCode == null)
                .map((l) => l.technicalCode)
                .toSet();
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  _refetchLocationTypes() async {
    try {
      final types = await TechnicalLocationTypeService.getAll();
      setState(() {
        locationTypes = {for (var t in types) t.name: t};
      });
    } catch (e) {
      print('Error fetching location types: $e');
    }
  }

  _refetchBrands() async {
    try {
      final brandsList = await BrandService.getAll();
      setState(() {
        brands = {
          for (var b in brandsList)
            if (b.id != null) b.id!: b,
        };
      });
    } catch (e) {
      print('Error fetching brands: $e');
    }
  }

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
                      refetchEquipment: _refetchEquipment,
                      refetchLocations: _refetchLocations,
                      refetchLocationTypes: _refetchLocationTypes,
                      refetchBrands: _refetchBrands,
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
        types: locationTypes.values.toList(),
        refetchLocationTypes: () => _refetchLocationTypes(),
        onClose: () {
          setState(() {
            activeTab = "locations";
          });
        },
      );
    }
    if (activeTab == "brands") {
      // Compute equipment count by brandId
      final Map<int, int> equipmentCountByBrand = {};
      for (final eq in equipment.values) {
        if (brands.containsKey(eq.brandId)) {
          equipmentCountByBrand[eq.brandId] =
              (equipmentCountByBrand[eq.brandId] ?? 0) + 1;
        }
      }
      return MarcaDetailsPage(
        brands: brands.values.toList(),
        equipmentCountByBrand: equipmentCountByBrand,
        refetchBrands: _refetchBrands,
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Selecciona una ubicación o equipo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'para ver sus detalles y opciones de gestión',
                style: TextStyle(
                  fontSize: 14,
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
        refetchOperationalLocations: _refetchOperationalLocations,
        brands: brands,
        onRefetch: () => {_refetchEquipment(), _refetchLocations()},
        operationalLocations: operationalLocations,
        getFullPath: (code) => TemplateProcessor.getFullPath(code, locations),
      );
    }
  }
}
