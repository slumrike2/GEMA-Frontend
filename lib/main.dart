import 'package:flutter/material.dart';
import 'package:frontend/Pages/equipos&ubicaciones/crear_equipo.dart';
import 'Screens/admin_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminScreen(),
      routes: {
        AdminScreen.routeName: (context) =>  AdminScreen(),

      },
    );
  }
}
