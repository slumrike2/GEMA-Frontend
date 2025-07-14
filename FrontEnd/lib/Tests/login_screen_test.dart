import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/Screens/login_screen.dart';

/// ------------------------------------------------------------
/// Pruebas unitarias de la pantalla LoginScreen con Supabase
/// Autor: Juan Quijada
/// Fecha: Julio 2025
///
/// Descripción general:
/// Este archivo contiene pruebas automatizadas para validar el
/// comportamiento de LoginScreen en tres escenarios:
/// 1. Login exitoso con navegación.
/// 2. Validación previa de email/contraseña.
/// 3. Login fallido con mensaje de error.
///
/// Tecnologías:
/// - Flutter Test
/// - Mocktail para mocking
/// - Supabase Flutter SDK
/// ------------------------------------------------------------

/// Mock de SupabaseClient para inyección de dependencias.
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock de GoTrueClient (parte de Supabase.auth).
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Mock de AuthResponse que devuelve Supabase al iniciar sesión.
class MockAuthResponse extends Mock implements AuthResponse {}

/// Mock de Session (parte de AuthResponse).
class MockSession extends Mock implements Session {}

void main() {
  // Variables comunes entre los tests.
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockAuthResponse mockAuthResponse;
  late MockSession mockSession;

  /// Configuración previa a cada test (mocks listos).
  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockAuthResponse = MockAuthResponse();
    mockSession = MockSession();

    // Relaciona el cliente de autenticación con el cliente Supabase mockeado.
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockAuthResponse.session).thenReturn(mockSession);
    when(() => mockAuthResponse.user).thenReturn(null);
  });

  /// Test 1: Login exitoso navega a /admin
  ///
  /// Objetivo:
  /// Verificar que al realizar un login correcto,
  /// se redirige automáticamente a la pantalla de administración.
  testWidgets('Login exitoso navega a /admin', (tester) async {
    // Configura la respuesta mock de signInWithPassword.
    when(() => mockGoTrueClient.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);

    // Renderiza el LoginScreen con el cliente mock inyectado.
    await tester.pumpWidget(MaterialApp(
      routes: {
        '/admin': (context) => const Scaffold(body: Text('Pantalla Admin')),
      },
      home: LoginScreen(injectedClient: mockSupabaseClient),
    ));

    // Simula ingreso de credenciales válidas.
    await tester.enterText(find.byType(TextField).at(0), 'admin@gema.com');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');

    // Simula tap en el botón 'Entrar'.
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Verificación: Se muestra la pantalla admin.
    expect(find.text('Pantalla Admin'), findsOneWidget);
  });

  /// Test 2: Login con validación previa muestra error
  ///
  /// Objetivo:
  /// Validar que si el correo o contraseña no cumplen con
  /// las reglas locales de validación, se muestre el error correspondiente
  /// sin llegar a llamar a Supabase.
  testWidgets('Login con validación previa muestra error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'correo_invalido');
    await tester.enterText(find.byType(TextField).at(1), '123');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Verificación: Modal con mensaje de validación.
    expect(find.textContaining('Por favor ingresa un correo electrónico válido'), findsOneWidget);
  });

  /// Test 3: Login fallido muestra modal con error
  ///
  /// Objetivo:
  /// Simular un fallo de autenticación en Supabase y verificar
  /// que el modal con mensaje de error se muestra correctamente.
  testWidgets('Login fallido muestra modal con error', (tester) async {
    when(() => mockGoTrueClient.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('Invalid login credentials'));

    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(injectedClient: mockSupabaseClient),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'test@gema.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Verificación: Modal con mensaje de error traducido.
    expect(find.textContaining('Credenciales inválidas'), findsOneWidget);
  });
}