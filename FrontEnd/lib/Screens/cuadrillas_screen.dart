import 'package:flutter/material.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/Pages/cuadrillas/cuadrillas_inicio_page.dart';
import 'package:frontend/Modals/crear_modificar_cuadrilla_modal.dart';

import 'package:frontend/Services/technical_team_service.dart';

class CuadrillasScreen extends StatefulWidget {
  const CuadrillasScreen({super.key});

  @override
  State<CuadrillasScreen> createState() => _CuadrillasScreenState();
}

class _CuadrillasScreenState extends State<CuadrillasScreen> {
  List<TechnicalTeam> _cuadrillas = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCuadrillas();
  }

  Future<void> _loadCuadrillas() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final cuadrillas = await TechnicalTeamService.getAll();
      if (!mounted) return;
      setState(() => _cuadrillas = cuadrillas);
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

  Future<void> _refreshData() async {
    await _loadCuadrillas();
  }

  Future<void> _onCrearCuadrilla() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            child: CrearModificarCuadrillaPage(onSuccess: _refreshData),
          ),
    );
  }

  Future<void> _onModificarCuadrilla(TechnicalTeam team) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            child: CrearModificarCuadrillaPage(
              cuadrillaData: team.toJson(),
              onSuccess: _refreshData,
            ),
          ),
    );
  }

  void _onVerMantenimientos(TechnicalTeam team) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver mantenimientos de ${team.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F3FB),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: CuadrillasInicioPage(
                  cuadrillas: _cuadrillas,
                  onCrearCuadrilla: _onCrearCuadrilla,
                  onRefresh: _refreshData,
                  onModificar: _onModificarCuadrilla,
                  onVerMantenimientos: _onVerMantenimientos,
                ),
              ),
    );
  }
}
