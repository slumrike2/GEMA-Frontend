import 'package:http/http.dart' as http;
import 'dart:convert';

// Tipo para la vista combinada de técnico y usuario
class TechnicianUserView {
  final String userId;
  final String? userName;
  final String userEmail;
  final String personalId;
  final String contact;
  final String speciality;
  final int? technicalTeamId;

  TechnicianUserView({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.personalId,
    required this.contact,
    required this.speciality,
    required this.technicalTeamId,
  });

  factory TechnicianUserView.fromJson(Map<String, dynamic> json) {
    return TechnicianUserView(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String,
      personalId: json['personalId'] as String,
      contact: json['contact'] as String,
      speciality: json['speciality'] as String,
      technicalTeamId: json['technicalTeamId'] as int?,
    );
  }
}

class TechnicianService {
  static const String baseUrl = 'http://localhost:3000/api/technicians';
  // Obtener la vista combinada de técnicos y usuarios
  static Future<List<TechnicianUserView>> getTechnicianUserView() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/view'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TechnicianUserView.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error al obtener la vista de técnicos: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener la vista de técnicos: $e');
    }
  }

  // Obtener todos los técnicos
  static Future<List<dynamic>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error al obtener técnicos: ${response.statusCode} - ${response.body}',
        );
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
        throw Exception(
          'Error al obtener el técnico: ${response.statusCode} - ${response.body}',
        );
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
        throw Exception(
          'Error al crear el técnico: ${response.statusCode} - ${response.body}',
        );
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
        throw Exception(
          'Error al actualizar el técnico: ${response.statusCode} - ${response.body}',
        );
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
        throw Exception(
          'Error al eliminar el técnico: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al eliminar el técnico: $e');
    }
  }

  // Obtener técnicos por equipo técnico
  static Future<List<dynamic>> getByTechnicalTeam(
    String technicalTeamId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/technical-team/$technicalTeamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error al obtener técnicos por equipo técnico: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener técnicos por equipo técnico: $e');
    }
  }
}
