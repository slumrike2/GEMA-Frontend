import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicalLocationService {
  static const String baseUrl = 'http://localhost:3000/api/technical-locations';

  // Obtener todas las ubicaciones técnicas
  static Future<List<dynamic>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener ubicaciones técnicas');
    }
  }

  // Obtener una ubicación técnica por código
  static Future<Map<String, dynamic>> getByCode(String code) async {
    final response = await http.get(Uri.parse('$baseUrl/$code'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener la ubicación técnica');
    }
  }

  // Crear una nueva ubicación técnica
  static Future<void> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear la ubicación técnica');
    }
  }

  // Actualizar una ubicación técnica
  static Future<void> update(String code, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la ubicación técnica');
    }
  }

  // Eliminar una ubicación técnica
  static Future<void> delete(String code) async {
    final response = await http.delete(Uri.parse('$baseUrl/$code'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la ubicación técnica');
    }
  }

  // Obtener hijos de una ubicación técnica
  static Future<List<dynamic>> getChildren(String code) async {
    final response = await http.get(Uri.parse('$baseUrl/$code/children'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener hijos');
    }
  }
}