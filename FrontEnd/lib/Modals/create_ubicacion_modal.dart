import 'package:flutter/material.dart';
import '../Models/backend_types.dart';
import '../Components/searchable_combobox.dart';

class CreateUbicacionModal extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onCreate;
  final VoidCallback onCancel;
  final List<LocationType> locationTypes;
  final List<TechnicalLocation> parentLocations;
  final TechnicalLocation? selectedLocation; // NEW

  const CreateUbicacionModal({
    super.key,
    required this.onCreate,
    required this.onCancel,
    required this.locationTypes,
    required this.parentLocations,
    this.selectedLocation, // NEW
  });

  @override
  State<CreateUbicacionModal> createState() => _CreateUbicacionModalState();
}

class _CreateUbicacionModalState extends State<CreateUbicacionModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  int? _typeId;
  String? _parentCode;
  bool _lockToCurrent = true;
  String _parentSearch = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    if (widget.selectedLocation != null) {
      _lockToCurrent = true;
      _parentCode = widget.selectedLocation!.technicalCode;
    } else {
      _lockToCurrent = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _generateNameAndCode() {
    if (_typeId == null) return;
    final typeIndex = _typeId! - 1;
    if (typeIndex < 0 || typeIndex >= widget.locationTypes.length) return;
    final type = widget.locationTypes[typeIndex];
    TechnicalLocation? parent;
    try {
      parent = widget.parentLocations.firstWhere(
        (l) => l.technicalCode == _parentCode,
      );
    } catch (_) {
      parent = null;
    }
    final siblings =
        widget.parentLocations
            .where(
              (l) => l.parentTechnicalCode == _parentCode && l.type == _typeId,
            )
            .toList();
    // Find max serial for this type under the same parent
    int maxSerial = 0;
    final serialReg = RegExp(r'(\d+)$');
    for (var loc in siblings) {
      final match = serialReg.firstMatch(loc.technicalCode);
      if (match != null) {
        int serial = int.tryParse(match.group(1) ?? '') ?? 0;
        if (serial > maxSerial) maxSerial = serial;
      }
    }
    int nextSerial = maxSerial + 1;
    String parentCode = parent != null ? parent.technicalCode : '';
    String parentName = parent != null ? parent.name : '';
    String typeName = type.name;
    String name = type.nameTemplate
        .replaceAll('{parent_code}', parentCode)
        .replaceAll('{parent_name}', parentName)
        .replaceAll('{type}', typeName)
        .replaceAll('{serial}', nextSerial.toString());
    String code = type.codeTemplate
        .replaceAll('{parent_code}', parentCode)
        .replaceAll('{parent_name}', parentName)
        .replaceAll('{type}', typeName)
        .replaceAll('{serial}', nextSerial.toString());
    _nameController.text = name;
    _codeController.text = code;
  }

  List<TechnicalLocation> get _filteredParents {
    if (_parentSearch.isEmpty) return widget.parentLocations;
    final q = _parentSearch.toLowerCase();
    return widget.parentLocations
        .where(
          (l) =>
              l.name.toLowerCase().contains(q) ||
              l.technicalCode.toLowerCase().contains(q) ||
              widget.locationTypes.length > l.type &&
                  widget.locationTypes[l.type].name.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blueGrey.shade100, width: 2),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'Crear Ubicación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.blue[50],
                  ),
                  onChanged: (v) {}, // allow manual edit
                  validator:
                      (v) =>
                          v == null || v.isEmpty ? 'Ingrese un nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código Técnico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.blue[50],
                  ),
                  onChanged: (v) {}, // allow manual edit
                  validator:
                      (v) =>
                          v == null || v.isEmpty ? 'Ingrese un código' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.blue[50],
                  ),
                  value: _typeId,
                  items:
                      widget.locationTypes
                          .map(
                            (t) => DropdownMenuItem(
                              value:
                                  widget.locationTypes.indexOf(t) +
                                  1, // assuming id is index+1
                              child: Text(t.name),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    setState(() {
                      _typeId = v;
                      _generateNameAndCode();
                    });
                  },
                  validator: (v) => v == null ? 'Seleccione un tipo' : null,
                ),
                const SizedBox(height: 16),
                if (widget.selectedLocation != null)
                  Row(
                    children: [
                      Checkbox(
                        value: _lockToCurrent,
                        onChanged: (val) {
                          setState(() {
                            _lockToCurrent = val ?? false;
                            if (_lockToCurrent) {
                              _parentCode =
                                  widget.selectedLocation!.technicalCode;
                            } else {
                              _parentCode = null;
                            }
                            _generateNameAndCode();
                          });
                        },
                      ),
                      Flexible(
                        child: Text(
                          'Crear ubicación dentro de la ubicación actual: '
                          '${widget.selectedLocation!.name} (${widget.selectedLocation!.technicalCode})',
                        ),
                      ),
                    ],
                  ),
                if (_lockToCurrent && widget.selectedLocation != null)
                  TextFormField(
                    enabled: false,
                    initialValue:
                        widget.selectedLocation!.name +
                        ' (' +
                        widget.selectedLocation!.technicalCode +
                        ')',
                    decoration: InputDecoration(
                      labelText: 'Ubicación Padre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubicación Padre'),
                      const SizedBox(height: 6),
                      SearchableComboBox<String>(
                        items:
                            _filteredParents
                                .map(
                                  (l) => DropdownMenuItem(
                                    value: l.technicalCode,
                                    child: Text(
                                      l.name + ' (' + l.technicalCode + ')',
                                    ),
                                  ),
                                )
                                .toList(),
                        value: _parentCode,
                        onChanged: (v) {
                          setState(() {
                            _parentCode = v;
                            _generateNameAndCode();
                          });
                        },
                        hintText: 'Buscar por nombre, código o tipo...',
                        labelText: 'Seleccionar ubicación padre',
                        validator:
                            (v) =>
                                v == null
                                    ? 'Seleccione una ubicación padre'
                                    : null,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onCreate({
                            'name': _nameController.text,
                            'technicalCode': _codeController.text,
                            'type': _typeId,
                            'parentTechnicalCode':
                                _lockToCurrent &&
                                        widget.selectedLocation != null
                                    ? widget.selectedLocation!.technicalCode
                                    : _parentCode,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Crear'),
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
