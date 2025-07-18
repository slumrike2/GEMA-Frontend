import 'package:flutter/material.dart';
import 'package:frontend/Screens/users_screen.dart';
import 'package:frontend/Services/user_service.dart';
import 'package:frontend/Models/backend_types.dart';
import 'package:frontend/constants/app_constnats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/Screens/equipos_ubicaciones_screen.dart';

// import 'mantenimientos_screen.dart'; // Mantenimientos oculto
import 'cuadrillas_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const String routeName = '/admin';
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int selectedIndex = 0;
  bool showUsersScreen = false;
  bool loadingUser = true;

  final List<IconData> _navIcons = [
    // Icons.build, // Mantenimientos
    Icons.devices,
    Icons.group,
    Icons.person,
  ];
  final List<String> _navLabels = [
    // 'Mantenimientos',
    'Equipos y Ubicaciones',
    'Cuadrillas',
    'Usuarios',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserRole();
  }

  Future<void> _fetchCurrentUserRole() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final uuid = session?.user.id;
      if (uuid != null) {
        // Asume que tienes UserService.getById disponible
        final user = await UserService.getById(uuid);
        setState(() {
          showUsersScreen = user.role != UserRole.user;
          loadingUser = false;
        });
      } else {
        setState(() {
          showUsersScreen = false;
          loadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        showUsersScreen = false;
        loadingUser = false;
      });
    }
  }

  void _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> navColors = [
      // primaryYellow, // Mantenimientos
      AppColors.primaryGreen,
      AppColors.primaryBlue,
      AppColors.primaryGray,
    ];
    List<Image> navIcons = [
      // Image.asset('assets/images/IconMantenimientos.png'),
      Image.asset('assets/images/IconEquiposUbicaciones.png'),
      Image.asset('assets/images/IconCuadrillas.png'),
      Image.asset(
        'assets/images/IconMantenimientos.png',
      ), // Si quieres ocultar también esta imagen, comenta esta línea
    ];

    if (loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si el usuario es "user", ocultar el botón y la pantalla de UsersScreen
    final navIconsFiltered =
        showUsersScreen ? _navIcons : _navIcons.sublist(0, 2);
    final navLabelsFiltered =
        showUsersScreen ? _navLabels : _navLabels.sublist(0, 2);
    final navImagesFiltered =
        showUsersScreen ? navIcons : navIcons.sublist(0, 2);
    final screensFiltered =
        showUsersScreen
            ? [
              // const MantenimientosScreen(),
              const EquiposUbicacionesScreen(),
              const CuadrillasScreen(),
              const UsersScreen(),
            ]
            : [
              // const MantenimientosScreen(),
              const EquiposUbicacionesScreen(),
              const CuadrillasScreen(),
            ];

    // Ajustar selectedIndex si es necesario
    final safeSelectedIndex =
        selectedIndex >= screensFiltered.length ? 0 : selectedIndex;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: 200,
            selectedIndex: safeSelectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            backgroundColor: navColors[safeSelectedIndex],
            leading: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  navImagesFiltered[safeSelectedIndex],
                  const SizedBox(height: 8),
                  const Text(
                    'Panel',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                tooltip: 'Cerrar sesión',
                onPressed: _handleLogout,
              ),
            ),
            destinations: List.generate(
              navIconsFiltered.length,
              (i) => NavigationRailDestination(
                icon: Icon(navIconsFiltered[i], color: Colors.white),
                selectedIcon: Icon(navIconsFiltered[i], color: Colors.black),
                label: Text(
                  navLabelsFiltered[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        i == safeSelectedIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
            ),
            selectedIconTheme: const IconThemeData(
              color: Colors.black,
              size: 28,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Colors.white,
              size: 28,
            ),
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: IndexedStack(
              index: safeSelectedIndex,
              children: screensFiltered,
            ),
          ),
        ],
      ),
    );
  }
}
