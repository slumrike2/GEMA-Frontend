import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class EquipmentService {
  static const String baseUrl = 'http://localhost:3000/api/equipment';

  // Obtener todos los equipos
  static Future<List<Equipment>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Equipment.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error al obtener equipos: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener equipos: $e');
    }
  }

  // Obtener un equipo por UUID
  static Future<Equipment> getByUuid(String uuid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$uuid'));
      if (response.statusCode == 200) {
        return Equipment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Error al obtener el equipo: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener el equipo: $e');
    }
  }

  // Crear un nuevo equipo
  static Future<void> create(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        throw Exception(
          'Error al crear el equipo: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al crear el equipo: $e');
    }
  }

  // Actualizar un equipo
  static Future<void> update(String uuid, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$uuid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Error al actualizar el equipo: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar el equipo: $e');
    }
  }

  // Eliminar un equipo
  static Future<void> delete(String uuid) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$uuid'));
      if (response.statusCode != 200) {
        throw Exception(
          'Error al eliminar el equipo: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al eliminar el equipo: $e');
    }
  }
}
