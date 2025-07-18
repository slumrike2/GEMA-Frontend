import 'package:flutter/material.dart';
import 'package:frontend/Components/custom_card.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:frontend/utils/template_processor.dart';

class TreeNode extends StatelessWidget {
  final String technicalCode;
  final int level;
  final Map<String, TechnicalLocation> filteredData;
  final Map<String, TechnicalLocation> allLocations;
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
  final void Function(String parentTechnicalCode)? onQuickCreate;

  const TreeNode({
    super.key,
    required this.technicalCode,
    required this.level,
    required this.filteredData,
    required this.allLocations,
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
    this.onQuickCreate,
  });

  @override
  Widget build(BuildContext context) {
    final location = filteredData[technicalCode];
    if (location == null) return const SizedBox.shrink();

    final typeName = TemplateProcessor.getLocationTypeName(
      location.type,
      locationTypes,
    );
    final icon =
        AppConstants.locationTypeIcons[typeName] ??
        AppConstants.locationTypeIcons["default"]!;

    final childCodes = TemplateProcessor.getChildLocations(
      technicalCode,
      allLocations,
    );
    final hasChildren = childCodes.isNotEmpty;
    final isExpanded = expandedNodes.contains(technicalCode);
    final isSelected =
        selectedItem == technicalCode && selectedType == "location";
    final isHovered = hoveredNodeId == technicalCode;

    return Column(
      children: [
        GestureDetector(
          onTap: () => onSelectItem(technicalCode, "location"),
          child: MouseRegion(
            onEnter: (_) => onMouseEnter(technicalCode)(),
            onExit: (_) => onMouseLeave(),
            child: Container(
              margin: EdgeInsets.only(left: level * 24.0),
              child: CustomCard(
                isSelected: isSelected,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (hasChildren)
                      IconButton(
                        onPressed: onToggleExpanded(technicalCode),
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: AppColors.primary,
                        ),
                        iconSize: 20,
                      )
                    else
                      const SizedBox(width: 48),

                    Icon(icon, color: AppColors.primary, size: 20),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  location.name,
                                  style: AppTextStyles.subtitle(
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
                                  location.technicalCode,
                                  style: AppTextStyles.caption(
                                    color: AppColors.primary,
                                  ).copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  typeName,
                                  style: AppTextStyles.caption(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getFullPath(technicalCode),
                            style: AppTextStyles.bodySmall(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isHovered)
                      IconButton(
                        onPressed:
                            onQuickCreate != null
                                ? () => onQuickCreate!(technicalCode)
                                : null,
                        icon: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          minimumSize: const Size(24, 24),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (hasChildren && isExpanded)
          ...childCodes.map(
            (childCode) => TreeNode(
              technicalCode: childCode,
              level: level + 1,
              filteredData: filteredData,
              allLocations: allLocations,
              locationTypes: locationTypes,
              expandedNodes: expandedNodes,
              selectedItem: selectedItem,
              selectedType: selectedType,
              hoveredNodeId: hoveredNodeId,
              getFullPath: getFullPath,
              onToggleExpanded: onToggleExpanded,
              onSelectItem: onSelectItem,
              onMouseEnter: onMouseEnter,
              onMouseLeave: onMouseLeave,
              onQuickCreate: onQuickCreate,
            ),
          ),
      ],
    );
  }
}
