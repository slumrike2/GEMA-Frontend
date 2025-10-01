import 'package:flutter/material.dart';
import 'package:frontend/Services/technician_service.dart';
import 'package:frontend/Services/technical_team_service.dart';
import 'package:frontend/Services/user_service.dart';

class AddTeamMembersModal extends StatefulWidget {
  const AddTeamMembersModal({super.key});

  @override
  State<AddTeamMembersModal> createState() => _AddTeamMembersModalState();
}

class _SelectableTechnician {
  final String uuid;
  final String personalId;
  final String speciality;
  String? name;
  String? role;
  String? email;
  bool selected = false;

  _SelectableTechnician({
    required this.uuid,
    required this.personalId,
    required this.speciality,
    this.name,
    this.email,
  });
}

class _AddTeamMembersModalState extends State<AddTeamMembersModal> {
  bool _loading = true;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _listCtrl = ScrollController();
  List<_SelectableTechnician> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // 1) Obtener vista combinada (técnico + usuario)
      final techUser = await TechnicianService.getTechnicianUserView();
      // 2) Obtener equipos para calcular líderes
      final teams = await TechnicalTeamService.getAll();
      final leaderIds =
          teams
              .map((t) => t.leaderId)
              .where((id) => id != null && id.isNotEmpty)
              .cast<String>()
              .toSet();

      // 3) Filtrar sin equipo y no líderes
      final filtered =
          techUser
              .where(
                (t) =>
                    t.technicalTeamId == null && !leaderIds.contains(t.userId),
              )
              .toList();

      // 4) Mapear a seleccionables con nombre/email de la vista
      final items =
          filtered
              .map(
                (t) => _SelectableTechnician(
                  uuid: t.userId,
                  personalId: t.personalId,
                  speciality: t.speciality,
                  name: t.userName,
                  email: t.userEmail,
                ),
              )
              .toList();

      // 5) Enriquecer con role (y validar nombre/email) desde UserService.getById
      await Future.wait(
        items.map((it) async {
          try {
            final user = await UserService.getById(it.uuid);
            it.name = user.name ?? it.name;
            it.role = user.role?.name ?? it.role;
            it.email = user.email.isNotEmpty ? user.email : it.email;
          } catch (_) {
            // Ignorar errores individuales
          }
        }),
      );

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar técnicos: $e')));
    }
  }

  List<_SelectableTechnician> get _filtered {
    if (_query.trim().isEmpty) return _items;
    final q = _query.toLowerCase();
    return _items.where((it) {
      final name = (it.name ?? '').toLowerCase();
      final email = (it.email ?? '').toLowerCase();
      final ci = it.personalId.toLowerCase();
      final spec = it.speciality.toLowerCase();
      return name.contains(q) ||
          email.contains(q) ||
          ci.contains(q) ||
          spec.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Miembros'),
      content: SizedBox(
        width: 500,
        child:
            _loading
                ? const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Buscar técnico',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: Scrollbar(
                        controller: _listCtrl,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _listCtrl,
                          primary: false,
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final it = _filtered[i];
                            return CheckboxListTile(
                              value: it.selected,
                              onChanged:
                                  (val) => setState(
                                    () => it.selected = val ?? false,
                                  ),
                              title: Text(
                                it.name == null || it.name!.isEmpty
                                    ? 'Sin nombre'
                                    : it.name!,
                              ),
                              subtitle: Text(
                                '${it.email ?? 'Sin correo'} • CI: ${it.personalId} • ${it.speciality}',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              _loading
                  ? null
                  : () {
                    final selected =
                        _items
                            .where((it) => it.selected)
                            .map((e) => e.uuid)
                            .toList();
                    Navigator.of(context).pop<List<String>>(selected);
                  },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
