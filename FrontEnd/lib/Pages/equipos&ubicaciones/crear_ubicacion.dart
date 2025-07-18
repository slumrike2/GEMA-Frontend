import 'package:flutter/material.dart';
import 'package:frontend/constants/app_constnats.dart';
import '../../Services/technical_location_service.dart';
import '../../Models/backend_types.dart';
import '../../Services/technical_location_type_service.dart';

class CrearUbicacionForm extends StatefulWidget {
  final void Function()? onSuccess;
  final void Function()? onBack;
  final TechnicalLocation? initialLocation;
  final List<LocationType> locationTypes;
  final String? parentTechnicalCode;
  const CrearUbicacionForm({
    Key? key,
    this.onSuccess,
    this.onBack,
    this.initialLocation,
    required this.locationTypes,
    this.parentTechnicalCode,
  }) : super(key: key);

  @override
  State<CrearUbicacionForm> createState() => _CrearUbicacionFormState();
}

class _CrearUbicacionFormState extends State<CrearUbicacionForm> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedLocationTypeName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null && widget.locationTypes.isNotEmpty) {
      _nameController.text = widget.initialLocation!.name;
      _codeController.text = widget.initialLocation!.technicalCode;
      final idx = widget.initialLocation!.type;
      if (idx >= 0 && idx < widget.locationTypes.length) {
        _selectedLocationTypeName = widget.locationTypes[idx].name;
      }
    }
    if (_selectedLocationTypeName == null && widget.locationTypes.isNotEmpty) {
      _selectedLocationTypeName = widget.locationTypes.first.name;
    }
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);
    try {
      final newLocation = TechnicalLocation(
        name: _nameController.text,
        technicalCode: _codeController.text,
        type: widget.locationTypes.indexWhere(
          (t) => t.name == _selectedLocationTypeName,
        ),
        parentTechnicalCode: widget.parentTechnicalCode,
      );
      await TechnicalLocationService.create(newLocation.toJson());
      widget.onSuccess?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 400,
          child: AbsorbPointer(
            absorbing: _isLoading,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Crear Ubicación',
                        style: AppTextStyles.title(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (widget.onBack != null) {
                                  widget.onBack!();
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código Técnico',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLocationTypeName,
                  items:
                      widget.locationTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type.name,
                              child: Text(type.name),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() => _selectedLocationTypeName = val),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Ubicación',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (widget.onBack != null) {
                                  widget.onBack!();
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _onSave,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
