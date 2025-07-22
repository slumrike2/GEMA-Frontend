import 'package:flutter/material.dart';
import 'package:frontend/constants/app_constnats.dart';
import '../Modals/create_user_modal.dart';
import '../Services/user_service.dart';
import '../Models/backend_types.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(child: UserManager()),
      ),
    );
  }
}

class UserManager extends StatefulWidget {
  @override
  State<UserManager> createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  List<User> users = [];
  bool isLoading = false;
  String? errorText;
  int selectedTab = 0;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });
    try {
      users = await UserService.getAll();
    } catch (e) {
      errorText = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addUser(String email, String role) async {
    setState(() {
      errorText = null;
    });
    try {
      await UserService.create(email: email, role: role);
      await _fetchUsers();
    } catch (e) {
      setState(() {
        errorText = e.toString();
      });
    }
  }

  Future<void> _updateUser(User user) async {
    setState(() {
      errorText = null;
    });
    try {
      await UserService.update(user.uuid ?? '', user.toJson());
      await _fetchUsers();
    } catch (e) {
      setState(() {
        errorText = e.toString();
      });
    }
  }

  Future<void> _deleteUser(int index) async {
    final user = users[index];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Seguro que deseas eliminar el usuario "${user.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    await UserService.delete(user.uuid ?? '');
                    await _fetchUsers();
                  } catch (e) {
                    setState(() {
                      errorText = e.toString();
                    });
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _startEditUser(int index) {
    final user = users[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => FutureBuilder<User>(
            future: UserService.getById(user.uuid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text('No se pudo cargar el usuario.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                );
              }
              final fullUser = snapshot.data!;
              final fullHasName =
                  (fullUser.name != null && fullUser.name!.trim().isNotEmpty);
              return CreateUserModal(
                onCreate: (email, role, {String? name}) {
                  final updatedUser = User(
                    uuid: fullUser.uuid,
                    name:
                        fullHasName
                            ? (name ?? fullUser.name ?? '')
                            : (fullUser.name ?? ''),
                    email: email,
                    role: UserRole.values.byName(role),
                    updatedAt: null,
                    createdAt: null,
                    deletedAt: null,
                  );
                  _updateUser(updatedUser);
                },
                isEdit: fullHasName,
                initialEmail: fullUser.email,
                initialRole: fullUser.role?.name,
                initialName: fullHasName ? fullUser.name : null,
              );
            },
          ),
    );
  }

  List<User> get filteredUsers {
    List<User> baseList;
    if (selectedTab == 1) {
      baseList =
          users
              .where(
                (u) =>
                    (u.name ?? '').trim().isNotEmpty &&
                    (u.name ?? '').toLowerCase() != 'no registrado',
              )
              .toList();
    } else if (selectedTab == 2) {
      baseList =
          users
              .where(
                (u) =>
                    (u.name ?? '').trim().isEmpty ||
                    (u.name ?? '').toLowerCase() == 'no registrado',
              )
              .toList();
    } else {
      baseList = users;
    }
    if (searchText.trim().isEmpty) return baseList;
    final query = searchText.trim().toLowerCase();
    return baseList.where((u) {
      final name = (u.name ?? '').toLowerCase();
      final email = u.email.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Widget _buildTab(String label, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton(
        onPressed: () {
          setState(() => selectedTab = index);
        },
        style: TextButton.styleFrom(
          foregroundColor:
              selectedTab == index
                  ? AppColors.primaryGreen
                  : AppColors.onSurface,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Usuarios',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 24,
                  color: AppColors.primaryGreen,
                ),
                tooltip: 'Refrescar',
                onPressed: isLoading ? null : _fetchUsers,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.person_add, size: 20, color: Colors.white),
                  label: Text(
                    'Agregar usuario',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.botonGreen,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => CreateUserModal(
                            onCreate: (email, role, {String? name}) {
                              _addUser(email, role);
                            },
                            initialEmail: '',
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buscador
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar usuarios o equipos...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          // Tabs
          Row(
            children: [
              _buildTab('Todos', 0),
              _buildTab('Registrados', 1),
              _buildTab('Pendientes', 2),
            ],
          ),
          const SizedBox(height: 8),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(errorText!, style: TextStyle(color: Colors.red)),
            ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                    ? const Center(child: Text('No hay usuarios registrados.'))
                    : ListView.separated(
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, i) {
                        final user = filteredUsers[i];
                        final userName = (user.name ?? '').trim();
                        final userEmail = user.email;
                        final userRole =
                            user.role?.name == 'admin' ? 'Admin' : 'Usuario';
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.secondaryGreen,
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            (userName.isNotEmpty
                                                    ? userName
                                                    : 'No registrado') +
                                                ' · Rol: $userRole',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  userName.isNotEmpty
                                                      ? Colors.black
                                                      : Colors.red,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                userName.isNotEmpty
                                                    ? AppColors.secondaryGreen
                                                    : AppColors.secondaryYellow,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            userName.isNotEmpty
                                                ? 'Registrado'
                                                : 'Pendiente',
                                            style: TextStyle(
                                              color:
                                                  userName.isNotEmpty
                                                      ? AppColors.primaryGreen
                                                      : AppColors.primaryYellow,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      userEmail,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  userName.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: AppColors.primaryBlue,
                                        ),
                                        tooltip: 'Editar',
                                        onPressed: () => _startEditUser(i),
                                      )
                                      : Container(),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _deleteUser(i),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
