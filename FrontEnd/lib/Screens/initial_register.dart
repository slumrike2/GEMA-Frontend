import 'package:flutter/material.dart';

class InitialRegisterScreen extends StatefulWidget {
  const InitialRegisterScreen({super.key});

  static const String routeName = '/initial-register';

  @override
  State<InitialRegisterScreen> createState() => _InitialRegisterScreenState();
}

class _InitialRegisterScreenState extends State<InitialRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordVerifyController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(122, 252, 198, 48),
              Color.fromARGB(122, 55, 180, 227),
              Color.fromARGB(122, 0, 121, 52),
            ],
          ),
        ),
        child: SizedBox.expand(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60),
                      Icon(Icons.person, size: 100, color: Colors.blue),
                      const SizedBox(height: 24),
                      const Text(
                        'Completa tu registro',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingresa tu nombre y crea una nueva contraseña para activar tu cuenta.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 53, 53, 53),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nueva contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordVerifyController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Verifica la contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor verifica la contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              child: const Text(
                                'Guardar',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // Aquí deberías llamar a tu servicio para actualizar el nombre y la contraseña del usuario actual
    // Ejemplo:
    // try {
    //   await UserService.updateCurrentUser(
    //     name: _nameController.text.trim(),
    //     password: _passwordController.text.trim(),
    //   );
    //   Navigator.pushReplacementNamed(context, '/admin');
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    //   );
    // } finally {
    //   setState(() => _loading = false);
    // }
    await Future.delayed(const Duration(seconds: 1)); // Simulación
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/admin');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _passwordVerifyController.dispose();
    super.dispose();
  }
}
