import 'package:flutter/material.dart';
import 'package:frontend/Pages/cuadrillas/cuadrillas_inicio_page.dart';
import '../Pages/cuadrillas/crear_modificar_cuadrilla_page.dart';
import '../Pages/cuadrillas/crear_modificar_persona_page.dart';

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
      ],
    },
    {
      "nombre": "Cuadrilla 2: Arturo Martinez",
      "especialidad": "Aseo",
      "miembros": [
        {"nombre": "Hilda Martinez", "ci": "20134386"},
        {"nombre": "Julio Millán", "ci": "29325985"},
        {"nombre": "Miguel Silva", "ci": "18874625"},
      ],
    },
  ];

  int _pantalla =
      0; // 0: inicio, 1: crear cuadrilla, 2: crear/modificar persona, 3: modificar cuadrilla
  Map<String, dynamic>? _cuadrillaSeleccionada;

  //Navegación y acciones

  void _goToInicio() {
    setState(() {
      _pantalla = 0;
      _cuadrillaSeleccionada = null;
    });
  }

  void _onCrearCuadrilla() {
    setState(() {
      _pantalla = 1;
      _cuadrillaSeleccionada = null;
    });
  }

  void _onCrearOModificarPersona() {
    setState(() {
      _pantalla = 2;
    });
  }

  void _onModificar(int i) {
    setState(() {
      _pantalla = 3;
      _cuadrillaSeleccionada = cuadrillas[i];
    });
  }

  void _onVerMantenimientos(int i) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver mantenimientos de ${cuadrillas[i]["nombre"]}'),
      ),
    );
  }

  // Navegación y acciones

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, top: 18, bottom: 8),
        child: TextButton.icon(
          onPressed: _goToInicio,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Volver'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_pantalla == 1) {
      child = Column(
        children: [
          _buildBackButton(),
          Expanded(child: CrearModificarCuadrillaPage()),
        ],
      );
    } else if (_pantalla == 2) {
      child = Column(
        children: [
          _buildBackButton(),
          Expanded(child: CrearModificarPersonaPage()),
        ],
      );
    } else if (_pantalla == 3) {
      child = Column(
        children: [
          _buildBackButton(),
          Expanded(
            child: CrearModificarCuadrillaPage(
              cuadrillaData: _cuadrillaSeleccionada,
            ),
          ),
        ],
      );
    } else {
      child = CuadrillasInicioPage(
        searchController: _searchController,
        searchType: _searchType,
        searchTypes: _searchTypes,
        cuadrillas: cuadrillas,
        onCrearCuadrilla: _onCrearCuadrilla,
        onCrearOModificarPersona: _onCrearOModificarPersona,
        onVerMantenimientos: _onVerMantenimientos,
        onModificar: _onModificar,
      );
    }

    return Container(
      color: const Color(0xFFD6F3FB),
      width: double.infinity,
      child: child,
    );
  }
}
