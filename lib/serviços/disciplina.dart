import 'dart:convert';
import 'package:http/http.dart' as http;

// Modelos
class Schedule {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  Schedule({required this.dayOfWeek, required this.startTime, required this.endTime});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class Classroom {
  final String id;
  final String name;
  final String latitude;
  final String longitude;
  final int minDistance;

  Classroom({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.minDistance,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      minDistance: json['min_distance'],
    );
  }
}

class Person {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String type;

  Person({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      type: json['type'],
    );
  }
}

class Discipline {
  final String id;
  final String name;
  final String description;
  final Classroom? classroom;
  final Person? teacher;
  final List<Person> students;
  final Schedule? schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discipline({
    required this.id,
    required this.name,
    required this.description,
    this.classroom,
    this.teacher,
    required this.students,
    this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      classroom: json['classroom'] != null ? Classroom.fromJson(json['classroom']) : null,
      teacher: json['teacher'] != null ? Person.fromJson(json['teacher']) : null,
      students: (json['students'] as List<dynamic>?)
              ?.map((s) => Person.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

// Client para consumir a API
class DisciplineApiClient {
  final String _baseUrl;
  final String _bearerToken;
  final http.Client _http;

  DisciplineApiClient({
    String baseUrl = 'http://localhost:3001',
    required String bearerToken,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _bearerToken = bearerToken,
        _http = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_bearerToken',
      };

  /// Cria uma nova disciplina
  Future<Discipline> createDiscipline({
    required String name,
    required String description,
  }) async {
    final uri = Uri.parse('$_baseUrl/discipline');
    final body = jsonEncode({
      'name': name,
      'description': description,
    });

    final resp = await _http.post(uri, headers: _headers, body: body);
    if (resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Discipline.fromJson(data);
    } else if (resp.statusCode == 400) {
      final errors = jsonDecode(resp.body)['errors'];
      throw Exception('Requisição inválida: $errors');
    } else {
      throw Exception('Erro ao criar disciplina: ${resp.statusCode}');
    }
  }

  /// Busca todas as disciplinas
  Future<List<Discipline>> fetchAllDisciplines() async {
    final uri = Uri.parse('$_baseUrl/discipline');
    final resp = await _http.get(uri, headers: _headers);
    if (resp.statusCode == 200) {
      final list = jsonDecode(resp.body) as List<dynamic>;
      return list
          .map((item) => Discipline.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erro ao buscar disciplinas: ${resp.statusCode}');
    }
  }

  /// Deleta uma disciplina pelo ID
  Future<void> deleteDiscipline(String id) async {
    final uri = Uri.parse('$_baseUrl/discipline/$id');
    final resp = await _http.delete(uri, headers: _headers);
    if (resp.statusCode == 200) {
      // tudo certo
      return;
    } else {
      throw Exception('Erro ao deletar disciplina: ${resp.statusCode}');
    }
  }

  /// Encerra o client
  void dispose() {
    _http.close();
  }
}