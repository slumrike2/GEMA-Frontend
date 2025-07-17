import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';
import '../Models/backend_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class UserService {
  static const String baseUrl = 'http://localhost:3000/api/users';

  // Método para registrar usuario en Supabase
  static Future<AuthResponse> signUpUser(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Obtener todos los usuarios
  static Future<List<User>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener usuarios: ${response.statusCode}');
    }
  }

  // Obtener usuarios disponibles que tengan nombre y correo
  static Future<List<User>> getAvailableUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/available'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => User.fromJson(e))
          .where((user) =>
              (user.name?.trim().isNotEmpty ?? false) &&
              (user.email?.trim().isNotEmpty ?? false))
          .toList();
    } else {
      throw Exception('Error al obtener usuarios disponibles: ${response.statusCode}');
    }
  }

  // Obtener usuario por UUID
  static Future<User> getById(String uuid) async {
    final response = await http.get(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener usuario: ${response.statusCode}');
    }
  }

  // Crear usuario: recibe email y rol, genera password aleatoria y registra en Supabase y backend
  static Future<void> create({required String email, required String role}) async {
    final chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    final rand = Random.secure();
    final password = List.generate(16, (index) => chars[rand.nextInt(chars.length)]).join();

    final uuidResponse = await signUpUser(email, password);
    final uuid = uuidResponse.user?.id;

    if (uuid == null) {
      throw Exception('No se pudo registrar usuario en Supabase');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uuid': uuid,
        'email': email,
        'role': role,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear usuario en backend: ${response.body}');
    }
  }

  // Cambiar contraseña del usuario actual en Supabase
  static Future<void> changeCurrentUserPassword(String newPassword) async {
    final response = await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (response.user == null) {
      throw Exception('No se pudo cambiar la contraseña del usuario.');
    }
  }

  // Actualizar usuario en backend
  static Future<void> update(String uuid, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$uuid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario: ${response.statusCode}');
    }
  }

  // Eliminar usuario en backend
  static Future<void> delete(String uuid) async {
    final response = await http.delete(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario: ${response.statusCode}');
    }
  }
}
