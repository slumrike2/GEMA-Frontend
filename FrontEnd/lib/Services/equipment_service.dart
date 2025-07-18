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
  static Future<void> update(String uuid, Equipment data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$uuid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
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

  // Cambiar el estado de un equipo
  static Future<void> updateState(String uuid, String newState) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$uuid/state'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'state': newState}),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Error al cambiar el estado: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al cambiar el estado: $e');
    }
  }

  // Asociar ubicación técnica a un equipo
  static Future<void> assignTechnicalLocation(
    String equipmentId,
    String technicalLocationId,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/assign/technicalLocation/$equipmentId/$technicalLocationId',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo asociar la ubicación técnica, '
        ' código de estado: ${response.statusCode}, ${response.body}',
      );
    }
  }

  // Asociar ubicación operativa a un equipo
  static Future<void> assignOperationalLocation(
    String equipmentId,
    String operationalLocationId,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/assign/operationalLocation/$equipmentId/$operationalLocationId',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo asociar la ubicación operativa');
    }
  }

  // Obtener ubicaciones operativas de un equipo
  static Future<List<String>> getOperationalLocations(
    String equipmentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/operationalLocation/$equipmentId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      throw Exception(
        'No se pudieron obtener las ubicaciones operativas: '
        '\${response.statusCode} - \${response.body}',
      );
    }
  }
}
