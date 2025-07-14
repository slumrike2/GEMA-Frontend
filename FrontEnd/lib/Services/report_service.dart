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

  // GET /api/reports/by-location/:technicalCode
  /// Obtiene todos los reportes asociados a una ubicación técnica específica.
  ///
  /// [technicalCode]: Código técnico de la ubicación.
  /// Returns: Lista de reportes asociados a la ubicación.
  /// Throws: Exception si ocurre un error en la petición.
  static Future<List<Report>> getByLocation(String technicalCode) async {
    final url = baseUrl.replaceFirst(
      '/api/reports',
      '/api/reports/by-location/$technicalCode',
    );
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener reportes por ubicación: ${response.statusCode}',
      );
    }
  }

  // GET /api/reports/by-equipment/:equipmentUuid
  /// Obtiene todos los reportes asociados a un equipo específico.
  ///
  /// [equipmentUuid]: UUID del equipo.
  /// Returns: Lista de reportes asociados al equipo.
  /// Throws: Exception si ocurre un error en la petición.
  static Future<List<Report>> getByEquipment(String equipmentUuid) async {
    final url = baseUrl.replaceFirst(
      '/api/reports',
      '/api/reports/by-equipment/$equipmentUuid',
    );
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener reportes por equipo: ${response.statusCode}',
      );
    }
  }

  // POST /api/reports/associate-equipments/:reportId
  /// Asocia uno o varios equipos a un reporte (relación muchos-a-muchos).
  ///
  /// [reportId]: ID del reporte.
  /// [equipmentUuids]: Lista de UUIDs de equipos a asociar.
  /// Returns: Lista de relaciones creadas.
  /// Throws: Exception si ocurre un error en la petición.
  static Future<List<dynamic>> associateEquipments(
    int reportId,
    List<String> equipmentUuids,
  ) async {
    final url = baseUrl.replaceFirst(
      '/api/reports',
      '/api/reports/associate-equipments/$reportId',
    );
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'equipmentUuids': equipmentUuids}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al asociar equipos: ${response.statusCode}');
    }
  }

  // POST /api/reports/associate-locations/:reportId
  /// Asocia una o varias ubicaciones técnicas a un reporte (relación muchos-a-muchos).
  ///
  /// [reportId]: ID del reporte.
  /// [technicalCodes]: Lista de códigos técnicos de ubicaciones a asociar.
  /// Returns: Lista de relaciones creadas.
  /// Throws: Exception si ocurre un error en la petición.
  static Future<List<dynamic>> associateLocations(
    int reportId,
    List<String> technicalCodes,
  ) async {
    final url = baseUrl.replaceFirst(
      '/api/reports',
      '/api/reports/associate-locations/$reportId',
    );
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'technicalCodes': technicalCodes}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al asociar ubicaciones: ${response.statusCode}');
    }
  }
}
