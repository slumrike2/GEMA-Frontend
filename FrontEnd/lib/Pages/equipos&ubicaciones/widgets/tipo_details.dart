import 'package:flutter/material.dart';
import 'package:frontend/Modals/crear_tipo_ubicacion_modal.dart';
import 'package:frontend/Modals/delete_type_dialog.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Pages/equipos&ubicaciones/widgets/location_type_card.dart';
import 'package:frontend/Services/technical_location_type_service.dart';

class LocationTypesPage extends StatefulWidget {
  final VoidCallback? onClose;
  const LocationTypesPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<LocationTypesPage> createState() => _LocationTypesPageState();
}

class _LocationTypesPageState extends State<LocationTypesPage> {
  List<LocationType> types = [];

  @override
  void initState() {
    super.initState();
    _fetchLocationTypes();
  }

  void _fetchLocationTypes() async {
    try {
      final fetchedTypes = await TechnicalLocationTypeService.getAll();
      setState(() {
        types = fetchedTypes;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar or log the error)
      print('Error fetching location types: $e');
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CrearTipoUbicacionModal(
            onCreate: (locationType) {
              setState(() {
                // Assign a mock ID if needed
                final typeWithId =
                    locationType.id == null
                        ? LocationType(
                          id: types.length + 1,
                          name: locationType.name,
                          icon: locationType.icon,
                          description: locationType.description,
                          nameTemplate: locationType.nameTemplate,
                          codeTemplate: locationType.codeTemplate,
                          fields: locationType.fields,
                        )
                        : locationType;
                types.add(typeWithId);
              });
            },
          ),
    );
  }

  void _showDeleteTypeDialog(LocationType type) async {
    // Mock: Find locations associated with this type (replace with real data in production)
    final locationsToDelete = List<String>.generate(
      7,
      (i) => '${type.name} ${i + 1}',
    );
    final otherTypes = types.where((t) => t.id != type.id).toList();
    final locationCount = locationsToDelete.length;
    showDialog(
      context: context,
      builder:
          (context) => DeleteTypeDialog(
            type: type,
            locationCount: locationCount,
            otherTypes: otherTypes,
            locationsToDelete: locationsToDelete,
            onDelete: (action, selectedType) {
              setState(() {
                types.removeWhere((t) => t.id == type.id);
                // TODO: Handle cascade, move, or keep logic as needed
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Para cerrar y volver a los detalles, necesitamos acceder a la pantalla padre y cambiar el tab
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 3;
        double horizontalPadding = 32.0;
        double cardPadding = 20.0;
        if (width < 600) {
          crossAxisCount = 1;
          horizontalPadding = 8.0;
          cardPadding = 10.0;
        } else if (width < 900) {
          crossAxisCount = 2;
          horizontalPadding = 16.0;
          cardPadding = 14.0;
        }
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 900),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and close button
                      HeaderSection(onClose: widget.onClose),
                      const SizedBox(height: 4),
                      // Description and add button
                      DescriptionSection(onCreate: _showCreateDialog),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child:
                              types.isEmpty
                                  ? const EmptyState()
                                  : LocationTypesGrid(
                                    types: types,
                                    crossAxisCount: crossAxisCount,
                                    cardPadding: cardPadding,
                                    crossAxisSpacing: width < 600 ? 8 : 24,
                                    mainAxisSpacing: width < 600 ? 8 : 24,
                                    childAspectRatio: width < 600 ? 0.85 : 0.95,
                                    onDelete:
                                        (type) => _showDeleteTypeDialog(type),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ); // end LayoutBuilder
  }
}

class HeaderSection extends StatelessWidget {
  final VoidCallback? onClose;

  const HeaderSection({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Tipos de Ubicación',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 28),
          tooltip: 'Cerrar',
          onPressed: onClose,
        ),
      ],
    );
  }
}

class DescriptionSection extends StatelessWidget {
  final VoidCallback onCreate;

  const DescriptionSection({Key? key, required this.onCreate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Gestiona las plantillas para crear ubicaciones técnicas',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Crear Tipo'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: const TextStyle(fontSize: 15),
          ),
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay tipos de ubicación',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea el primer tipo para comenzar a usar plantillas',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class LocationTypesGrid extends StatelessWidget {
  final List<LocationType> types;
  final int crossAxisCount;
  final double cardPadding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final void Function(LocationType) onDelete;

  const LocationTypesGrid({
    Key? key,
    required this.types,
    required this.crossAxisCount,
    required this.cardPadding,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.childAspectRatio,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: types.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final type = types[index];
        return LocationTypeCard(
          type: type,
          cardPadding: cardPadding,
          onDelete: () => onDelete(type),
        );
      },
    );
  }
}
