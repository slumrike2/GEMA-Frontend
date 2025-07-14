import 'package:http/http.dart' as http;
import 'dart:convert';

class EnumService {
  static const String baseUrl = 'http://localhost:3000/api/enum';

  static Future<Map<String, dynamic>> getAllEnums() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener enums: \\${response.statusCode}');
    }
  }
}
