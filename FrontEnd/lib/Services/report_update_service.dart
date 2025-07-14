import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class ReportUpdateService {
  static const String baseUrl = 'http://localhost:3000/api/report-updates';

  static Future<List<ReportUpdate>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ReportUpdate.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener actualizaciones de reporte: \\${response.statusCode}',
      );
    }
  }

  static Future<ReportUpdate> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return ReportUpdate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener actualización de reporte: \\${response.statusCode}',
      );
    }
  }

  static Future<void> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear actualización de reporte: \\${response.statusCode}',
      );
    }
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar actualización de reporte: \\${response.statusCode}',
      );
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar actualización de reporte: \\${response.statusCode}',
      );
    }
  }
}
