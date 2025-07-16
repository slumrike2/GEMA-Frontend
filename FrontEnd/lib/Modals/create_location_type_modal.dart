import 'package:flutter/material.dart';
import 'package:frontend/Services/user_service.dart';

class CreateLocationTypeModal extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> data) onCreate;
  final VoidCallback onCancel;

  const CreateLocationTypeModal({
    Key? key,
    required this.onCreate,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CreateLocationTypeModal> createState() =>
      _CreateLocationTypeModalState();
}

class _CreateLocationTypeModalState extends State<CreateLocationTypeModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _nameTemplate = '';
  String _codeTemplate = '';
  bool _loading = false;
  String? _error;

  // Persistent controllers for template fields
  late final TextEditingController _nameTemplateController;
  late final TextEditingController _codeTemplateController;

  // Variables available for templates
  final List<Map<String, String>> _templateVariables = [
    {
      'tag': '{parent_code}',
      'label': 'Código del padre',
      'tooltip':
          'El código técnico de la ubicación padre (ej: SEDE, MOD1, etc.)',
    },
    {
      'tag': '{serial}',
      'label': 'Serial incremental',
      'tooltip':
          'Un número incremental único para este tipo bajo el mismo padre (ej: 1, 2, 3...)',
    },
    {
      'tag': '{type}',
      'label': 'Tipo',
      'tooltip':
          'El nombre del tipo de ubicación (ej: Módulo, Piso, Sala, etc.)',
    },
    {
      'tag': '{parent_name}',
      'label': 'Nombre del padre',
      'tooltip': 'El nombre de la ubicación padre',
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameTemplateController = TextEditingController(text: _nameTemplate);
    _codeTemplateController = TextEditingController(text: _codeTemplate);
    _nameTemplateController.addListener(() {
      setState(() {
        _nameTemplate = _nameTemplateController.text;
      });
    });
    _codeTemplateController.addListener(() {
      setState(() {
        _codeTemplate = _codeTemplateController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameTemplateController.dispose();
    _codeTemplateController.dispose();
    super.dispose();
  }

  // Helper to insert tag at cursor position
  void _insertTagToTemplate(String tag, bool isNameTemplate) {
    final controller =
        isNameTemplate ? _nameTemplateController : _codeTemplateController;
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, tag);
    final newSelectionIndex = selection.start + tag.length;
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Crear Tipo de Ubicación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                // --- Tutorial/Guía de variables ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Guía de variables para plantillas:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ..._templateVariables.map(
                        (v) => Row(
                          children: [
                            Tooltip(
                              message: v['tooltip']!,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  v['tag']!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                            Text(v['label']!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // --- Tag selection for Name Template ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children:
                        _templateVariables
                            .map(
                              (v) => Tooltip(
                                message: v['tooltip']!,
                                child: ActionChip(
                                  label: Text(v['tag']!),
                                  onPressed:
                                      () =>
                                          _insertTagToTemplate(v['tag']!, true),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Plantilla de Nombre',
                    border: OutlineInputBorder(),
                  ),
                  controller: _nameTemplateController,
                  validator:
                      (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'La plantilla de nombre es requerida'
                              : null,
                ),
                const SizedBox(height: 12),
                // --- Tag selection for Code Template ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children:
                        _templateVariables
                            .map(
                              (v) => Tooltip(
                                message: v['tooltip']!,
                                child: ActionChip(
                                  label: Text(v['tag']!),
                                  onPressed:
                                      () => _insertTagToTemplate(
                                        v['tag']!,
                                        false,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Plantilla de Código',
                    border: OutlineInputBorder(),
                  ),
                  controller: _codeTemplateController,
                  validator:
                      (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'La plantilla de código es requerida'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _name = val),
                  validator:
                      (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'El nombre es requerido'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _description = val),
                  minLines: 1,
                  maxLines: 3,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : widget.onCancel,
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          _loading
                              ? null
                              : () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {
                                    _loading = true;
                                    _error = null;
                                  });
                                  try {
                                    await widget.onCreate({
                                      'name': _name.trim(),
                                      'description':
                                          _description.trim().isEmpty
                                              ? null
                                              : _description.trim(),
                                      'nameTemplate':
                                          _nameTemplateController.text.trim(),
                                      'codeTemplate':
                                          _codeTemplateController.text.trim(),
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _error =
                                          'Error al crear tipo de ubicación';
                                      _loading = false;
                                    });
                                  }
                                }
                              },
                      child:
                          _loading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Crear'),
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
