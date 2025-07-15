import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/Screens/admin_screen.dart';

/// ------------------------------------------------------------
/// Pruebas unitarias de AdminScreen: Logout funcional
/// Autor: Juan Quijada
/// Fecha: Julio 2025
///
/// Descripción general:
/// Este archivo contiene pruebas automatizadas para validar el
/// comportamiento de AdminScreen específicamente en el flujo de logout:
///
/// 1. Verificar que al presionar el botón de "Cerrar sesión" se llama
///    correctamente al método signOut() de Supabase.
/// 2. Verificar que luego de cerrar sesión se redirige a la ruta '/login'.
///
/// Tecnologías utilizadas:
/// - Flutter Test
/// - Mocktail para mocking de SupabaseClient y GoTrueClient
/// - Supabase Flutter SDK
/// ------------------------------------------------------------

/// Mock de SupabaseClient para inyección.
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock de GoTrueClient.
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  /// Configuración previa a cada prueba, inicializa los mocks.
  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    // Se simula que auth del cliente devuelve el mock de GoTrueClient.
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    // Se simula que signOut no genera error y se completa exitosamente.
    when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});
  });

  /// Test: Logout exitoso redirige a /login
  ///
  /// Objetivo:
  /// 1. Simular que el usuario hace tap sobre el botón de cerrar sesión.
  /// 2. Verificar que se llama una vez a Supabase.auth.signOut().
  /// 3. Verificar que luego de cerrar sesión se navega a la pantalla '/login'.
  testWidgets('Logout desde AdminScreen redirige a /login', (tester) async {
    await tester.pumpWidget(MaterialApp(
      routes: {
        '/login': (context) => const Scaffold(body: Text('Pantalla Login')),
      },
      home: AdminScreen(injectedClient: mockSupabaseClient),
    ));

    // Toca el botón de logout identificado por su tooltip.
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    // Verifica que se llamó a signOut una sola vez.
    verify(() => mockGoTrueClient.signOut()).called(1);

    // Verifica que la pantalla actual sea la de login.
    expect(find.text('Pantalla Login'), findsOneWidget);
  });
}