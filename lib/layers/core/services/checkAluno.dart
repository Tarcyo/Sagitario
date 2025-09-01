import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Modelo de resposta quando o ponto é registrado com sucesso
class AttendanceCheckResult {
  final String status;
  final int checks;

  AttendanceCheckResult({required this.status, required this.checks});

  factory AttendanceCheckResult.fromJson(Map<String, dynamic> json) {
    return AttendanceCheckResult(
      status: json['status'] as String? ?? '',
      checks: (json['checks'] is int) ? json['checks'] as int : int.tryParse('${json['checks']}') ?? 0,
    );
  }

  @override
  String toString() => 'AttendanceCheckResult(status: $status, checks: $checks)';
}

/// Erro retornado com código 400 (dados inválidos)
class BadRequestException implements Exception {
  final Map<String, dynamic> errors;
  BadRequestException(this.errors);
  @override
  String toString() => 'BadRequestException: $errors';
}

/// Erro genérico da API (500, etc.)
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Registra um ponto de presença.
///
/// Campos obrigatórios:
/// - [bearerToken] : token Bearer para Authorization header
/// - [studentId], [disciplineId] : ids em string
/// - [isPresent] : true/false
/// - [startTime] : "HH:MM" (ex: "08:00")
/// - [classDate] : "YYYY-MM-DD" (ex: "2025-08-11")
///
/// Retorna [AttendanceCheckResult] em caso de sucesso (HTTP 200).
Future<AttendanceCheckResult> registerAttendanceCheck({
  required String bearerToken,
  required String studentId,
  required String disciplineId,
  required bool isPresent,
  required String startTime,
  required String classDate,
  http.Client? client,
  Duration timeout = const Duration(seconds: 10),
}) async {
  client ??= http.Client();
  final uri = Uri.parse('https://final-ifg-backend.onrender.com/attendance/check');

  final Map<String, dynamic> payload = {
    'student_id': studentId,
    'discipline_id': disciplineId,
    'is_present': isPresent,
    'start_time': startTime,
    'class_date': classDate,
  };

  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $bearerToken',
  };

  try {
    final response = await client
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(timeout);

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode == 200) {
      if (body is Map<String, dynamic>) {
        return AttendanceCheckResult.fromJson(body);
      } else {
        throw ApiException(200, 'Resposta 200 com formato inesperado: ${response.body}');
      }
    } else if (response.statusCode == 400) {
      // Espera { "errors": { ... } }
      final errors = (body is Map<String, dynamic> && body['errors'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(body['errors'])
          : <String, dynamic>{'body': body};
      throw BadRequestException(errors);
    } else {
      final message = (body is Map<String, dynamic> && body['message'] != null)
          ? '${body['message']}'
          : response.body;
      throw ApiException(response.statusCode, message);
    }
  } on SocketException catch (e) {
    throw ApiException(-1, 'Falha de conexão: ${e.message}');
  } on http.ClientException catch (e) {
    throw ApiException(-1, 'ClientException: ${e.message}');
  } on FormatException catch (e) {
    throw ApiException(-1, 'Erro ao decodificar resposta: ${e.message}');
  }  finally {
    // opcional: não feche client se foi passado de fora (decisão simples: não fechamos)
  }
}
