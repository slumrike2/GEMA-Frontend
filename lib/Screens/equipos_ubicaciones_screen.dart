import 'package:flutter/material.dart';
import '../Pages/crear_equipo.dart';
import '../Pages/crear_ubicacion_tecnica.dart';
import '../Pages/inicio_equipos_ubicaciones.dart';

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
  int _pantalla = 0; // 0: inicio, 1: crear equipo, 2: crear ubicacion

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

  void _goToInicio() {
    setState(() {
      _pantalla = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_pantalla == 1) {
      child = CrearEquipo(onBack: _goToInicio);
    } else if (_pantalla == 2) {
      child = CrearUbicacionTecnica(onBack: _goToInicio);
    } else {
      child = InicioEquiposUbicaciones(
        onCrearEquipo: _goToCrearEquipo,
        onCrearUbicacion: _goToCrearUbicacion,
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
