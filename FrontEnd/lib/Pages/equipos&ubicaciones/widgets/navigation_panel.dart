import 'package:flutter/material.dart';
import 'package:frontend/Components/custom_card.dart';
import 'package:frontend/Modals/crear_equipo_modal.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/equipment_item.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/tree_node.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:frontend/utils/search_utils.dart';

class NavigationPanel extends StatefulWidget {
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final String activeTab;
  final ValueChanged<String> onTabChanged;
  final Map<String, TechnicalLocation> locations;
  final Map<String, Equipment> equipment;
  final Map<int, Brand> brands;
  final Map<String, LocationType> locationTypes;
  final Set<String> expandedNodes;
  final String? selectedItem;
  final String selectedType;
  final String? hoveredNodeId;
  final String Function(String) getFullPath;
  final VoidCallback Function(String) onToggleExpanded;
  final void Function(String, String) onSelectItem;
  final VoidCallback Function(String) onMouseEnter;
  final VoidCallback onMouseLeave;

  const NavigationPanel({
    super.key,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.activeTab,
    required this.onTabChanged,
    required this.locations,
    required this.equipment,
    required this.brands,
    required this.locationTypes,
    required this.expandedNodes,
    this.selectedItem,
    required this.selectedType,
    this.hoveredNodeId,
    required this.getFullPath,
    required this.onToggleExpanded,
    required this.onSelectItem,
    required this.onMouseEnter,
    required this.onMouseLeave,
  });

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  // Expanded state for each button
  bool _expandedUbicacion = false;
  bool _expandedEquipo = false;
  bool _expandedMarca = false;
  bool _expandedTipos = false;
  @override
  Widget build(BuildContext context) {
    final filteredLocations = SearchUtils.filterLocations(
      widget.searchTerm,
      widget.locations,
      widget.locationTypes,
    );

    final filteredEquipment = SearchUtils.filterEquipment(
      widget.searchTerm,
      widget.equipment,
      widget.brands,
    );

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Navegación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              _buildActionButtons(),
            ],
          ),

          const SizedBox(height: 16),

          // Search
          TextField(
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar ubicaciones o equipos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('locations', 'Ubicaciones')),
                Expanded(child: _buildTabButton('equipment', 'Equipos')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child:
                widget.activeTab == 'locations'
                    ? _buildLocationsTab(filteredLocations)
                    : _buildEquipmentTab(filteredEquipment),
          ),
        ],
      ),
    );
  }

  // Hover state for each action button
  bool _hoverUbicacion = false;
  bool _hoverEquipo = false;
  bool _hoverMarca = false;
  bool _hoverTipos = false;

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crear Ubicación
        MouseRegion(
          onEnter: (_) => setState(() => _hoverUbicacion = true),
          onExit:
              (_) => setState(() {
                _hoverUbicacion = false;
                _expandedUbicacion = false;
              }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            onEnd: () => setState(() => _expandedUbicacion = _hoverUbicacion),
            width: _hoverUbicacion ? 100 : 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.primary),
                  if (_expandedUbicacion) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Ubicación',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Crear Equipo
        MouseRegion(
          onEnter: (_) => setState(() => _hoverEquipo = true),
          onExit:
              (_) => setState(() {
                _hoverEquipo = false;
                _expandedEquipo = false;
              }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            onEnd: () => setState(() => _expandedEquipo = _hoverEquipo),
            width: _hoverEquipo ? 80 : 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => CrearEquipoModal(
                        brands: widget.brands.values.toList(),
                        locations: widget.locations.values.toList(),
                        onCreate: (data) {
                          // TODO: handle equipo creation logic here
                        },
                      ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build, size: 16, color: AppColors.primary),
                  if (_expandedEquipo) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Equipo',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Crear Marca
        MouseRegion(
          onEnter: (_) => setState(() => _hoverMarca = true),
          onExit:
              (_) => setState(() {
                _hoverMarca = false;
                _expandedMarca = false;
              }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            onEnd: () => setState(() => _expandedMarca = _hoverMarca),
            width: _hoverMarca ? 80 : 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 16, color: AppColors.primary),
                  if (_expandedMarca) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Marca',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Crear Tipos
        MouseRegion(
          onEnter: (_) => setState(() => _hoverTipos = true),
          onExit:
              (_) => setState(() {
                _hoverTipos = false;
                _expandedTipos = false;
              }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            onEnd: () => setState(() => _expandedTipos = _hoverTipos),
            width: _hoverTipos ? 80 : 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 16, color: AppColors.primary),
                  if (_expandedTipos) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Tipos',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          foregroundColor: AppColors.primary,
          minimumSize: const Size(32, 32),
        ),
      ),
    );
  }

  Widget _buildTabButton(String value, String label) {
    final isActive = widget.activeTab == value;

    return GestureDetector(
      onTap: () => widget.onTabChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsTab(Map<String, TechnicalLocation> filteredLocations) {
    final rootItems =
        filteredLocations.values
            .where((location) => location.parentTechnicalCode == null)
            .toList();

    return ListView.builder(
      itemCount: rootItems.length,
      itemBuilder: (context, index) {
        final location = rootItems[index];
        return TreeNode(
          technicalCode: location.technicalCode,
          level: 0,
          filteredData: filteredLocations,
          allLocations: widget.locations,
          locationTypes: widget.locationTypes,
          expandedNodes: widget.expandedNodes,
          selectedItem: widget.selectedItem,
          selectedType: widget.selectedType,
          hoveredNodeId: widget.hoveredNodeId,
          getFullPath: widget.getFullPath,
          onToggleExpanded: widget.onToggleExpanded,
          onSelectItem: widget.onSelectItem,
          onMouseEnter: widget.onMouseEnter,
          onMouseLeave: widget.onMouseLeave,
        );
      },
    );
  }

  Widget _buildEquipmentTab(Map<String, Equipment> filteredEquipment) {
    return ListView.builder(
      itemCount: filteredEquipment.length,
      itemBuilder: (context, index) {
        final equipment = filteredEquipment.values.elementAt(index);
        return EquipmentItem(
          equipment: equipment,
          brands: widget.brands,
          locations: widget.locations,
          isSelected:
              widget.selectedItem == equipment.technicalCode &&
              widget.selectedType == "equipment",
          onSelect:
              () => widget.onSelectItem(equipment.technicalCode, "equipment"),
        );
      },
    );
  }
}
