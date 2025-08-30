// Adicione no pubspec.yaml:
// dependencies:
//   http: ^0.13.6

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Registra um único ponto de presença do professor.
/// Retorna o JSON decodificado em caso de sucesso (status 200).
/// Lança [Exception] em caso de erro (contendo mensagem e corpo da resposta).
Future<Map<String, dynamic>> registerTeacherAttendance({
  required String bearerToken,
  required String teacherId,
  required String disciplineId,
  required bool isPresent,
  required String startTime,   // ex: "08:00"
  required String classDate,   // ex: "2025-08-11"
}) async {
  final uri = Uri.parse('https://final-ifg-backend.onrender.com/attendance/check/teacher');

  final body = jsonEncode({
    "teacher_id": teacherId,
    "discipline_id": disciplineId,
    "is_present": isPresent,
    "start_time": startTime,
    "class_date": classDate,
  });


  print("Estou tentando enviar os valores: "+body.toString());

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $bearerToken',
  };

  final response = await http.post(uri, headers: headers, body: body);

  // Tentar decodificar o corpo (se houver)
  Map<String, dynamic>? parsed;
  try {
    if (response.body.isNotEmpty) parsed = jsonDecode(response.body) as Map<String, dynamic>?;
  } catch (e) {
    // se não for JSON, ignoramos o parse
    parsed = null;
  }

  switch (response.statusCode) {
    case 200:
      // Retorna o corpo decodificado (ex: { "status": "PENDING", "checks": 1 })
      return parsed ?? {"message": "Requisição bem-sucedida, sem corpo JSON."};
    case 400:
      throw Exception('400 Dados inválidos. Detalhes: ${parsed ?? response.body}');
    case 403:
      throw Exception('403 Professor não vinculado à disciplina. Detalhes: ${parsed ?? response.body}');
    case 404:
      throw Exception('404 Disciplina não encontrada. Detalhes: ${parsed ?? response.body}');
    case 500:
      throw Exception('500 Erro interno no servidor. Detalhes: ${parsed ?? response.body}');
    default:
      throw Exception('${response.statusCode} - Resposta inesperada: ${parsed ?? response.body}');
  }
}