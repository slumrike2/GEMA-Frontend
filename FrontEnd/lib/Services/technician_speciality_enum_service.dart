import 'package:http/http.dart' as http;
import 'dart:convert';

class TechnicianSpecialityEnumService {
  static const String baseUrl =
      'http://localhost:3000/api/technician-specialities-enum';

  static Future<List<String>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.cast<String>();
      } else if (data is Map && data.containsKey('specialities')) {
        return List<String>.from(data['specialities']);
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Error al obtener especialidades enum: \\${response.statusCode}',
      );
    }
  }
}
