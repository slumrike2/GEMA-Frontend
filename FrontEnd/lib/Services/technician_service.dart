import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicianService {
  static const String baseUrl = 'http://localhost:3000/api/technicians';

  // Obtener todos los técnicos
  static Future<List<dynamic>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener técnicos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener técnicos: $e');
    }
  }

  // Obtener un técnico por UUID
  static Future<Map<String, dynamic>> getByUuid(String uuid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$uuid'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener el técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener el técnico: $e');
    }
  }

  // Crear un nuevo técnico
  static Future<void> create(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        throw Exception('Error al crear el técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear el técnico: $e');
    }
  }

  // Actualizar un técnico
  static Future<void> update(String uuid, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$uuid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el técnico: $e');
    }
  }

  // Eliminar un técnico
  static Future<void> delete(String uuid) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$uuid'));
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar el técnico: $e');
    }
  }

  // Obtener técnicos por equipo técnico
  static Future<List<dynamic>> getByTechnicalTeam(String technicalTeamId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/technical-team/$technicalTeamId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener técnicos por equipo técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener técnicos por equipo técnico: $e');
    }
  }
}
