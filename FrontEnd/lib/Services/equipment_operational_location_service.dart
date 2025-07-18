import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class EquipmentOperationalLocationService {
  static const String baseUrl =
      'http://localhost:3000/api/equipment-operational-locations';

  static Future<List<EquipmentOperationalLocation>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<EquipmentOperationalLocation> locations =
          data.map((e) => EquipmentOperationalLocation.fromJson(e)).toList();
      return locations;
    } else {
      throw Exception(
        'Error al obtener ubicaciones operacionales: \\${response.statusCode}',
      );
    }
  }

  static Future<EquipmentOperationalLocation> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return EquipmentOperationalLocation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener ubicación operacional: \\${response.statusCode}',
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
        'Error al crear ubicación operacional: \\${response.statusCode}',
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
        'Error al actualizar ubicación operacional: \\${response.statusCode}',
      );
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar ubicación operacional: \\${response.statusCode}',
      );
    }
  }
}
