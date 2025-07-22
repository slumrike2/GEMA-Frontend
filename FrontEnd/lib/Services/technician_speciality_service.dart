import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicianSpecialityService {
  static const String baseUrl = 'http://localhost:3000/api/technician-specialities-enum';

  // Obtener todas las especialidades disponibles
  static Future<List<String>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Asumiendo que la respuesta es un array de strings o un objeto con las especialidades
        if (data is List) {
          return data.cast<String>();
        } else if (data is Map && data.containsKey('specialities')) {
          return List<String>.from(data['specialities']);
        } else {
          return [];
        }
      } else {
        throw Exception('Error al obtener especialidades: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener especialidades: $e');
    }
  }

  static Future<void> create(String speciality) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'speciality': speciality}),
      );
      if (response.statusCode != 201) {
        throw Exception(
          'Error al crear especialidad: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al crear especialidad: $e');
    }
  }
} 