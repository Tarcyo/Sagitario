import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// URL base do servidor (conforme informado)
const String _baseUrl = 'https://final-ifg-backend.onrender.com';

/// Exceções customizadas para facilitar o tratamento de erros
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

/// Modelo para um item de horário (schedule)
class ScheduleItem {
  final int dayOfWeek;
  final String startTime; // formato "HH:mm"
  final String endTime;   // formato "HH:mm"

  ScheduleItem({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      };
}

/// Modelo para Disciplina (discipline)
class Discipline {
  final String id;
  final String name;
  final String? description;
  final int totalClasses;
  final String? classroomId;
  final String? teacherId;
  final List<String> students;
  final List<ScheduleItem> schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discipline({
    required this.id,
    required this.name,
    this.description,
    required this.totalClasses,
    this.classroomId,
    this.teacherId,
    required this.students,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    final studentsRaw = json['students'];
    final scheduleRaw = json['schedule'];

    return Discipline(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalClasses: json['total_classes'] is int
          ? json['total_classes'] as int
          : int.tryParse(json['total_classes'].toString()) ?? 0,
      classroomId: json['classroom_id'] as String?,
      teacherId: json['teacher_id'] as String?,
      students: (studentsRaw is List) ? List<String>.from(studentsRaw) : <String>[],
      schedule: (scheduleRaw is List)
          ? scheduleRaw.map<ScheduleItem>((e) => ScheduleItem.fromJson(e as Map<String, dynamic>)).toList()
          : <ScheduleItem>[],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'total_classes': totalClasses,
        'classroom_id': classroomId,
        'teacher_id': teacherId,
        'students': students,
        'schedule': schedule.map((s) => s.toJson()).toList(),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  @override
  String toString() {
    return 'Discipline(id: $id, name: $name, totalClasses: $totalClasses, students: ${students.length}, schedule: ${schedule.length})';
  }
}

/// Função que consome GET /discipline/{id} com Bearer token.
/// - [id] : id da disciplina (path)
/// - [bearerToken] : token JWT ou similar (sem "Bearer " — a função adiciona)
/// - [client] : opcional, útil para testes; se null cria um novo http.Client
/// Retorna [Discipline] em caso de sucesso, lança [NotFoundException] (404),
/// [ServerException] (5xx) ou [ApiException] para outros casos.
Future<Discipline> getDisciplineById(
  String id,
  String bearerToken, {
  http.Client? client,
}) async {
  client ??= http.Client();
  final uri = Uri.parse('$_baseUrl/discipline/$id');

  try {
    final response = await client
        .get(
          uri,
          headers: <String, String>{
            'Accept': 'application/json',
            'Authorization': 'Bearer $bearerToken',
          },
        )
        .timeout(const Duration(seconds: 15));

    // 200 OK
    if (response.statusCode == 200) {
      final body = response.body;
      if (body.isEmpty) {
        throw ApiException('Resposta vazia do servidor.');
      }
      final Map<String, dynamic> jsonMap = json.decode(body) as Map<String, dynamic>;
      return Discipline.fromJson(jsonMap);
    }

    // 404 Not found
    if (response.statusCode == 404) {
      // tenta ler mensagem da API, se houver
      try {
        final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final message = jsonMap['message'] ?? 'Disciplina não encontrada';
        throw NotFoundException(message as String);
      } catch (_) {
        throw NotFoundException('Disciplina não encontrada (404).');
      }
    }

    // 5xx Server error
    if (response.statusCode >= 500 && response.statusCode < 600) {
      throw ServerException('Erro interno no servidor (${response.statusCode}).');
    }

    // Outros códigos — tenta extrair mensagem da API
    try {
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final message = jsonMap['message'] ?? 'Erro desconhecido (${response.statusCode}).';
      throw ApiException(message as String);
    } catch (_) {
      throw ApiException('Erro desconhecido (${response.statusCode}).');
    }
  } on TimeoutException catch (_) {
    throw ApiException('Tempo de conexão esgotado. Tente novamente.');
  } on http.ClientException catch (e) {
    throw ApiException('Erro de cliente HTTP: ${e.message}');
  } finally {
    // não fechamos o client se foi injetado pelo chamador (cliente pode querer reutilizar)
    // se criamos localmente (client == null no começo) o ideal seria fechá-lo. Como não sabemos,
    // quem passar o client fica responsável por fechá-lo.
  }
}
