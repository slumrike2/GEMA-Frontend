import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Screens/login_screen.dart';
import 'Screens/admin_screen.dart';

/// Punto de entrada principal de la aplicación.
///
/// Inicializa Supabase con la URL y la clave anónima,
/// y lanza la aplicación con la clase [MainApp].
void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de ejecutar código asíncrono
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase con la URL y la clave pública (anonKey)
  await Supabase.initialize(
    url: 'https://qxvbydzewskwmywzdnvi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4dmJ5ZHpld3Nrd215d3pkbnZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4ODI3MTIsImV4cCI6MjA2NjQ1ODcxMn0.tEGoee-SE1VRse7MJbTjCN31-KeD2p3quxFz7eGYPMI',
  );

  // Ejecuta la aplicación Flutter con la clase MainApp
  runApp(const MainApp());
}

/// Widget raíz de la aplicación.
///
/// Define las rutas principales y determina la pantalla inicial en base
/// al estado de la sesión actual de Supabase Auth.
class MainApp extends StatelessWidget {
  /// Constructor constante para el widget principal.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Comprueba si hay una sesión activa para definir la pantalla inicial
    final initialRoute = Supabase.instance.client.auth.currentSession != null
        ? AdminScreen.routeName
        : LoginScreen.routeName;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        // Ruta para la pantalla de login
        LoginScreen.routeName: (context) => const LoginScreen(),

        // Ruta para la pantalla de administración
        AdminScreen.routeName: (context) => const AdminScreen(),
      },
    );
  }
}