import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class TechnicalLocationTypeService {
  static const String baseUrl =
      'http://localhost:3000/api/technical-location-types';

  static Future<List<LocationType>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => LocationType.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener tipos de ubicación técnica: \\${response.statusCode}',
      );
    }
  }

  static Future<LocationType> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return LocationType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener tipo de ubicación técnica: \\${response.statusCode}',
      );
    }
  }

  static Future<LocationType> create(String name) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return LocationType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al crear tipo de ubicación técnica: \\${response.statusCode}',
      );
    }
  }

  static Future<LocationType> createWithTemplates(
    String name,
    String nameTemplate,
    String codeTemplate,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'nameTemplate': nameTemplate,
        'codeTemplate': codeTemplate,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return LocationType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al crear tipo de ubicación técnica: \\${response.statusCode}',
      );
    }
  }
}
