import 'package:flutter/material.dart';
import '../Pages/equipos&ubicaciones/crear_equipo.dart';
import '../Pages/equipos&ubicaciones/crear_ubicacion_tecnica.dart';
import '../Pages/equipos&ubicaciones/inicio_equipos_ubicaciones.dart';
import '../Pages/equipos&ubicaciones/crear_tipo_ubicacion.dart';

class EquiposUbicacionesScreen extends StatefulWidget {
  final VoidCallback? onCrearEquipo;
  final VoidCallback? onCrearUbicacion;
  const EquiposUbicacionesScreen({
    super.key,
    this.onCrearEquipo,
    this.onCrearUbicacion,
  });

  @override
  State<EquiposUbicacionesScreen> createState() =>
      _EquiposUbicacionesScreenState();
}

class _EquiposUbicacionesScreenState extends State<EquiposUbicacionesScreen> {
  int _pantalla = 0; // 0: inicio, 1: crear equipo, 2: crear ubicacion, 3: tipos de ubicacion

  void _goToCrearEquipo() {
    setState(() {
      _pantalla = 1;
    });
  }

  void _goToCrearUbicacion() {
    setState(() {
      _pantalla = 2;
    });
  }

  void _goToTiposUbicacion() {
    setState(() {
      _pantalla = 3;
    });
  }

  void _goToInicio() {
    setState(() {
      _pantalla = 0;
    });
  }

  Widget buildBackButton(VoidCallback? onBack) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, top: 18, bottom: 8),
        child: TextButton.icon(
          onPressed: onBack,
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
          buildBackButton(_goToInicio),
          Expanded(child: CrearEquipo(onBack: _goToInicio)),
        ],
      );
    } else if (_pantalla == 2) {
      child = Column(
        children: [
          buildBackButton(_goToInicio),
          Expanded(child: CrearUbicacionTecnica(onBack: _goToInicio)),
        ],
      );
    } else if (_pantalla == 3) {
      child = Column(
        children: [
          buildBackButton(_goToInicio),
          Expanded(child: CrearTipoUbicacion()),
        ],
      );
    } else {
      child = InicioEquiposUbicaciones(
        onCrearEquipo: _goToCrearEquipo,
        onCrearUbicacion: _goToCrearUbicacion,
        onTiposUbicacion: _goToTiposUbicacion,
      );
    }
    return Container(
      color: const Color(0xFFD6ECE0),
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }
}
