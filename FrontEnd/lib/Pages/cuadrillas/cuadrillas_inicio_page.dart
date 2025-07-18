import 'package:flutter/material.dart';
import '../../Models/backend_types.dart';
import '../../Modals/create_technician_modal.dart';
import 'package:frontend/Services/technician_service.dart';
import 'package:frontend/Services/user_service.dart';
import 'package:frontend/Services/technician_speciality_service.dart';
import 'package:frontend/constants/app_constnats.dart';

class CuadrillasInicioPage extends StatefulWidget {
  final List<TechnicalTeam> cuadrillas;
  final VoidCallback onCrearCuadrilla;
  final Future<void> Function() onRefresh;
  final void Function(TechnicalTeam) onVerMantenimientos;
  final void Function(TechnicalTeam) onModificar;

  const CuadrillasInicioPage({
    super.key,
    required this.cuadrillas,
    required this.onCrearCuadrilla,
    required this.onRefresh,
    required this.onVerMantenimientos,
    required this.onModificar,
  });

  @override
  State<CuadrillasInicioPage> createState() => _CuadrillasInicioPageState();
}

class _CuadrillasInicioPageState extends State<CuadrillasInicioPage> {
  bool _loadingModal = false;
  List<User> _usuariosDisponibles = [];
  List<String> _especialidades = [];

  Future<void> _abrirModalCrearModificarPersona() async {
    setState(() => _loadingModal = true);

    try {
      final especialidades = await TechnicianSpecialityService.getAll();
      final usuariosDisponibles = await UserService.getAvailableUsers();

      if (!mounted) return;

      setState(() {
        _especialidades = especialidades;
        _usuariosDisponibles = usuariosDisponibles;
        _loadingModal = false;
      });

      await showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: CreateTechnicianModal(
                especialidades: _especialidades,
                usuariosDisponibles: _usuariosDisponibles,
                onCreate: (data) async {
                  try {
                    // Convertimos todos los campos a String
                    final cleanData = data.map(
                      (k, v) => MapEntry(k, v?.toString()),
                    );

                    await TechnicianService.create(cleanData);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Técnico creado/actualizado'),
                      ),
                    );
                    Navigator.of(context).pop();
                    await widget.onRefresh();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al crear técnico: $e')),
                    );
                  }
                },
                onCancel: () {
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingModal = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos para técnico: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(35, 8, 0, 12),
                    child: Text(
                      'Cuadrillas',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: "Arial",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: widget.onCrearCuadrilla,
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
                          onPressed:
                              _loadingModal
                                  ? null
                                  : _abrirModalCrearModificarPersona,
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
                  ...widget.cuadrillas.map((cuadrilla) {
                    final String nombre =
                        cuadrilla.name.trim().isNotEmpty
                            ? cuadrilla.name
                            : 'Sin nombre';
                    final String? especialidad = cuadrilla.speciality;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.groups,
                                    color: AppColors.iconBlue,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Cuadrilla: $nombre',
                                              style: AppTextStyles.sectionTitle(
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            if (especialidad != null &&
                                                especialidad.isNotEmpty)
                                              Chip(
                                                label: Text(
                                                  especialidad,
                                                  style: AppTextStyles.label(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppColors.accentBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                              ),
                                            const SizedBox(width: 6),
                                            Chip(
                                              label: const Text(
                                                'Activa',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        // Placeholder para código
                                        Text(
                                          'CUA-XXX',
                                          style: AppTextStyles.bodySmall(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Placeholder para líder
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: AppColors.iconBlue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Líder de Cuadrilla',
                                    style: AppTextStyles.bodySmall(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Card(
                                color: AppColors.secondaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.iconBlue,
                                    child: Text(
                                      '?',
                                      style: AppTextStyles.body(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Nombre líder',
                                    style: AppTextStyles.body(),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CI: --------',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                      Text(
                                        '📞 --------',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                      Text(
                                        'correo@correo.com',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Placeholder para miembros
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: AppColors.iconBlue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Miembros (0)',
                                    style: AppTextStyles.bodySmall(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Column(
                                children: [
                                  Card(
                                    color: AppColors.secondaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.iconBlue,
                                        child: Text(
                                          '?',
                                          style: AppTextStyles.body(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'Nombre miembro',
                                        style: AppTextStyles.body(),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rol',
                                            style: AppTextStyles.bodySmall(),
                                          ),
                                          Text(
                                            'CI: --------',
                                            style: AppTextStyles.bodySmall(),
                                          ),
                                        ],
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.person_add,
                                        color: AppColors.iconBlue,
                                      ),
                                      label: Text(
                                        'Agregar Miembro',
                                        style: AppTextStyles.bodySmall(
                                          color: AppColors.iconBlue,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.iconBlue,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Placeholder para mantenimientos y ubicación
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '0',
                                        style: AppTextStyles.title(
                                          color: AppColors.warning,
                                        ),
                                      ),
                                      Text(
                                        'Mantenimientos Pendientes',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '0',
                                        style: AppTextStyles.title(
                                          color: AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        'Completados',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.iconBlue,
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          'Ubicación',
                                          style: AppTextStyles.bodySmall(),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Botones de acción
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        () => widget.onVerMantenimientos(
                                          cuadrilla,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.botonBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      textStyle: AppTextStyles.button(),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                    ),
                                    child: const Text("Ver Mantenimientos"),
                                  ),
                                  OutlinedButton(
                                    onPressed:
                                        () => widget.onModificar(cuadrilla),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.botonBlue,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                    ),
                                    child: Text(
                                      "Modificar",
                                      style: AppTextStyles.button(
                                        color: AppColors.botonBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
        if (_loadingModal)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
