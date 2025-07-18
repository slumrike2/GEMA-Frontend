import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Services/technical_location_service.dart';

class CrearUbicacionModal extends StatefulWidget {
  final List<TechnicalLocation> locations;
  final List<LocationType> locationTypes;
  final void Function({
    required String name,
    required String technicalCode,
    required int type,
    required String? parentTechnicalCode,
  })
  onCreate;
  final VoidCallback onRefetchLocations;
  final String? preselectedParentCode;

  const CrearUbicacionModal({
    Key? key,
    required this.locations,
    required this.locationTypes,
    required this.onCreate,
    this.preselectedParentCode,
    required this.onRefetchLocations,
  }) : super(key: key);

  @override
  State<CrearUbicacionModal> createState() => _CrearUbicacionModalState();
}

class _CrearUbicacionModalState extends State<CrearUbicacionModal> {
  final _formKey = GlobalKey<FormState>();
  String? _parentCode;
  String? _abbreviatedCode;
  LocationType? _selectedType;
  Map<String, String> _variables = {};
  String _previewCode = '';
  String _previewName = '';

  @override
  void initState() {
    super.initState();
    _parentCode = widget.preselectedParentCode;
  }

  void _updatePreview() {
    if (_selectedType == null) return;
    String code = _selectedType!.codeTemplate;
    String name = _selectedType!.nameTemplate;
    _variables.forEach((k, v) {
      code = code.replaceAll('{$k}', v);
      name = name.replaceAll('{$k}', v);
    });
    final parent = widget.locations.firstWhere(
      (l) => l.technicalCode == _parentCode,
      orElse:
          () => TechnicalLocation(
            technicalCode: '',
            abbreviatedTechnicalCode: '',
            name: '',
            type: 0,
            parentTechnicalCode: null,
          ),
    );
    _previewCode =
        parent.technicalCode.isNotEmpty
            ? parent.technicalCode + '-' + code
            : code;
    _previewName = name;
    _abbreviatedCode = code;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Crear Nueva Ubicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _parentCode,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación Padre',
                    ),
                    items:
                        widget.locations
                            .map(
                              (loc) => DropdownMenuItem(
                                value: loc.technicalCode,
                                child: Text(
                                  '${loc.technicalCode} - ${loc.name}',
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      setState(() {
                        _parentCode = v;
                        _updatePreview();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LocationType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Ubicación',
                    ),
                    items:
                        widget.locationTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedType = v;
                        _variables = {};
                        if (v != null) {
                          final reg = RegExp(r'\{(\w+)\}');
                          for (final match in reg.allMatches(
                            v.codeTemplate + v.nameTemplate,
                          )) {
                            _variables[match.group(1)!] = '';
                          }
                        }
                        _updatePreview();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_selectedType != null)
                    ..._variables.keys.map(
                      (key) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: key),
                          onChanged: (v) {
                            _variables[key] = v;
                            _updatePreview();
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_previewCode.isNotEmpty || _previewName.isNotEmpty)
                    Card(
                      color: Colors.blueGrey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_previewCode.isNotEmpty)
                              Text(
                                'Código Técnico: $_previewCode',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            if (_previewName.isNotEmpty)
                              Text('Nombre: $_previewName'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() != true ||
                              _selectedType == null)
                            return;
                          // Construir el objeto para el backend
                          final technicalLocation = {
                            'name': _previewName,
                            'technicalCode': _previewCode,
                            'type':
                                _selectedType!.id ??
                                widget.locationTypes.indexOf(_selectedType!),
                            'parentTechnicalCode': _parentCode,
                            'abbreviatedTechnicalCode': _abbreviatedCode,
                          };
                          try {
                            await TechnicalLocationService.create(
                              technicalLocation,
                            );
                            widget.onCreate(
                              name: _previewName,
                              technicalCode: _previewCode,
                              type:
                                  _selectedType!.id ??
                                  widget.locationTypes.indexOf(_selectedType!),
                              parentTechnicalCode: _parentCode,
                            );
                            if (widget.onRefetchLocations != null) {
                              widget.onRefetchLocations!();
                            }
                            Navigator.of(context).pop();
                          } catch (e) {
                            // Puedes mostrar un error aquí si lo deseas
                          }
                        },
                        child: const Text('Crear Ubicación'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
