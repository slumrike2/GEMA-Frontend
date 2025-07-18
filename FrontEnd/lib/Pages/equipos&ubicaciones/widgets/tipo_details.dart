import 'package:flutter/material.dart';

// Mock data models
class TemplateVariable {
  final String id;
  final String name;
  final String type;
  final String? defaultValue;
  final List<String>? options;

  TemplateVariable({
    required this.id,
    required this.name,
    required this.type,
    this.defaultValue,
    this.options,
  });
}

class LocationTemplate {
  final String id;
  final String name;
  final List<TemplateVariable> variables;
  final String codeFormat;
  final String nameFormat;

  LocationTemplate({
    required this.id,
    required this.name,
    required this.variables,
    required this.codeFormat,
    required this.nameFormat,
  });
}

// Mock templates
final List<LocationTemplate> mockTemplates = [
  LocationTemplate(
    id: "building",
    name: "Edificio",
    variables: [
      TemplateVariable(
        id: "prefix",
        name: "Prefijo",
        type: "text",
        defaultValue: "EDIF",
      ),
      TemplateVariable(id: "number", name: "Número", type: "serial"),
    ],
    codeFormat: "{prefix}{number}",
    nameFormat: "Edificio {number}",
  ),
  LocationTemplate(
    id: "floor",
    name: "Piso",
    variables: [
      TemplateVariable(
        id: "prefix",
        name: "Prefijo",
        type: "text",
        defaultValue: "PISO",
      ),
      TemplateVariable(id: "number", name: "Número", type: "serial"),
    ],
    codeFormat: "{prefix}{number}",
    nameFormat: "Piso {number}",
  ),
  LocationTemplate(
    id: "classroom",
    name: "Salón de Clase",
    variables: [
      TemplateVariable(
        id: "prefix",
        name: "Prefijo",
        type: "text",
        defaultValue: "SALON",
      ),
      TemplateVariable(id: "number", name: "Número", type: "serial"),
      TemplateVariable(
        id: "type",
        name: "Tipo",
        type: "select",
        options: ["Regular", "Multimedia", "Laboratorio"],
      ),
    ],
    codeFormat: "{prefix}{number}",
    nameFormat: "Salón {number} - {type}",
  ),
  LocationTemplate(
    id: "laboratory",
    name: "Laboratorio",
    variables: [
      TemplateVariable(
        id: "prefix",
        name: "Prefijo",
        type: "text",
        defaultValue: "LAB",
      ),
      TemplateVariable(id: "number", name: "Número", type: "serial"),
      TemplateVariable(
        id: "specialty",
        name: "Especialidad",
        type: "select",
        options: ["Química", "Física", "Biología", "Computación"],
      ),
    ],
    codeFormat: "{prefix}{number}",
    nameFormat: "Laboratorio de {specialty} {number}",
  ),
];

typedef VoidCallback = void Function();

class LocationTypesPage extends StatefulWidget {
  final VoidCallback? onClose;
  const LocationTypesPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<LocationTypesPage> createState() => _LocationTypesPageState();
}

class _LocationTypesPageState extends State<LocationTypesPage> {
  List<LocationTemplate> templates = List.from(mockTemplates);

  void _showCreateDialog() {
    // Implementar formulario de creación aquí
  }

  Color getVariableTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue.shade100;
      case 'serial':
        return Colors.green.shade100;
      case 'select':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  String getVariableTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Texto';
      case 'serial':
        return 'Serial';
      case 'select':
        return 'Selección';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para cerrar y volver a los detalles, necesitamos acceder a la pantalla padre y cambiar el tab
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
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tipos de Ubicación',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Gestiona las plantillas para crear ubicaciones técnicas',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Botón X para cerrar
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 28),
                        tooltip: 'Cerrar',
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child:
                          templates.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.settings,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
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
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text('Crear Primer Tipo'),
                                      onPressed: _showCreateDialog,
                                    ),
                                  ],
                                ),
                              )
                              : GridView.builder(
                                itemCount: templates.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                      childAspectRatio: 0.95,
                                    ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final template = templates[index];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.settings,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  template.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                ),
                                                onPressed: () {},
                                                tooltip: 'Editar',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                onPressed: () {},
                                                tooltip: 'Eliminar',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Formato de Código',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  template.codeFormat,
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  'Formato de Nombre',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  template.nameFormat,
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            'Variables (${template.variables.length})',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          ...template.variables.map(
                                            (v) => Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 6,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        v.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              getVariableTypeColor(
                                                                v.type,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          getVariableTypeLabel(
                                                            v.type,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (v.defaultValue != null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        'Por defecto: ${v.defaultValue}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  if (v.options != null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        'Opciones: ${v.options!.join(", ")}',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () {},
                                                  child: const Text('Editar'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () {},
                                                  child: const Text('Duplicar'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
  }
}
