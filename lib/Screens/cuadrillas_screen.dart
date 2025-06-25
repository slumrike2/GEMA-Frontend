import 'package:flutter/material.dart';
import 'crear_modificar_cuadrilla_screen.dart';
import 'crear_modificar_persona_screen.dart';

class CuadrillasScreen extends StatefulWidget {
  const CuadrillasScreen({super.key});

  @override
  State<CuadrillasScreen> createState() => _CuadrillasScreenState();
}

class _CuadrillasScreenState extends State<CuadrillasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'Líder';
  final List<String> _searchTypes = ['Líder', 'Especialidad', 'Nombre'];

  List<Map<String, dynamic>> cuadrillas = [
    {
      "nombre": "Cuadrilla 1: Arturo Márquez",
      "especialidad": "Electricidad",
      "miembros": [
        {"nombre": "Juan Pablo Gómez", "ci": "20134586"},
        {"nombre": "María Fernanda Fermín", "ci": "29315985"},
        {"nombre": "Pedro Manuel Guzmán", "ci": "19874625"},
      ]
    },
    {
      "nombre": "Cuadrilla 2: Arturo Martinez",
      "especialidad": "Aseo",
      "miembros": [
        {"nombre": "Hilda Martinez", "ci": "20134386"},
        {"nombre": "Julio Millán", "ci": "29325985"},
        {"nombre": "Miguel Silva", "ci": "18874625"},
      ]
    },
  ];

  void _onCrearCuadrilla() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearModificarCuadrillaScreen(),
      ),
    );
    // Recargar cuadrillas del endpoint si lo deseas
  }

  void _onCrearOModificarPersona() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CrearModificarPersonaScreen(),
      ),
    );
    // Recargar datos del endpoint si lo deseas
  }

  void _onModificar(int i) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearModificarCuadrillaScreen(
          cuadrillaData: cuadrillas[i],
        ),
      ),
    );
    // Recargar cuadrillas del endpoint si lo deseas
  }

  void _onVerMantenimientos(int i) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver mantenimientos de ${cuadrillas[i]["nombre"]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD6F3FB),
      width: double.infinity,
      child: SingleChildScrollView(
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
                        onPressed: _onCrearCuadrilla,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196B6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        child: const Text("Crear Cuadrilla"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _onCrearOModificarPersona,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196B6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buscar...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text(
                              'Por ',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              value: _searchType,
                              borderRadius: BorderRadius.circular(8),
                              items: _searchTypes
                                  .map((tipo) => DropdownMenuItem(
                                        value: tipo,
                                        child: Text(tipo),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _searchType = value!;
                                });
                              },
                            ),
                            const Text(
                              ' : ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal.shade900),
                                    borderRadius: BorderRadius.circular(3.5),
                                  ),
                                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
                              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                                  bottom: BorderSide(color: Color(0xFF26384D), width: 0.5),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      m["nombre"],
                                      style: const TextStyle(fontSize: 17, color: Colors.black),
                                    ),
                                  ),
                                  if (m["ci"] != null)
                                    Text(
                                      "CI: ${m["ci"]}",
                                      style: const TextStyle(fontSize: 16, color: Colors.black87),
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
                                onPressed: () => _onVerMantenimientos(i),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2293B4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                ),
                                child: const Text("Ver Mantenimientos"),
                              ),
                              const SizedBox(width: 22),
                              ElevatedButton(
                                onPressed: () => _onModificar(i),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2293B4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
      ),
    );
  }
}
