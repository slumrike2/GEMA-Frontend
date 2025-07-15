import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  

class UserService {
  static const String baseUrl = 'http://localhost:3000/api/users';

  static Future<AuthResponse> signUpUser(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  static Future<List<User>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener usuarios: \\${response.statusCode}');
    }
  }

  static Future<User> getById(String uuid) async {
    final response = await http.get(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener usuario: \\${response.statusCode}');
    }
  }

  static Future<void> create( 
  {
    required String email,
    required String password,
    required String role
  }) async {
    final uuidResponse = await signUpUser(email, password);
    final uuid = uuidResponse.user?.id;
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uuid': uuid,
        'email': email,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      print('Usuario creado en backend');
    } else {
      print('Error al crear usuario en backend: ${response.body}');
    }
  }

  static Future<void> update(String uuid, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$uuid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario: \\${response.statusCode}');
    }
  }

  static Future<void> delete(String uuid) async {
    final response = await http.delete(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar usuario: \\${response.statusCode}');
    }
  }
}
