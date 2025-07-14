import 'package:flutter/material.dart';

class CuadrillasInicioPage extends StatelessWidget {
  final TextEditingController searchController;
  final String searchType;
  final List<String> searchTypes;
  final List<Map<String, dynamic>> cuadrillas;
  final void Function() onCrearCuadrilla;
  final void Function() onCrearOModificarPersona;
  final void Function(int) onVerMantenimientos;
  final void Function(int) onModificar;

  const CuadrillasInicioPage({
    super.key,
    required this.searchController,
    required this.searchType,
    required this.searchTypes,
    required this.cuadrillas,
    required this.onCrearCuadrilla,
    required this.onCrearOModificarPersona,
    required this.onVerMantenimientos,
    required this.onModificar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 8, 0, 12),
                child: Text(
                  'Cuadrillas',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: "Arial",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botones superiores
              Padding(
                padding: const EdgeInsets.only(right: 35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onCrearCuadrilla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196B6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text("Crear Cuadrilla"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onCrearOModificarPersona,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196B6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text("Crear o Modificar Persona"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // Buscador
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buscar...',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Por ', style: TextStyle(fontSize: 16)),
                          DropdownButton<String>(
                            value: searchType,
                            borderRadius: BorderRadius.circular(8),
                            items: searchTypes
                                .map((tipo) => DropdownMenuItem(
                                      value: tipo,
                                      child: Text(tipo),
                                    ))
                                .toList(),
                            onChanged: null, // El control lo tiene el padre
                          ),
                          const Text(' : ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.teal,
                                  ),
                                  borderRadius: BorderRadius.circular(3.5),
                                ),
                              ),
                              enabled: false, // El control lo tiene el padre
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              // Cuadrillas
              ...List.generate(cuadrillas.length, (i) {
                final cuadrilla = cuadrillas[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado cuadrilla
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF93D7F3),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(17),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cuadrilla["nombre"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF22356A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (cuadrilla["especialidad"] != null)
                                Text(
                                  "Especialidad: ${cuadrilla["especialidad"]}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF22356A),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Miembros
                        ...cuadrilla["miembros"].map<Widget>((m) {
                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF26384D),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    m["nombre"],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                if (m["ci"] != null)
                                  Text(
                                    "CI: ${m["ci"]}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => onVerMantenimientos(i),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2293B4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 7,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text("Ver Mantenimientos"),
                            ),
                            const SizedBox(width: 22),
                            ElevatedButton(
                              onPressed: () => onModificar(i),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2293B4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 7,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text("Modificar"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
