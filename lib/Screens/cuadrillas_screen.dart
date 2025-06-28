import 'package:flutter/material.dart';

class CuadrillasScreen extends StatelessWidget {
  const CuadrillasScreen({super.key});

  static const String routeName = '/cuadrillas';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Cuadrillas',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
      ),
    );
  }
}
