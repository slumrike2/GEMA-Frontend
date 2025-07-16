import 'package:flutter/material.dart';
import 'package:frontend/Pages/cuadrillas/cuadrillas_inicio_page.dart';
import 'package:frontend/Pages/cuadrillas/crear_modificar_cuadrilla_page.dart';
import 'package:frontend/Services/technical_team_service.dart';
import 'package:frontend/Services/technician_service.dart';
import 'package:frontend/Services/technician_speciality_service.dart';
import 'package:frontend/Models/backend_types.dart';
import '../../Modals/CreateTechnicianModal.dart';

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

  // Carga cuadrillas desde backend y actualiza estado
  Future<void> _loadCuadrillas() async {
    setState(() => _loading = true);
    try {
      final cuadrillas = await TechnicalTeamService.getAll();
      if (mounted) {
        setState(() {
          _cuadrillas = cuadrillas;
        });
      }
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

  // Refresca y vuelve a pantalla de inicio
  Future<void> _refreshAndGoToInicio() async {
    await _loadCuadrillas();
  }

  // Mostrar modal para crear/modificar cuadrilla
  Future<void> _onCrearCuadrilla() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: CrearModificarCuadrillaPage(
          onSuccess: _refreshAndGoToInicio,
        ),
      ),
    );
  }

  // Mostrar modal para crear técnico con especialidades cargadas y llamada al servicio real
  Future<void> _onCrearOModificarPersona() async {
    try {
      final especialidades = await TechnicianSpecialityService.getAll();
      await showDialog(
        context: context,
        builder: (_) => CreateTechnicianModal(
          especialidades: especialidades,
          onCreate: (data) async {
            try {
              await TechnicianService.create(data);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Técnico creado/actualizado')),
                );
                Navigator.of(context).pop();
                await _loadCuadrillas();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear técnico: $e')),
                );
              }
            }
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar especialidades: $e')),
        );
      }
    }
  }

  // Mostrar modal para modificar cuadrilla existente
  Future<void> _onModificar(TechnicalTeam team) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        child: CrearModificarCuadrillaPage(
          cuadrillaData: team.toJson(),
          onSuccess: _refreshAndGoToInicio,
        ),
      ),
    );
  }

  // Acción para ver mantenimientos (placeholder)
  void _onVerMantenimientos(TechnicalTeam team) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver mantenimientos de ${team.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F3FB),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CuadrillasInicioPage(
                cuadrillas: _cuadrillas,
                onCrearCuadrilla: _onCrearCuadrilla,
                onCrearOModificarPersona: _onCrearOModificarPersona,
                onModificar: _onModificar,
                onVerMantenimientos: _onVerMantenimientos,
              ),
            ),
    );
  }
}
