import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Screens/login_screen.dart';
import 'Screens/admin_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Punto de entrada principal de la aplicación.
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Carga las variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");


  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MainApp());
}

/// Widget raíz de la aplicación.
///
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasSession = Supabase.instance.client.auth.currentSession != null;

    final initialRoute = hasSession ? AdminScreen.routeName : LoginScreen.routeName;


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        AdminScreen.routeName: (context) => const AdminScreen(),
      },
    );
  }
}
