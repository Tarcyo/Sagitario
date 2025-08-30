import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'https://final-ifg-backend.onrender.com';

/// Exceções customizadas
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class BadRequestException extends ApiException {
  final Map<String, dynamic>? errors;
  BadRequestException(String message, {this.errors}) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

/// Modelo de Classroom (response body)
class Classroom {
  final String id;
  final String name;
  final String latitude;
  final String longitude;
  final int minDistance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Classroom({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.minDistance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      minDistance: json['min_distance'] is int
          ? json['min_distance'] as int
          : int.tryParse(json['min_distance']?.toString() ?? '') ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'min_distance': minDistance,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  String toString() {
    return 'Classroom: '+toJson().toString();
  }
}

/// Função que busca sala por id (GET /classroom/{id}) usando Bearer token.
/// - [id] : id da sala (path)
/// - [bearerToken] : token JWT (a função adiciona o prefixo "Bearer ")
/// - [client] : opcional, útil para injeção em testes (se não informado a função cria e fecha seu próprio client)
Future<Classroom> getClassroomById(
  String id,
  String bearerToken, {
  http.Client? client,
}) async {
  final bool createdLocalClient = client == null;
  client ??= http.Client();
  final uri = Uri.parse('$_baseUrl/classroom/$id');

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
      if (response.body.isEmpty) {
        throw ApiException('Resposta vazia do servidor (200).');
      }
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return Classroom.fromJson(jsonMap);
    }

    // 400 Bad Request
    if (response.statusCode == 400) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final errors = (jsonMap['errors'] is Map) ? Map<String, dynamic>.from(jsonMap['errors']) : null;
        final message = jsonMap.containsKey('message') ? jsonMap['message'].toString() : 'Operação inválida (400).';
        throw BadRequestException(message, errors: errors);
      } catch (_) {
        throw BadRequestException('Operação inválida (400).');
      }
    }

    // 401 Unauthorized
    if (response.statusCode == 401) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final message = jsonMap['message'] ?? 'Usuário não autenticado (401).';
        throw UnauthorizedException(message as String);
      } catch (_) {
        throw UnauthorizedException('Usuário não autenticado (401).');
      }
    }

    // 404 Not Found — caso a API retorne 404 (não listado no swagger acima, mas comum)
    if (response.statusCode == 404) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final message = jsonMap['message'] ?? 'Sala não encontrada (404).';
        throw NotFoundException(message as String);
      } catch (_) {
        throw NotFoundException('Sala não encontrada (404).');
      }
    }

    // 5xx Server error
    if (response.statusCode >= 500 && response.statusCode < 600) {
      try {
        final Map<String, dynamic> jsonMap = response.body.isNotEmpty
            ? json.decode(response.body) as Map<String, dynamic>
            : {};
        final message = jsonMap['message'] ?? 'Erro interno no servidor (${response.statusCode}).';
        throw ServerException(message as String);
      } catch (_) {
        throw ServerException('Erro interno no servidor (${response.statusCode}).');
      }
    }

    // Outros códigos — tenta extrair mensagem
    try {
      final Map<String, dynamic> jsonMap = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final message = jsonMap['message'] ?? 'Erro desconhecido (${response.statusCode}).';
      throw ApiException(message as String);
    } catch (_) {
      throw ApiException('Erro desconhecido (${response.statusCode}).');
    }
  } on TimeoutException {
    throw ApiException('Tempo de conexão esgotado. Tente novamente.');
  } on http.ClientException catch (e) {
    throw ApiException('Erro de cliente HTTP: ${e.message}');
  } finally {
    if (createdLocalClient) {
      client.close();
    }
  }
}
