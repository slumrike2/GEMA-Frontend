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
  String _searchParentLocation = '';
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación Padre',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar ubicación padre...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => _searchParentLocation = value);
                        },
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
                              title: const Text('Sin ubicación padre'),
                              selected: _parentCode == null,
                              tileColor:
                                  _parentCode == null
                                      ? Colors.green.shade50
                                      : null,
                              textColor:
                                  _parentCode == null ? Colors.green : null,
                              onTap: () {
                                setState(() {
                                  _parentCode = null;
                                  _updatePreview();
                                });
                              },
                            ),
                            ...(() {
                              final query = _searchParentLocation.toLowerCase();
                              final filtered =
                                  widget.locations.where((loc) {
                                    if (query.isEmpty) return true;
                                    if (loc.name.toLowerCase().contains(query))
                                      return true;
                                    if (loc.abbreviatedTechnicalCode
                                        .toLowerCase()
                                        .contains(query))
                                      return true;
                                    if (loc.technicalCode
                                        .toLowerCase()
                                        .contains(query))
                                      return true;
                                    return false;
                                  }).toList();
                              // Sort: exact abbreviatedTechnicalCode match first
                              filtered.sort((a, b) {
                                final aExact =
                                    a.abbreviatedTechnicalCode.toLowerCase() ==
                                    query;
                                final bExact =
                                    b.abbreviatedTechnicalCode.toLowerCase() ==
                                    query;
                                if (aExact && !bExact) return -1;
                                if (!aExact && bExact) return 1;
                                return 0;
                              });
                              return filtered.map((loc) {
                                final isSelected =
                                    _parentCode == loc.technicalCode;
                                return ListTile(
                                  title: Text(
                                    '${loc.technicalCode} - ${loc.name}',
                                  ),
                                  subtitle: Text(
                                    'Abrev: ${loc.abbreviatedTechnicalCode}',
                                  ),
                                  selected: isSelected,
                                  tileColor:
                                      isSelected ? Colors.green.shade50 : null,
                                  textColor: isSelected ? Colors.green : null,
                                  onTap: () {
                                    setState(() {
                                      _parentCode = loc.technicalCode;
                                      _updatePreview();
                                    });
                                  },
                                );
                              });
                            })(),
                            if (_parentCode != null &&
                                !widget.locations.any(
                                  (loc) => loc.technicalCode == _parentCode,
                                ))
                              ListTile(
                                title: Text('$_parentCode'),
                                selected: true,
                                tileColor: Colors.green.shade50,
                                textColor: Colors.green,
                                onTap: () {
                                  setState(() {
                                    _parentCode = _parentCode;
                                    _updatePreview();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
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
                            widget.onRefetchLocations();
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
