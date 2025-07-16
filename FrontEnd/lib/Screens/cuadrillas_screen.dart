import 'package:flutter/material.dart';
import 'package:frontend/Pages/cuadrillas/cuadrillas_inicio_page.dart';
import 'package:frontend/Pages/cuadrillas/crear_modificar_cuadrilla_page.dart';
import 'package:frontend/Pages/cuadrillas/crear_modificar_persona_page.dart';
import 'package:frontend/Services/technical_team_service.dart';
import 'package:frontend/Models/backend_types.dart';

class CuadrillasScreen extends StatefulWidget {
  const CuadrillasScreen({super.key});

  @override
  State<CuadrillasScreen> createState() => _CuadrillasScreenState();
}

class _CuadrillasScreenState extends State<CuadrillasScreen> {
  List<TechnicalTeam> _cuadrillas = [];
  bool _loading = false;
  int _pantalla = 0; // 0: inicio, 1: crear/modificar persona

  @override
  void initState() {
    super.initState();
    _loadCuadrillas();
  }

  Future<void> _loadCuadrillas() async {
    setState(() => _loading = true);
    try {
      final cuadrillas = await TechnicalTeamService.getAll();
      setState(() {
        _cuadrillas = cuadrillas;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando cuadrillas: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _refreshAndGoToInicio() async {
    await _loadCuadrillas();
    setState(() {
      _pantalla = 0;
    });
  }

  void _onCrearCuadrilla() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: CrearModificarCuadrillaPage(
          onSuccess: _refreshAndGoToInicio,
        ),
      ),
    );
  }

  void _onCrearOModificarPersona() {
    setState(() {
      _pantalla = 1;
    });
  }

  void _onModificar(TechnicalTeam team) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: CrearModificarCuadrillaPage(
          cuadrillaData: team.toJson(), // tu modelo debe tener toJson()
          onSuccess: _refreshAndGoToInicio,
        ),
      ),
    );
  }

  void _onVerMantenimientos(TechnicalTeam team) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver mantenimientos de ${team.name}')),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, top: 18, bottom: 8),
        child: TextButton.icon(
          onPressed: _refreshAndGoToInicio,
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
          const Expanded(child: CrearModificarPersonaPage()),
        ],
      );
    } else {
      child = CuadrillasInicioPage(
        cuadrillas: _cuadrillas,
        onCrearCuadrilla: _onCrearCuadrilla,
        onCrearOModificarPersona: _onCrearOModificarPersona,
        onModificar: _onModificar,
        onVerMantenimientos: _onVerMantenimientos,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD6F3FB),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(child: child),
    );
  }
}
