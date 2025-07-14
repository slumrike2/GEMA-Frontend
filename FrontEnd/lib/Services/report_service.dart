import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class ReportService {
  static const String baseUrl = 'http://localhost:3000/api/reports';

  static Future<List<Report>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener reportes: \\${response.statusCode}');
    }
  }

  static Future<Report> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener reporte: \\${response.statusCode}');
    }
  }

  static Future<void> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear reporte: \\${response.statusCode}');
    }
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar reporte: \\${response.statusCode}');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar reporte: \\${response.statusCode}');
    }
  }
}
