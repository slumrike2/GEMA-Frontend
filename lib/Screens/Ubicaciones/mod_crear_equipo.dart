import 'package:flutter/material.dart';
import 'package:frontend/Components/sidebar.dart';
import 'package:frontend/Components/location_filter.dart';

class ModCrearEquipoScreen extends StatelessWidget {
  const ModCrearEquipoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController technicalCodeController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController serialNumberController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController locationFilterController = TextEditingController();

    int selectedIndex = 1;
    // Simulación de datos para Brand, State y Ubicación Operativa
    final List<String> brands = ['Marca A', 'Marca B', 'Marca C'];
    final List<String> equipmentStates = [
      'installed',
      'in_maintenance',
      'maintenance_pending',
      'in_repair',
      'repair_pending',
      'in_stock',
      'decommissioned',
      'transfer_pending'
    ];
    final List<String> operationalLocations = [
      'Loc-001',
      'Loc-002',
      'Loc-003',
    ];

    String? selectedBrand;
    String? selectedState;
    String? selectedOperationalLocation;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedIndex: selectedIndex),
          Expanded(
            child: Container(
              color: const Color(0xFFD6ECE0),
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        child: const Text(
                          'Modificar o Crear Equipo',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location Filter arriba del input de código técnico
                            const Text(
                              'Ubicación padre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            EquiposUbicacionesPanel(controller: locationFilterController),
                            const SizedBox(height: 24),
                            // Código Técnico con botón Buscar al lado
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: technicalCodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Código Técnico',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    // Acción para buscar por código técnico
                                  },
                                  child: const Text('Buscar'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // ...resto de los campos...
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: serialNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Número de Serie',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            // Campo de Marca con autocompletado y opción de nueva marca
                            Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return brands.where((String option) {
                                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                });
                              },
                              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Marca',
                                    border: OutlineInputBorder(),
                                  ),
                                  onEditingComplete: onEditingComplete,
                                );
                              },
                              onSelected: (String selection) {
                                // Aquí puedes manejar la selección de la marca
                                // Por ejemplo: selectedBrand = selection;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                              items: equipmentStates
                                  .map((state) => DropdownMenuItem(
                                        value: state,
                                        child: Text(state),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                // selectedState = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Ubicación Operativa',
                                border: OutlineInputBorder(),
                              ),
                              items: operationalLocations
                                  .map((loc) => DropdownMenuItem(
                                        value: loc,
                                        child: Text(loc),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                // selectedOperationalLocation = value;
                              },
                            ),
                            const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: () {
                                      // Acción para eliminar equipo
                                    },
                                    child: const Text('Eliminar'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: () {
                                      // Acción para guardar equipo
                                    },
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}