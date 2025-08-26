import 'dart:convert';
import 'package:http/http.dart' as http;

class GetDisciplinasByDay {
  final String baseUrl = "https://final-ifg-backend.onrender.com";
  final String token; // passe o Bearer token no construtor

  GetDisciplinasByDay(this.token);

  Future<Map<String, dynamic>?> getDisciplinesByDay(int day) async {
    final url = Uri.parse("$baseUrl/discipline/day/$day");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        throw Exception("Dia da semana inválido. Use valores entre 0 e 6.");
      } else if (response.statusCode == 500) {
        throw Exception("Erro interno no servidor.");
      } else {
        throw Exception("Erro: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
