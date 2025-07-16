import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:frontend/Screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  group('LoginScreen UI', () {
    testWidgets('Muestra los campos de correo y contraseña', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      expect(find.text('Correo'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('Muestra el botón Entrar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      expect(find.text('Entrar'), findsOneWidget);
    });
  });

  group('LoginScreen lógica de validación', () {
    late LoginScreenState state;
    setUp(() {
      state = LoginScreen().createState() as LoginScreenState;
    });

    test('Valida email incorrecto', () {
      final result = state.validateCredentials('correo', '123456');
      expect(result, 'Por favor ingresa un correo electrónico válido.');
    });

    test('Valida contraseña corta', () {
      final result = state.validateCredentials('test@mail.com', '123');
      expect(result, 'La contraseña debe tener al menos 6 caracteres.');
    });

    test('Valida credenciales correctas', () {
      final result = state.validateCredentials('test@mail.com', '123456');
      expect(result, null);
    });
  });

  group('LoginScreen errores de autenticación', () {
    late LoginScreenState state;
    setUp(() {
      state = LoginScreen().createState() as LoginScreenState;
    });

    test('Error de credenciales inválidas', () {
      final msg = state.mapAuthError('Invalid login credentials');
      expect(msg, contains('Credenciales inválidas'));
    });
    test('Error de usuario no encontrado', () {
      final msg = state.mapAuthError('User not found');
      expect(msg, contains('Usuario no encontrado'));
    });
    test('Error de correo no confirmado', () {
      final msg = state.mapAuthError('Email not confirmed');
      expect(msg, contains('Correo no confirmado'));
    });
    test('Error de demasiados intentos', () {
      final msg = state.mapAuthError('Too many requests');
      expect(msg, contains('Demasiados intentos'));
    });
    test('Error de red', () {
      final msg = state.mapAuthError('Network error');
      expect(msg, contains('No se pudo conectar'));
    });
    test('Error desconocido', () {
      final msg = state.mapAuthError(null);
      expect(msg, contains('Error desconocido'));
    });
  });
}
