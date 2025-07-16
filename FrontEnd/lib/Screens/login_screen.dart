import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/Screens/initial_register.dart';
import 'package:frontend/Services/user_service.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Components/action_button.dart';

/// ------------------------------------------------------------
/// Pantalla de Login: LoginScreen
/// ------------------------------------------------------------
/// Descripción:
/// - Interfaz para que los usuarios inicien sesión.
/// - Valida credenciales localmente (correo, contraseña).
/// - Integra autenticación mediante Supabase.
/// - Maneja errores y muestra feedback visual.
///
/// Funcionalidad:
/// - Si el login es exitoso → Navega a '/admin'.
/// - Si el login falla o la validación local no es válida →
///   Muestra modal inferior con mensaje.
///
/// Parámetros opcionales:
/// - injectedClient: Permite inyectar un SupabaseClient mock para pruebas.
///
/// Autor: Juan Quijada
/// Fecha: Julio 2025
/// ------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  final SupabaseClient? injectedClient;

  const LoginScreen({super.key, this.injectedClient});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _checkUserStatus() async {
    try {
      final supabase = widget.injectedClient ?? Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _showErrorModal('No hay usuario autenticado.');
        return;
      }
      final uuid = currentUser.id;
      final user = await UserService.getById(uuid);
      final hasName = user.name != null;
      if (!mounted) return;
      if (hasName) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(
          context,
          InitialRegisterScreen.routeName,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorModal('Error al verificar usuario: $e');
      }
    }
  }

  /// Método principal de login.
  /// - Realiza validación local.
  /// - Llama a Supabase para autenticar.
  /// - Muestra mensajes de error o navega según el caso.
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final validationMessage = _validateCredentials(email, password);
    if (validationMessage != null) {
      _showErrorModal(validationMessage);
      return;
    }

    setState(() => _loading = true);
    try {
      final supabase = widget.injectedClient ?? Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _checkUserStatus();
    } on AuthException catch (e) {
      if (mounted) {
        final errorMessage = _mapAuthError(e.message);
        _showErrorModal(errorMessage);
      }
    } on SocketException {
      if (mounted) {
        _showErrorModal(
          'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
        );
      }
    } on ClientException {
      if (mounted) {
        _showErrorModal('Error de cliente. Por favor intenta más tarde.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorModal('Error inesperado: $e');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Validación local de las credenciales antes de llamar a Supabase.
  /// Devuelve un mensaje de error si es inválido, o null si es válido.
  String? _validateCredentials(String email, String password) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      return 'Por favor ingresa un correo electrónico válido.';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  /// Mapea errores de Supabase a mensajes entendibles para el usuario final.
  String _mapAuthError(String? error) {
    if (error == null) return 'Error desconocido.';

    final msg = error.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'Credenciales inválidas. Verifica tu correo y contraseña.';
    }
    if (msg.contains('user not found')) {
      return 'Usuario no encontrado. Por favor verifica el correo.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Correo no confirmado. Revisa tu email para activar la cuenta.';
    }
    if (msg.contains('too many requests')) {
      return 'Demasiados intentos. Por favor intenta más tarde.';
    }
    if (msg.contains('password strength')) {
      return 'La contraseña no cumple con los requisitos de seguridad.';
    }
    if (msg.contains('network error') || msg.contains('failed to connect')) {
      return 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
    }
    return 'Error: $error';
  }

  /// Muestra un modal tipo BottomSheet con el mensaje de error.
  void _showErrorModal(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la interfaz de la pantalla de login.
  /// Incluye:
  /// - Logo.
  /// - Inputs de correo y contraseña.
  /// - Botón de login con spinner si está cargando.
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),
                    Image.asset('assets/images/IconLogin.png', height: 100),
                    const SizedBox(height: 24),
                    const Text(
                      'Bienvenido a GEMA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 53, 53, 53),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                          width: double.infinity,
                          child: ActionButton(
                            icon: Icons.login,
                            label: 'Entrar',
                            backgroundColor: Colors.blue,
                            onPressed: _handleLogin,
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
    );
  }
}
