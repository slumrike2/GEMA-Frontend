import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/constants/app_constnats.dart';

class AssignLocationModal extends StatefulWidget {
  final Equipment equipment;
  final Map<String, TechnicalLocation> locations;
  final List<EquipmentOperationalLocation> operationalLocations;
  final void Function(
    String? technicalLocationId,
    List<String> operationalLocationIds,
  )
  onSave;

  const AssignLocationModal({
    super.key,
    required this.equipment,
    required this.locations,
    required this.operationalLocations,
    required this.onSave,
  });

  @override
  State<AssignLocationModal> createState() => _AssignLocationModalState();
}

class _AssignLocationModalState extends State<AssignLocationModal> {
  String? selectedTechnicalLocation;
  List<String> selectedOperationalLocations = [];
  String searchTechnicalLocation = '';
  String searchOperationalLocation = '';

  @override
  void initState() {
    super.initState();
    selectedTechnicalLocation = widget.equipment.technicalLocation;
    selectedOperationalLocations =
        widget.operationalLocations
            .where((op) => op.equipmentId == widget.equipment.uuid)
            .map((op) => op.locationId)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTechnicalLocations =
        widget.locations.values
            .where(
              (loc) =>
                  loc.name.toLowerCase().contains(
                    searchTechnicalLocation.toLowerCase(),
                  ) ||
                  loc.technicalCode.toLowerCase().contains(
                    searchTechnicalLocation.toLowerCase(),
                  ),
            )
            .toList();
    final filteredOperationalLocations =
        widget.locations.values
            .where(
              (loc) =>
                  loc.name.toLowerCase().contains(
                    searchOperationalLocation.toLowerCase(),
                  ) ||
                  loc.technicalCode.toLowerCase().contains(
                    searchOperationalLocation.toLowerCase(),
                  ),
            )
            .toList();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asignar Ubicaciones - ${widget.equipment.name}',
                style: AppTextStyles.title(),
              ),
              const SizedBox(height: 24),
              // Technical Location Combobox
              Text('📍 Ubicación Física', style: AppTextStyles.subtitle()),
              if (selectedTechnicalLocation != null &&
                  widget.locations[selectedTechnicalLocation] != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    'Actualmente asignada: ${widget.locations[selectedTechnicalLocation]!.name} (${widget.locations[selectedTechnicalLocation]!.technicalCode})',
                    style: AppTextStyles.body(color: Colors.green),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    'Actualmente sin asignar (en inventario)',
                    style: AppTextStyles.body(color: Colors.orange),
                  ),
                ),
              ],
              Builder(
                builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar ubicación física...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged:
                            (value) =>
                                setState(() => searchTechnicalLocation = value),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: Text(
                                'Sin asignar (en inventario)',
                                style: AppTextStyles.body(),
                              ),
                              selected: selectedTechnicalLocation == null,
                              tileColor:
                                  selectedTechnicalLocation == null
                                      ? Colors.green.shade50
                                      : null,
                              textColor:
                                  selectedTechnicalLocation == null
                                      ? Colors.green
                                      : null,
                              onTap: () {
                                setState(
                                  () => selectedTechnicalLocation = null,
                                );
                              },
                            ),
                            ...filteredTechnicalLocations.map((loc) {
                              final isSelected =
                                  selectedTechnicalLocation ==
                                  loc.technicalCode;
                              return ListTile(
                                title: Text(
                                  '${loc.name} (${loc.technicalCode})',
                                  style: AppTextStyles.body(),
                                ),
                                selected: isSelected,
                                tileColor:
                                    isSelected ? Colors.green.shade50 : null,
                                textColor: isSelected ? Colors.green : null,
                                onTap: () {
                                  setState(
                                    () =>
                                        selectedTechnicalLocation =
                                            loc.technicalCode,
                                  );
                                },
                              );
                            }),
                            // If selectedTechnicalLocation is not in filtered list, show it highlighted
                            if (selectedTechnicalLocation != null &&
                                !filteredTechnicalLocations.any(
                                  (loc) =>
                                      loc.technicalCode ==
                                      selectedTechnicalLocation,
                                ) &&
                                widget.locations[selectedTechnicalLocation] !=
                                    null)
                              ListTile(
                                title: Text(
                                  '${widget.locations[selectedTechnicalLocation]!.name} (${widget.locations[selectedTechnicalLocation]!.technicalCode})',
                                  style: AppTextStyles.body(),
                                ),
                                selected: true,
                                tileColor: Colors.green.shade50,
                                textColor: Colors.green,
                                onTap: () {
                                  setState(
                                    () =>
                                        selectedTechnicalLocation =
                                            selectedTechnicalLocation,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                'La ubicación física es donde el equipo está instalado actualmente. Si no está asignada, el equipo se considera en inventario.',
                style: AppTextStyles.body(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Operational Locations Multi Combobox
              Text(
                '⚙️ Ubicaciones Operativas (Donde funciona/opera)',
                style: AppTextStyles.subtitle(),
              ),
              const SizedBox(height: 8),
              // Selected tags
              if (selectedOperationalLocations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children:
                        selectedOperationalLocations.map((code) {
                          final loc = widget.locations[code];
                          return loc == null
                              ? const SizedBox.shrink()
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(
                                  right: 2,
                                  bottom: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${loc.name}',
                                      style: AppTextStyles.caption(
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () {
                                        setState(
                                          () => selectedOperationalLocations
                                              .remove(code),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                        }).toList(),
                  ),
                ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar ubicaciones operativas...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    (value) =>
                        setState(() => searchOperationalLocation = value),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children:
                      filteredOperationalLocations.map((loc) {
                        final checked = selectedOperationalLocations.contains(
                          loc.technicalCode,
                        );
                        return Container(
                          color: checked ? Colors.green.shade50 : null,
                          child: CheckboxListTile(
                            value: checked,
                            title: Text(
                              '${loc.name} (${loc.technicalCode})',
                              style:
                                  checked
                                      ? AppTextStyles.body(color: Colors.green)
                                      : AppTextStyles.body(),
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedOperationalLocations.add(
                                    loc.technicalCode,
                                  );
                                } else {
                                  selectedOperationalLocations.remove(
                                    loc.technicalCode,
                                  );
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona todas las ubicaciones donde este equipo opera o funciona',
                style: AppTextStyles.body(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.button(color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        selectedTechnicalLocation,
                        selectedOperationalLocations,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.botonGreen,
                    ),
                    child: Text(
                      'Guardar Asignaciones',
                      style: AppTextStyles.button(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
