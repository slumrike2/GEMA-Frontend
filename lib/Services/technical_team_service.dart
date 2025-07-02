import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicalTeamService {
  static const String baseUrl = 'http://localhost:3000/api/technical-teams';

  // Obtener todos los equipos técnicos
  static Future<List<dynamic>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener equipos técnicos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener equipos técnicos: $e');
    }
  }

  // Obtener un equipo técnico por ID
  static Future<Map<String, dynamic>> getById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener el equipo técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener el equipo técnico: $e');
    }
  }

  // Crear un nuevo equipo técnico
  static Future<void> create(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        throw Exception('Error al crear el equipo técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear el equipo técnico: $e');
    }
  }

  // Actualizar un equipo técnico
  static Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el equipo técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el equipo técnico: $e');
    }
  }

  // Eliminar un equipo técnico
  static Future<void> delete(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el equipo técnico: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar el equipo técnico: $e');
    }
  }

  // Obtener equipos técnicos por especialidad
  static Future<List<dynamic>> getBySpeciality(String speciality) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/speciality/$speciality'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener equipos por especialidad: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener equipos por especialidad: $e');
    }
  }

  // Obtener equipos técnicos por líder
  static Future<List<dynamic>> getByLeader(String leaderId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leader/$leaderId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener equipos por líder: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener equipos por líder: $e');
    }
  }
}