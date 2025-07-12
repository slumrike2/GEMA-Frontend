import 'package:flutter/material.dart';
import 'Screens/admin_screen.dart';
import 'Screens/login_screen.dart';

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
        LoginScreen.routeName: (context) => const LoginScreen(),
      },
    );
  }
}
