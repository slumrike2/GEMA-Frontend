import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Components/action_button.dart';

/// Pantalla de inicio de sesión para la aplicación GEMA.
///
/// Permite al usuario ingresar su correo y contraseña para autenticarse
/// mediante Supabase Auth. Muestra mensajes de error en caso de fallo y
/// redirige a la pantalla de administración si el login es exitoso.
class LoginScreen extends StatefulWidget {
  /// Ruta estática para navegación con [Navigator].
  static const routeName = '/login';

  /// Crea una instancia constante de [LoginScreen].
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Controlador para el campo de correo electrónico.
  final _emailController = TextEditingController();

  /// Controlador para el campo de contraseña.
  final _passwordController = TextEditingController();

  /// Indica si la aplicación está procesando el login (mostrar spinner).
  bool _loading = false;

  /// Maneja el proceso de inicio de sesión usando Supabase Auth.
  ///
  /// Obtiene los valores de email y password, los envía a Supabase para autenticación,
  /// maneja errores específicos y redirige a la pantalla de administración si es exitoso.
  Future<void> _handleLogin() async {
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session != null) {
        // Login exitoso: navegar a pantalla admin.
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin');
        }
      } else {
        // Login fallido: lanzar excepción para mostrar error.
        throw Exception(response.user == null
            ? 'Usuario no encontrado.'
            : 'Credenciales incorrectas.');
      }
    } on AuthException catch (e) {
      // Error específico de autenticación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      // Error inesperado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
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
        child: SizedBox.expand(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/images/IconLogin.png',
                      height: 100,
                    ),
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