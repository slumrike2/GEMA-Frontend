import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicianService {
  static const String baseUrl = 'http://localhost:3000/api/technicians';

  // Obtener todos los técnicos
  static Future<List<Map<String, dynamic>>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map && decoded.containsKey('technicians')) {
        return List<Map<String, dynamic>>.from(decoded['technicians']);
      }
      return [];
    } else {
      throw Exception('Error al obtener técnicos: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener un técnico por UUID
  static Future<Map<String, dynamic>> getByUuid(String uuid) async {
    final response = await http.get(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener el técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Crear un nuevo técnico desde usuario existente (requiere uuid del usuario)
  // data debe incluir: uuid, speciality, technicalTeamId (opcional), contact (opcional)
  static Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final dataToSend = Map<String, dynamic>.from(data);

    // NO eliminar uuid, es requerido para el backend

    final response = await http.post(
      Uri.parse('$baseUrl/from-user'),  // endpoint especial para creación desde usuario
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dataToSend),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al crear el técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Actualizar un técnico por UUID
  static Future<void> update(String uuid, Map<String, dynamic> data) async {
    final dataToSend = Map<String, dynamic>.from(data);
    dataToSend.remove('uuid'); // No se puede actualizar el UUID

    final response = await http.put(
      Uri.parse('$baseUrl/$uuid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dataToSend),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Eliminar un técnico por UUID
  static Future<void> delete(String uuid) async {
    final response = await http.delete(Uri.parse('$baseUrl/$uuid'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener técnicos por ID de equipo técnico (int)
  static Future<List<Map<String, dynamic>>> getByTechnicalTeam(int technicalTeamId) async {
    final response = await http.get(Uri.parse('$baseUrl/technical-team/$technicalTeamId'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else if (decoded is Map && decoded.containsKey('technicians')) {
        return List<Map<String, dynamic>>.from(decoded['technicians']);
      }
      return [];
    } else {
      throw Exception('Error al obtener técnicos por equipo técnico: ${response.statusCode} - ${response.body}');
    }
  }
}
