import 'package:flutter/material.dart';
import '../Components/sidebar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedPage,
            onItemSelected: (index) {
              setState(() {
                _selectedPage = index;
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedPage,
              children: const [
                _PageMantenimientos(),
                _PageEquiposUbicaciones(),
                _PageCuadrillas(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageMantenimientos extends StatelessWidget {
  const _PageMantenimientos();
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

class _PageEquiposUbicaciones extends StatelessWidget {
  const _PageEquiposUbicaciones();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Equipos y Ubicaciones',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class _PageCuadrillas extends StatelessWidget {
  const _PageCuadrillas();
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
