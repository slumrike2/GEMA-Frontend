import 'package:flutter/material.dart';
import '../Services/user_service.dart';
import '../Components/action_button.dart';

/// ------------------------------------------------------------
/// Pantalla de Registro Inicial: InitialRegisterScreen
/// ------------------------------------------------------------
/// Descripción:
/// - Interfaz para registrar un nuevo usuario con rol especificado.
/// - Solicita correo electrónico y rol (usuario o administrador).
/// - Valida campos localmente antes de enviar datos al backend.
/// - Integra servicio externo para crear usuario mediante UserService.
///
/// Funcionalidad:
/// - Si el registro es exitoso → Muestra mensaje y redirige a '/login'.
/// - Si el registro falla → Muestra mensaje de error.
/// - Botón de retroceso para volver a la pantalla anterior.
///
/// Autores: Juan Quijada, Sebastián Ynojosa 
/// Fecha: Julio 2025
/// ------------------------------------------------------------

class InitialRegisterScreen extends StatefulWidget {
  static const routeName = '/initial-register';

  const InitialRegisterScreen({super.key});

  @override
  _InitialRegisterScreenState createState() => _InitialRegisterScreenState();
}

class _InitialRegisterScreenState extends State<InitialRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedRole = 'user';
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await UserService.create(
        email: _emailController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un enlace de confirmación a tu email.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 60),
                          Image.asset('assets/images/IconLogin.png', height: 100),
                          const SizedBox(height: 24),
                          const Text(
                            'Registro de Usuario',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ingresa tu email y selecciona el rol para comenzar el proceso de registro',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo.';
                              }
                              if (!RegExp(r"^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}")
                                  .hasMatch(value)) {
                                return 'Por favor ingresa un correo válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.security),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'user', child: Text('Usuario')),
                              DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ActionButton(
                                    icon: Icons.check,
                                    label: 'Continuar',
                                    backgroundColor: Colors.blue,
                                    onPressed: _registerUser,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}