import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class TechnicalTeamService {
  static const String baseUrl = 'http://localhost:3000/api/technical-teams';

  // Obtener todos los equipos técnicos
  static Future<List<TechnicalTeam>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => TechnicalTeam.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener equipos técnicos: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener un equipo técnico por ID
  static Future<TechnicalTeam> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return TechnicalTeam.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener el equipo técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Crear un nuevo equipo técnico
  static Future<TechnicalTeam> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return TechnicalTeam.fromJson(jsonDecode(response.body));
    } else {throw Exception('Error al crear el equipo técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Actualizar un equipo técnico
  static Future<TechnicalTeam> update(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return TechnicalTeam.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar el equipo técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Eliminar un equipo técnico
  static Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar el equipo técnico: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener equipos técnicos por especialidad
  static Future<List<TechnicalTeam>> getBySpeciality(String speciality) async {
    final response = await http.get(Uri.parse('$baseUrl/speciality/$speciality'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => TechnicalTeam.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener equipos por especialidad: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener equipos técnicos por líder
  static Future<List<TechnicalTeam>> getByLeader(String leaderId) async {
    final response = await http.get(Uri.parse('$baseUrl/leader/$leaderId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => TechnicalTeam.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener equipos por líder: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener técnicos asignados a un equipo
  static Future<List<Technician>> getTechniciansByTeam(String teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/$teamId/technicians'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Technician.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener técnicos del equipo: ${response.statusCode} - ${response.body}');
    }
  }

  // Asignar un técnico a un equipo
  static Future<void> assignTechnicianToTeam(String teamId, String technicianId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$teamId/assign-technician'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'technicianId': technicianId}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al asignar técnico al equipo: ${response.statusCode} - ${response.body}');
    }
  }
}
