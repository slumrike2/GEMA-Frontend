import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/Modals/create_user_modal.dart';

void main() {
  group('CreateUserModal', () {
    testWidgets('Muestra el título correcto para crear', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserModal(onCreate: (_, __, {String? name}) {}),
        ),
      );
      expect(find.text('Crear nuevo usuario'), findsOneWidget);
      expect(find.text('Guardar'), findsNothing);
      expect(find.text('Crear'), findsOneWidget);
    });

    testWidgets('Muestra el título correcto para editar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserModal(
            onCreate: (_, __, {String? name}) {},
            isEdit: true,
            initialName: 'Juan',
          ),
        ),
      );
      expect(find.text('Editar usuario'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('No muestra campo nombre si no hay nombre inicial', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserModal(
            onCreate: (_, __, {String? name}) {},
            isEdit: true,
            initialName: null,
          ),
        ),
      );
      expect(find.byType(TextFormField), findsNWidgets(1)); // Solo email
      expect(find.text('Nombre'), findsNothing);
    });

    testWidgets('Valida email requerido y formato', (
      WidgetTester tester,
    ) async {
      String? email;
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserModal(
            onCreate: (e, _, {String? name}) {
              email = e;
            },
          ),
        ),
      );
      await tester.tap(find.text('Crear'));
      await tester.pump();
      expect(find.text('Campo requerido'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'bademail');
      await tester.tap(find.text('Crear'));
      await tester.pump();
      expect(find.text('Correo inválido'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@email.com',
      );
      await tester.tap(find.text('Crear'));
      await tester.pump();
      expect(email, 'test@email.com');
    });

    testWidgets('Valida nombre requerido en edición', (
      WidgetTester tester,
    ) async {
      String? nameResult;
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserModal(
            onCreate: (_, __, {String? name}) {
              nameResult = name;
            },
            isEdit: true,
            initialName: 'Juan',
          ),
        ),
      );
      // Ingresar un email válido primero
      final nameField = find.byType(TextFormField).first;
      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'test@email.com');
      await tester.pump();
      // Limpiar el campo nombre
      await tester.enterText(nameField, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.tap(find.text('Guardar'));
      await tester.pump();
      expect(find.text('Campo requerido'), findsOneWidget);
      // Escribir un nombre válido y guardar
      await tester.enterText(nameField, 'Pedro');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.tap(find.text('Guardar'));
      await tester.pump();
      expect(nameResult, 'Pedro');
    });

    testWidgets('Cambia el rol seleccionado', (WidgetTester tester) async {
      String? role;
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserModal(
            onCreate: (_, r, {String? name}) {
              role = r;
            },
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Administrador').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@email.com',
      );
      await tester.tap(find.text('Crear'));
      await tester.pump();
      expect(role, 'admin');
    });
  });
}
