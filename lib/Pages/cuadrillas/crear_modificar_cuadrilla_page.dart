import 'package:flutter/material.dart';

class CrearModificarCuadrillaPage extends StatefulWidget {
  final Map<String, dynamic>? cuadrillaData;
  const CrearModificarCuadrillaPage({super.key, this.cuadrillaData});

  @override
  State<CrearModificarCuadrillaPage> createState() =>
      _CrearModificarCuadrillaPageState();
}

class _CrearModificarCuadrillaPageState
    extends State<CrearModificarCuadrillaPage> {
  late TextEditingController _liderController;
  late TextEditingController _especialidadController;
  List<Map<String, String>> miembros = [];
  List<TextEditingController> _nombreControllers = [];
  List<TextEditingController> _ciControllers = [];

  @override
  void initState() {
    super.initState();
    _liderController = TextEditingController(
      text: widget.cuadrillaData?["nombre"]?.split(": ").last ?? "",
    );
    _especialidadController = TextEditingController(
      text: widget.cuadrillaData?["especialidad"] ?? "",
    );
    miembros = List<Map<String, String>>.from(
      widget.cuadrillaData?["miembros"] ??
          [
            {"nombre": "Juan Pablo Gómez", "ci": "20134586"},
            {"nombre": "María Fernanda Fermín", "ci": "29315985"},
            {"nombre": "Pedro Manuel Guzmán", "ci": "19874625"},
          ],
    );
    _initControllers();
  }

  void _initControllers() {
    _nombreControllers = [];
    _ciControllers = [];
    for (var m in miembros) {
      _nombreControllers.add(TextEditingController(text: m["nombre"] ?? ""));
      _ciControllers.add(TextEditingController(text: m["ci"] ?? ""));
    }
  }

  void _onAgregarMiembro() {
    setState(() {
      miembros.add({"nombre": "", "ci": ""});
      _nombreControllers.add(TextEditingController());
      _ciControllers.add(TextEditingController());
    });
  }

  void _onEliminarMiembro(int index) {
    setState(() {
      miembros.removeAt(index);
      _nombreControllers[index].dispose();
      _ciControllers[index].dispose();
      _nombreControllers.removeAt(index);
      _ciControllers.removeAt(index);
    });
  }

  void _onGuardar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Guardado (endpoint)")));
  }

  void _onEliminar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Eliminado (endpoint)")));
  }

  @override
  void dispose() {
    _liderController.dispose();
    _especialidadController.dispose();
    for (var c in _nombreControllers) {
      c.dispose();
    }
    for (var c in _ciControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Crear/Modificar Cuadrilla',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Arial",
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Campo líder
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Líder de la Cuadrilla",
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _liderController,
                          style: const TextStyle(fontSize: 17),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 9,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            // Campo especialidad
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Especialidad", style: TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _especialidadController,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Miembros de la cuadrilla
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Miembros de la Cuadrilla",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(miembros.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _nombreControllers[i],
                              onChanged: (val) => miembros[i]["nombre"] = val,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _ciControllers[i],
                              onChanged: (val) => miembros[i]["ci"] = val,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "CI",
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFFA5242),
                            ),
                            onPressed: () => _onEliminarMiembro(i),
                            tooltip: 'Eliminar miembro',
                          ),
                        ],
                      ),
                    );
                  }),
                  Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF2293B4),
                        size: 28,
                      ),
                      onPressed: _onAgregarMiembro,
                      tooltip: 'Agregar miembro',
                    ),
                  ),
                ],
              ),
            ),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _onEliminar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5443),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _onGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2293B4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
