import 'package:flutter/material.dart';

class MantenimientosScreen extends StatelessWidget {
  const MantenimientosScreen({super.key});
  static const String routeName = '/mantenimientos';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Bienvenido, Administrador1',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
      ),
    );
  }
}
