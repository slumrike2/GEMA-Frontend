import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/backend_types.dart';

class BrandService {
  static const String baseUrl = 'http://localhost:3000/api/brands';

  static Future<List<Brand>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Brand.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener marcas: \\${response.statusCode}');
    }
  }

  static Future<Brand> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Brand.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener marca: \\${response.statusCode}');
    }
  }

  static Future<void> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear marca: \\${response.statusCode}');
    }
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar marca: \\${response.statusCode}');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar marca: \\${response.statusCode}');
    }
  }
}
