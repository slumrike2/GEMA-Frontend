import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/Models/backend_types.dart';

class CrearTipoUbicacionModal extends StatefulWidget {
  final void Function(LocationType locationType) onCreate;
  const CrearTipoUbicacionModal({Key? key, required this.onCreate})
    : super(key: key);

  @override
  State<CrearTipoUbicacionModal> createState() =>
      _CrearTipoUbicacionModalState();
}

class _CrearTipoUbicacionModalState extends State<CrearTipoUbicacionModal> {
  final ScrollController _scrollController = ScrollController();
  // Custom widget for autocomplete in format fields
  // Controllers and focus nodes for autocomplete fields
  late final TextEditingController _formatoCodigoController;
  late final FocusNode _formatoCodigoFocusNode;
  late final TextEditingController _formatoNombreController;
  late final FocusNode _formatoNombreFocusNode;

  @override
  void initState() {
    super.initState();
    _formatoCodigoController = TextEditingController(text: formatoCodigo);
    _formatoCodigoFocusNode = FocusNode();
    _formatoNombreController = TextEditingController(text: formatoNombre);
    _formatoNombreFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _formatoCodigoController.dispose();
    _formatoCodigoFocusNode.dispose();
    _formatoNombreController.dispose();
    _formatoNombreFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _CampoAutocompleteTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required void Function(String) onChanged,
    required List<Map<String, String?>> campos,
    String? Function(String?)? validator,
    String tooltip = '',
  }) {
    return StatefulBuilder(
      builder: (context, setStateField) {
        List<String> campoIds =
            campos
                .map((c) => c['id'] ?? '')
                .where((id) => id.isNotEmpty)
                .toList();
        List<String> suggestions = [];
        int selectedIndex = 0;
        void updateSuggestions(String text, int cursorPos) {
          suggestions = [];
          final beforeCursor = text.substring(0, cursorPos);
          final match = RegExp(r'\{([^}]*)$').firstMatch(beforeCursor);
          if (match != null) {
            suggestions =
                campoIds
                    .where((id) => id.startsWith(match.group(1) ?? ''))
                    .toList();
          }
          if (selectedIndex >= suggestions.length) selectedIndex = 0;
          // If suggestions are visible, scroll to bottom
          if (suggestions.isNotEmpty && focusNode.hasFocus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        }

        return FocusScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Focus(
                onKey: (node, event) {
                  if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
                  final cursorPos = controller.selection.baseOffset;
                  updateSuggestions(
                    controller.text,
                    cursorPos < 0 ? controller.text.length : cursorPos,
                  );
                  if (suggestions.isEmpty) return KeyEventResult.ignored;
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    selectedIndex = (selectedIndex + 1) % suggestions.length;
                    setStateField(() {});
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    selectedIndex =
                        (selectedIndex - 1 + suggestions.length) %
                        suggestions.length;
                    setStateField(() {});
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                    final text = controller.text;
                    final cursor = controller.selection.baseOffset;
                    final before = text.substring(0, cursor);
                    final match = RegExp(r'\{([^}]*)$').firstMatch(before);
                    if (match != null && suggestions.isNotEmpty) {
                      final start = match.start + 1;
                      final newText =
                          text.replaceRange(
                            start,
                            cursor,
                            suggestions[selectedIndex],
                          ) +
                          '}';
                      controller.text = newText;
                      controller.selection = TextSelection.collapsed(
                        offset: start + suggestions[selectedIndex].length + 1,
                      );
                      onChanged(newText);
                      setStateField(() {});
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    suffixIcon: Tooltip(
                      message: tooltip,
                      child: const Icon(Icons.help_outline, size: 18),
                    ),
                  ),
                  validator: validator,
                  onChanged: (v) {
                    onChanged(v);
                    setStateField(() {});
                  },
                  onTap: () {
                    setStateField(() {});
                  },
                  onEditingComplete: () {
                    setStateField(() {});
                  },
                  onFieldSubmitted: (_) {
                    setStateField(() {});
                  },
                  onSaved: (_) {
                    setStateField(() {});
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              Builder(
                builder: (context) {
                  final cursorPos = controller.selection.baseOffset;
                  updateSuggestions(
                    controller.text,
                    cursorPos < 0 ? controller.text.length : cursorPos,
                  );
                  if (suggestions.isNotEmpty && focusNode.hasFocus) {
                    return Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        itemBuilder: (context, i) {
                          return Material(
                            color:
                                i == selectedIndex
                                    ? Colors.blue[50]
                                    : Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                final text = controller.text;
                                final cursor = controller.selection.baseOffset;
                                final before = text.substring(0, cursor);
                                final match = RegExp(
                                  r'\{([^}]*)$',
                                ).firstMatch(before);
                                if (match != null) {
                                  final start = match.start + 1;
                                  final newText =
                                      text.replaceRange(
                                        start,
                                        cursor,
                                        suggestions[i],
                                      ) +
                                      '}';
                                  controller.text = newText;
                                  controller
                                      .selection = TextSelection.collapsed(
                                    offset: start + suggestions[i].length + 1,
                                  );
                                  onChanged(newText);
                                  setStateField(() {});
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  suggestions[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        i == selectedIndex
                                            ? Colors.blue
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String descripcion = '';
  String formatoCodigo = '';
  String formatoNombre = '';
  List<Map<String, String?>> campos = [
    {'id': '', 'name': '', 'type': 'text', 'defaultValue': ''},
  ];

  void addCampo() {
    setState(() {
      campos.add({'id': '', 'name': '', 'type': 'text', 'defaultValue': ''});
    });
  }

  void removeCampo(int idx) {
    setState(() {
      if (campos.length > 1) campos.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Crear Nuevo Tipo de Ubicación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message:
                                'Define una plantilla para un tipo de ubicación técnica. Ejemplo: Laboratorio, Salón, Oficina.',
                            child: const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nombre del Tipo *',
                            hintText: 'Ej: Laboratorio, Salón, Oficina... ',
                            suffixIcon: Tooltip(
                              message:
                                  'Nombre general del tipo de ubicación. Ejemplo: Laboratorio, Salón, Oficina.',
                              child: const Icon(Icons.help_outline, size: 18),
                            ),
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'El nombre es obligatorio'
                                      : null,
                          onChanged: (v) => nombre = v,
                          autofocus: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción opcional',
                      suffixIcon: Tooltip(
                        message:
                            'Descripción adicional para el tipo de ubicación.',
                        child: const Icon(Icons.help_outline, size: 18),
                      ),
                    ),
                    onChanged: (v) => descripcion = v,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Variables Personalizadas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message:
                            'Las variables permiten personalizar la plantilla de código y nombre. Ejemplo: {laboratorio}, {número}',
                        child: const Icon(
                          Icons.help_outline,
                          size: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Variable'),
                        onPressed: addCampo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...campos.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var c = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Variable ${idx + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (campos.length > 1)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    tooltip: 'Eliminar Variable',
                                    onPressed: () => removeCampo(idx),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Etiqueta para Plantilla',
                                      hintText: 'Ej: laboratorio',
                                      suffixIcon: Tooltip(
                                        message:
                                            'Esta etiqueta se usará como variable en las plantillas de código y nombre. Ejemplo: {laboratorio}, {número}.',
                                        child: const Icon(
                                          Icons.help_outline,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'Etiqueta requerida'
                                                : null,
                                    onChanged: (val) => c['id'] = val,
                                    initialValue: c['id'],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Nombre',
                                      hintText: 'Ej: Laboratorio',
                                      suffixIcon: Tooltip(
                                        message:
                                            'Nombre descriptivo de la variable.',
                                        child: const Icon(
                                          Icons.help_outline,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.trim().isEmpty)
                                                ? 'Nombre requerido'
                                                : null,
                                    onChanged: (val) => c['name'] = val,
                                    initialValue: c['name'],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: DropdownButtonFormField<String>(
                                    value: c['type'] ?? 'text',
                                    decoration: InputDecoration(
                                      labelText: 'Tipo',
                                      suffixIcon: Tooltip(
                                        message: 'Tipo de dato de la variable.',
                                        child: const Icon(
                                          Icons.help_outline,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'text',
                                        child: Text('Texto'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'serial',
                                        child: Text('Serial'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'select',
                                        child: Text('Selección'),
                                      ),
                                    ],
                                    onChanged:
                                        (val) => setState(() {
                                          c['type'] = val;
                                        }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Valor por Defecto',
                                hintText: 'Valor predeterminado',
                                suffixIcon: Tooltip(
                                  message:
                                      'Valor inicial sugerido para la variable.',
                                  child: const Icon(
                                    Icons.help_outline,
                                    size: 18,
                                  ),
                                ),
                              ),
                              onChanged: (val) => c['defaultValue'] = val,
                              initialValue: c['defaultValue'],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    'Plantillas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Usa las variables definidas arriba para crear el formato de código y nombre. Escribe el texto y selecciona variables usando llaves { } para armar la plantilla.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ),
                  _CampoAutocompleteTextField(
                    label: 'Plantilla de Código',
                    hint: 'Ejemplo: {laboratorio}-{número}',
                    controller: _formatoCodigoController,
                    focusNode: _formatoCodigoFocusNode,
                    onChanged: (v) {
                      setState(() {
                        formatoCodigo = v;
                      });
                    },
                    campos: campos,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Plantilla requerida'
                                : null,
                    tooltip:
                        'Usa las variables entre llaves. Ejemplo: {laboratorio}-{número}',
                  ),
                  Builder(
                    builder: (context) {
                      // Ejemplo en vivo para código
                      String ejemplo = formatoCodigo;
                      campos.forEach((c) {
                        if (c['id'] != null && c['id']!.isNotEmpty) {
                          ejemplo = ejemplo.replaceAll(
                            '{${c['id']}}',
                            c['defaultValue']?.isNotEmpty == true
                                ? c['defaultValue']!
                                : c['id']!,
                          );
                        }
                      });
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, left: 2),
                        child: Text(
                          'Ejemplo: $ejemplo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _CampoAutocompleteTextField(
                    label: 'Plantilla de Nombre *',
                    hint: 'Ejemplo: Laboratorio {número}',
                    controller: _formatoNombreController,
                    focusNode: _formatoNombreFocusNode,
                    onChanged: (v) {
                      setState(() {
                        formatoNombre = v;
                      });
                    },
                    campos: campos,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Plantilla requerida'
                                : null,
                    tooltip:
                        'Usa las variables entre llaves. Ejemplo: Laboratorio {número}',
                  ),
                  Builder(
                    builder: (context) {
                      // Ejemplo en vivo para nombre
                      String ejemplo = formatoNombre;
                      campos.forEach((c) {
                        if (c['id'] != null && c['id']!.isNotEmpty) {
                          ejemplo = ejemplo.replaceAll(
                            '{${c['id']}}',
                            c['defaultValue']?.isNotEmpty == true
                                ? c['defaultValue']!
                                : c['id']!,
                          );
                        }
                      });
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, left: 2),
                        child: Text(
                          'Ejemplo: $ejemplo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final locationType = LocationType(
                              name: nombre.trim(),
                              icon: 'settings',
                              description:
                                  descripcion.trim().isEmpty
                                      ? null
                                      : descripcion.trim(),
                              nameTemplate: formatoNombre.trim(),
                              codeTemplate: formatoCodigo.trim(),
                              fields: {
                                'campos':
                                    campos
                                        .map(
                                          (c) => {
                                            'id': c['id']!.trim(),
                                            'name': c['name']!.trim(),
                                            'type': c['type'] ?? 'text',
                                            'defaultValue':
                                                (c['defaultValue']
                                                            ?.trim()
                                                            .isEmpty ??
                                                        true)
                                                    ? null
                                                    : c['defaultValue']!.trim(),
                                          },
                                        )
                                        .toList(),
                              },
                            );
                            widget.onCreate(locationType);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Crear Tipo'),
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
