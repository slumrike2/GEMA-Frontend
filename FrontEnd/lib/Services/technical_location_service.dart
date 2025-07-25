import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class TechnicalLocationService {
  static const String baseUrl = 'http://localhost:3000/api/technical-locations';

  // Obtener todas las ubicaciones técnicas
  static Future<List<TechnicalLocation>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TechnicalLocation.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error al obtener ubicaciones técnicas: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener ubicaciones técnicas: $e');
    }
  }

  // Obtener una ubicación técnica por código
  static Future<TechnicalLocation> getByCode(String code) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$code'));
      if (response.statusCode == 200) {
        return TechnicalLocation.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Error al obtener la ubicación técnica: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener la ubicación técnica: $e');
    }
  }

  // Crear una nueva ubicación técnica
  static Future<void> create(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 201) {
        throw Exception(
          'Error al crear la ubicación técnica: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al crear la ubicación técnica: $e');
    }
  }

  // Actualizar una ubicación técnica
  static Future<void> update(String code, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Error al actualizar la ubicación técnica: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar la ubicación técnica: $e');
    }
  }

  // Eliminar una ubicación técnica
  static Future<void> delete(String code) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$code'));
      if (response.statusCode != 200) {
        throw Exception(
          'Error al eliminar la ubicación técnica: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al eliminar la ubicación técnica: $e');
    }
  }

  // Obtener hijos de una ubicación técnica
  static Future<List<dynamic>> getChildren(String code) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$code/children'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error al obtener hijos: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener hijos: $e');
    }
  }

  static Future<List<TechnicalLocation>> getRoots() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/roots'));
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TechnicalLocation.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error al obtener ubicaciones técnicas raíces: \\${response.statusCode} - \\${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener ubicaciones técnicas raíces: $e');
    }
  }
}
