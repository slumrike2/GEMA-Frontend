import 'package:flutter/material.dart';
import 'package:frontend/Components/sidebar.dart';

class CuadrillasScreen extends StatelessWidget {
  const CuadrillasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedIndex: 2),
          Expanded(
            child: Center(
              child: Text(
                'Cuadrillas',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}