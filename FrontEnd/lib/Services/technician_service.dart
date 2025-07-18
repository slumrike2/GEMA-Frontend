import 'dart:convert';
import 'package:http/http.dart' as http;

class TechnicianService {
  static const String baseUrl = 'http://localhost:3000/api/technicians';

  // Crear técnico
  static Future<void> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode >= 400) {
      throw Exception('Error al crear técnico: ${response.body}');
    }
  }

  // Actualizar técnico
  static Future<void> update(String uuid, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$uuid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode >= 400) {
      throw Exception('Error al actualizar técnico: ${response.body}');
    }
  }

  // Eliminar técnico
  static Future<void> delete(String uuid) async {
    final response = await http.delete(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode >= 400) {
      throw Exception('Error al eliminar técnico: ${response.body}');
    }
  }

  // Obtener todos los técnicos existentes
  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener técnicos: ${response.body}');
    }
  }

  // Obtener todos los usuarios disponibles para ser técnicos (que tengan correo y nombre)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);

      // Filtrar solo los que tienen tanto nombre como correo
      final List<Map<String, dynamic>> filtered = body
          .where((user) =>
              user is Map<String, dynamic> &&
              (user['name']?.toString().trim().isNotEmpty ?? false) &&
              (user['email']?.toString().trim().isNotEmpty ?? false))
          .map<Map<String, dynamic>>((user) {
        // Completar datos faltantes como cédula si se puede inferir o dejar en blanco
        return {
          'uuid': user['uuid'] ?? '',
          'name': user['name'],
          'email': user['email'],
          'personalId': user['personalId'] ?? '', // completar si está disponible
        };
      }).toList();

      return filtered;
    } else {
      throw Exception('Error al obtener usuarios: ${response.body}');
    }
  }

}