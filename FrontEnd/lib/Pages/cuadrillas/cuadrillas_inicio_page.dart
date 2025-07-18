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
            (context) => CreateTechnicianModal(
              especialidades: _especialidades,
              usuariosDisponibles: _usuariosDisponibles,
              onCreate: (data) async {
                try {
                  final cleanData = data.map(
                    (k, v) => MapEntry(k, v?.toString()),
                  );
                  await TechnicianService.create(cleanData);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Técnico creado/actualizado')),
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
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingModal = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos para técnico: $e')),
      );
    }
  }

  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar cuadrillas según búsqueda
    final cuadrillasFiltradas =
        widget.cuadrillas.where((cuadrilla) {
          final nombre = cuadrilla.name.toLowerCase();
          final especialidad = (cuadrilla.speciality ?? '').toLowerCase();
          return nombre.contains(_searchText.toLowerCase()) ||
              especialidad.contains(_searchText.toLowerCase());
        }).toList();

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
                  // Título principal
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 8, 0, 12),
                    child: Text(
                      'Cuadrillas',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: "Arial",
                      ),
                    ),
                  ),
                  // Barra de búsqueda y botones
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        // Barra de búsqueda
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchText = value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText:
                                  'Buscar cuadrillas, técnicos o especialidades...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Botón de refresh
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF2196B6),
                          ),
                          tooltip: 'Refrescar',
                          onPressed: widget.onRefresh,
                        ),
                        const SizedBox(width: 10),
                        // Botón crear cuadrilla
                        ElevatedButton(
                          onPressed: widget.onCrearCuadrilla,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196B6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Crear Cuadrilla"),
                        ),
                        const SizedBox(width: 8),
                        // Botón crear/modificar persona
                        ElevatedButton(
                          onPressed:
                              _loadingModal
                                  ? null
                                  : _abrirModalCrearModificarPersona,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196B6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Crear o Modificar Persona"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ...existing code...
                  // Listado de cuadrillas
                  ...cuadrillasFiltradas.map((cuadrilla) {
                    final String nombre =
                        cuadrilla.name.trim().isNotEmpty
                            ? cuadrilla.name
                            : 'Sin nombre';
                    final String? especialidad = cuadrilla.speciality;
                    // MOCKS para campos no existentes en TechnicalTeam
                    final String codigo =
                        cuadrilla.id != null
                            ? 'CUA-${cuadrilla.id!.toString().padLeft(3, '0')}'
                            : 'CUA-XXX';
                    final bool activa = true;
                    final leader = null; // No existe en modelo
                    final List miembros = const []; // No existe en modelo
                    final int pendientes = 0;
                    final int completados = 0;
                    final String ubicacion = 'Ubicación no disponible';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header cuadrilla
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.groups,
                                      color: AppColors.iconBlue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '$nombre',
                                              style: AppTextStyles.sectionTitle(
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            if (especialidad != null &&
                                                especialidad.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 4,
                                                ),
                                                child: Chip(
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
                                              ),
                                            if (activa)
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
                                        Text(
                                          codigo,
                                          style: AppTextStyles.bodySmall(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Acciones (iconos)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        tooltip: 'Modificar',
                                        onPressed:
                                            () => widget.onModificar(cuadrilla),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          size: 20,
                                        ),
                                        tooltip: 'Ver',
                                        onPressed:
                                            () => widget.onVerMantenimientos(
                                              cuadrilla,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                        ),
                                        tooltip: 'Eliminar',
                                        onPressed: () {}, // TODO: implementar
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Líder de cuadrilla
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: AppColors.iconBlue,
                                    size: 20,
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
                                      leader != null && leader.name.isNotEmpty
                                          ? leader.name[0]
                                          : '?',
                                      style: AppTextStyles.body(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    leader != null
                                        ? leader.name
                                        : 'Nombre líder',
                                    style: AppTextStyles.body(),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CI: ${leader?.ci ?? '--------'}',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                      Text(
                                        '📞 ${leader?.phone ?? '--------'}',
                                        style: AppTextStyles.bodySmall(),
                                      ),
                                      Text(
                                        leader?.email ?? 'correo@correo.com',
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
                              // Miembros
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: AppColors.iconBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Miembros (${miembros.length})',
                                    style: AppTextStyles.bodySmall(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 110,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: miembros.length,
                                  itemBuilder: (context, idx) {
                                    final miembro = miembros[idx];
                                    return Card(
                                      color: AppColors.secondaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.iconBlue,
                                          child: Text(
                                            miembro.name.isNotEmpty
                                                ? miembro.name[0]
                                                : '?',
                                            style: AppTextStyles.body(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          miembro.name,
                                          style: AppTextStyles.body(),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${miembro.speciality ?? ''} • CI: ${miembro.ci ?? ''}',
                                              style: AppTextStyles.bodySmall(),
                                            ),
                                          ],
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 2,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: OutlinedButton.icon(
                                  onPressed:
                                      () {}, // TODO: implementar agregar miembro
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppColors.iconBlue,
                                  ),
                                  label: const Text('Agregar Miembro'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.iconBlue,
                                    side: const BorderSide(
                                      color: AppColors.iconBlue,
                                    ),
                                    textStyle: AppTextStyles.bodySmall(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Mantenimientos y ubicación
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '$pendientes',
                                        style: AppTextStyles.sectionTitle(
                                          color: AppColors.primaryBlue,
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
                                        '$completados',
                                        style: AppTextStyles.sectionTitle(
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
                                        Icons.location_on_outlined,
                                        color: AppColors.iconBlue,
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Text(
                                          ubicacion,
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
                                  ElevatedButton.icon(
                                    onPressed:
                                        () => widget.onVerMantenimientos(
                                          cuadrilla,
                                        ),
                                    icon: const Icon(Icons.list_alt, size: 18),
                                    label: const Text("Ver Mantenimientos"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.botonBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      textStyle: AppTextStyles.button(),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed:
                                        () => widget.onModificar(cuadrilla),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Modificar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.iconBlue,
                                      side: const BorderSide(
                                        color: AppColors.iconBlue,
                                      ),
                                      textStyle: AppTextStyles.button(),
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
