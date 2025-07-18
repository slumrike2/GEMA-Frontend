import 'package:flutter/material.dart';
import 'package:frontend/Screens/initial_register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Screens/login_screen.dart';
import 'Screens/admin_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Punto de entrada principal de la aplicación.
///
/// Inicializa Supabase con la URL y la clave anónima,
/// y lanza la aplicación con la clase [MainApp].
void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de ejecutar código asíncrono
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Inicializa Supabase con la URL y la clave pública (anonKey)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
    final initialRoute =
        Supabase.instance.client.auth.currentSession != null
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
        InitialRegisterScreen.routeName:
            (context) => const InitialRegisterScreen(),
      },
    );
  }
}
