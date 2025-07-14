import 'package:flutter/material.dart';
import '../modals/create_user_modal.dart';
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
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: UserManager(),
        ),
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

  Future<void> _addUser(String name, String email, String password) async {
    setState(() {
      errorText = null;
    });
    try {
      await UserService.create({
        'name': name,
        'email': email,
        'password': password,
      });
      await _fetchUsers();
    } catch (e) {
      setState(() {
        errorText = e.toString();
      });
    }
  }

  Future<void> _updateUser(
    User user,
    String name,
    String email,
    String password,
  ) async {
    setState(() {
      errorText = null;
    });
    try {
      await UserService.update(user.uuid ?? '', {
        'name': name,
        'email': email,
        'password': password,
      });
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
      builder:
          (context) => CreateUserModal(
            onCreate: (name, email, password) {
              _updateUser(user, name, email, password);
            },
            initialUsername: user.name,
            initialEmail: user.email,
            initialPassword: '',
            isEdit: true,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usuarios',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                  : users.isEmpty
                  ? const Center(child: Text('No hay usuarios registrados.'))
                  : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                          ),
                          radius: 32,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar',
                              onPressed: () => _startEditUser(i),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar',
                              onPressed: () => _deleteUser(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                icon: Icon(Icons.person_add, size: 28),
                label: Text('Agregar usuario', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => CreateUserModal(
                          onCreate: (username, email, password) {
                            _addUser(username, email, password);
                          },
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
