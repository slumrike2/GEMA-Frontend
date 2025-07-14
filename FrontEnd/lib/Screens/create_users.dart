import 'package:flutter/material.dart';
import '../modals/create_user_modal.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

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
  final List<Map<String, String>> users = [
    {'username': 'admin', 'email': 'admin@email.com', 'password': 'admin123'},
    {'username': 'jose', 'email': 'jose@email.com', 'password': 'jose123'},
    {'username': 'maria', 'email': 'maria@email.com', 'password': 'maria123'},
  ];
  int? editingIndex;
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final TextEditingController _editPasswordController = TextEditingController();
  String? errorText;

  void _addUser(String username, String email, String password) {
    if (users.any((u) => u['username'] == username)) {
      setState(() {
        errorText = 'El usuario ya existe.';
      });
      return;
    }
    setState(() {
      users.add({'username': username, 'email': email, 'password': password});
      errorText = null;
    });
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Seguro que deseas eliminar el usuario "${users[index]['username']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    users.removeAt(index);
                    if (editingIndex == index) {
                      editingIndex = null;
                      _editController.clear();
                      _editEmailController.clear();
                      _editPasswordController.clear();
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _startEditUser(int index) {
    showDialog(
      context: context,
      builder:
          (context) => CreateUserModal(
            onCreate: (username, email, password) {
              setState(() {
                users[index] = {
                  'username': username,
                  'email': email,
                  'password': password,
                };
              });
            },
            initialUsername: users[index]['username'] ?? '',
            initialEmail: users[index]['email'] ?? '',
            initialPassword: users[index]['password'] ?? '',
            isEdit: true,
          ),
    );
  }

  void _saveEditUser() {
    final username = _editController.text.trim();
    final email = _editEmailController.text.trim();
    final password = _editPasswordController.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'Todos los campos son obligatorios.';
      });
      return;
    }
    if (users.any(
      (u) =>
          u['username'] == username &&
          users[editingIndex!]['username'] != username,
    )) {
      setState(() {
        errorText = 'El usuario ya existe.';
      });
      return;
    }
    setState(() {
      users[editingIndex!] = {
        'username': username,
        'email': email,
        'password': password,
      };
      editingIndex = null;
      _editController.clear();
      _editEmailController.clear();
      _editPasswordController.clear();
      errorText = null;
    });
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
        Expanded(
          child:
              users.isEmpty
                  ? const Center(child: Text('No hay usuarios registrados.'))
                  : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(users[i]['username']![0].toUpperCase()),
                          radius: 32,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              users[i]['username'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              users[i]['email'] ?? '',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        // No mostrar la contraseña en la vista normal
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
