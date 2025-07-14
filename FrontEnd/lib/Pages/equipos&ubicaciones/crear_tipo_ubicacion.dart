import 'package:flutter/material.dart';
import '../../Services/technical_location_type_service.dart';
import '../../Models/backend_types.dart';

class CrearTipoUbicacion extends StatefulWidget {
  const CrearTipoUbicacion({super.key});

  @override
  State<CrearTipoUbicacion> createState() => _CrearTipoUbicacionState();
}

class _CrearTipoUbicacionState extends State<CrearTipoUbicacion> {
  List<LocationType> locationTypes = [];
  bool isLoading = false;
  final List<bool> _expanded = [];

  // Controllers para el formulario de creación/edición
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameTemplateController = TextEditingController();
  final _codeTemplateController = TextEditingController();

  // Estado para edición
  LocationType? editingType;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchLocationTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameTemplateController.dispose();
    _codeTemplateController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationTypes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final types = await TechnicalLocationTypeService.getAll();
      setState(() {
        locationTypes = types;
        _expanded.clear();
        _expanded.addAll(List.generate(types.length, (_) => false));
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching location types: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error al cargar los tipos de ubicación');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _nameTemplateController.clear();
    _codeTemplateController.clear();
    editingType = null;
    isEditing = false;
  }

  void _editLocationType(LocationType type) {
    setState(() {
      editingType = type;
      isEditing = true;
      _nameController.text = type.name;
      _descriptionController.text = type.description ?? '';
      _nameTemplateController.text = type.nameTemplate;
      _codeTemplateController.text = type.codeTemplate;
    });
  }

  Future<void> _deleteLocationType(LocationType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el tipo "${type.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TechnicalLocationTypeService.delete(type.name);
        await _fetchLocationTypes();
        _showSuccessSnackBar('Tipo de ubicación eliminado correctamente');
      } catch (e) {
        print('Error deleting location type: $e');
        _showErrorSnackBar('Error al eliminar el tipo de ubicación');
      }
    }
  }

  Future<void> _saveLocationType() async {
    if (_nameController.text.trim().isEmpty ||
        _nameTemplateController.text.trim().isEmpty ||
        _codeTemplateController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor completa todos los campos obligatorios');
      return;
    }

    try {
      if (isEditing) {
        await TechnicalLocationTypeService.update(editingType!.name, {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'nameTemplate': _nameTemplateController.text.trim(),
          'codeTemplate': _codeTemplateController.text.trim(),
        });
        _showSuccessSnackBar('Tipo de ubicación actualizado correctamente');
      } else {
        await TechnicalLocationTypeService.createWithTemplates(
          _nameController.text.trim(),
          _nameTemplateController.text.trim(),
          _codeTemplateController.text.trim(),
        );
        _showSuccessSnackBar('Tipo de ubicación creado correctamente');
      }
      await _fetchLocationTypes();
      _clearForm();
    } catch (e) {
      print('Error saving location type: $e');
      _showErrorSnackBar('Error al guardar el tipo de ubicación');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: [
                const Text(
                  'Gestión de Tipos de Ubicación Técnica',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _clearForm();
                    _showLocationTypeDialog();
                  },
                  child: const Text('Nuevo Tipo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : locationTypes.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay tipos de ubicación disponibles',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : Card(
                        color: const Color(0xFFD6ECE0),
                        child: ExpansionPanelList.radio(
                          elevation: 0,
                          expandedHeaderPadding: EdgeInsets.zero,
                          children: [
                            for (int i = 0; i < locationTypes.length; i++)
                              ExpansionPanelRadio(
                                value: locationTypes[i].name,
                                canTapOnHeader: true,
                                headerBuilder: (context, isExpanded) {
                                  final type = locationTypes[i];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Row(
                                      children: [
                                        Text(
                                          type.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        if ((type.description ?? '').isEmpty)
                                          Chip(
                                            label: const Text('Sin descripción'),
                                            backgroundColor: Colors.red[300],
                                            labelStyle: const TextStyle(color: Colors.white),
                                          ),
                                        if ((type.description ?? '').isNotEmpty)
                                          Chip(
                                            label: Text(type.description!),
                                            backgroundColor: Colors.blue[100],
                                          ),
                                      ],
                                    ),
                                  );
                                },
                                body: Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Nombre: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: locationTypes[i].name,
                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Descripción: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: locationTypes[i].description?.isNotEmpty == true ? locationTypes[i].description! : '-',
                                                style: const TextStyle(fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Plantilla de Nombre: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: locationTypes[i].nameTemplate,
                                                style: const TextStyle(fontWeight: FontWeight.normal, fontFamily: 'monospace'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Plantilla de Código: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: locationTypes[i].codeTemplate,
                                                style: const TextStyle(fontWeight: FontWeight.normal, fontFamily: 'monospace'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _editLocationType(locationTypes[i]);
                                              _showLocationTypeDialog();
                                            },
                                            icon: const Icon(Icons.edit, color: Colors.white),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                            ),
                                            label: const Text('Editar'),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            onPressed: () => _deleteLocationType(locationTypes[i]),
                                            icon: const Icon(Icons.delete, color: Colors.white),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                            ),
                                            label: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

  void _showLocationTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Tipo de Ubicación' : 'Nuevo Tipo de Ubicación'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Edificio, Piso, Sala',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción opcional del tipo',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameTemplateController,
                decoration: const InputDecoration(
                  labelText: 'Plantilla de Nombre *',
                  hintText: 'Ej: {nombre} - {descripción}',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeTemplateController,
                decoration: const InputDecoration(
                  labelText: 'Plantilla de Código *',
                  hintText: 'Ej: {tipo}_{numero}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveLocationType();
              Navigator.of(context).pop();
            },
            child: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }
}
