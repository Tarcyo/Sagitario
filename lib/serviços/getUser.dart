import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;

/// Modelo do usuário retornado pela API
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  /// Construtor que lida com diferentes formas de chave/nomes vindos da API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // A API devolve às vezes {"Usuário": { ... }} — então json aqui deve ser o objeto do usuário.
    String? id = json['id']?.toString() ?? json['_id']?.toString();
    String name = (json['name'] ?? json['nome'] ?? '') as String;
    String email = (json['email'] ?? '') as String;
    String? phone = json['phone'] ?? json['telefone'];
    String? type = json['type'] ?? json['tipo'];

    DateTime? parseNullableDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final createdAt = parseNullableDate(json['created_at'] ?? json['createdAt']);
    final updatedAt = parseNullableDate(json['updated_at'] ?? json['updatedAt']);

    if (id == null) {
      throw FormatException('Campo "id" ausente no JSON do usuário: $json');
    }

    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phone: $phone, type: $type, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Exceções específicas
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not Found']);
  @override
  String toString() => 'NotFoundException: $message';
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Busca usuário por ID
///
/// - [bearerToken] : token Bearer para Authorization header
/// - [id] : id do usuário (path param)
/// - [client] : opcional, para injetar mock/test client
/// - [timeout] : opcional
///
/// Retorna [UserModel] em caso de sucesso (HTTP 200).
Future<UserModel> fetchUserById({
  required String bearerToken,
  required String id,
  http.Client? client,
  Duration timeout = const Duration(seconds: 10),
}) async {
  client ??= http.Client();
  final uri = Uri.parse('https://final-ifg-backend.onrender.com/user/$id');

  final headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $bearerToken',
  };

  try {
    final response = await client.get(uri, headers: headers).timeout(timeout);

    final status = response.statusCode;
    final bodyText = response.body.isNotEmpty ? response.body : '{}';
    dynamic decoded;
    try {
      decoded = jsonDecode(bodyText);
    } catch (e) {
      // corpo não é JSON — tratar como erro genérico
      throw ApiException(status, 'Resposta inválida do servidor: ${response.body}');
    }

    if (status == 200) {
      // A API exemplo devolve: { "Usuário": { ... } }
      Map<String, dynamic> userJson;
      if (decoded is Map<String, dynamic>) {
        // procurar a chave que contém o usuário (tanto "Usuário" quanto "user" ou direto)
        if (decoded.containsKey('Usuário') && decoded['Usuário'] is Map<String, dynamic>) {
          userJson = Map<String, dynamic>.from(decoded['Usuário']);
        } else if (decoded.containsKey('user') && decoded['user'] is Map<String, dynamic>) {
          userJson = Map<String, dynamic>.from(decoded['user']);
        } else {
          // suponha que o próprio decoded é o objeto do usuário
          userJson = Map<String, dynamic>.from(decoded);
        }
        return UserModel.fromJson(userJson);
      } else {
        throw ApiException(200, 'Formato inesperado na resposta do servidor.');
      }
    } else if (status == 401) {
      // ex: { "message": "Unauthorized: No token provided" }
      final msg = (decoded is Map && decoded['message'] != null) ? decoded['message'].toString() : 'Unauthorized';
      throw UnauthorizedException(msg);
    } else if (status == 404) {
      final msg = (decoded is Map && decoded['message'] != null) ? decoded['message'].toString() : 'Data not found';
      throw NotFoundException(msg);
    } else {
      final msg = (decoded is Map && decoded['message'] != null) ? decoded['message'].toString() : response.body;
      throw ApiException(status, msg);
    }
  } on SocketException catch (e) {
    throw ApiException(-1, 'Falha de rede: ${e.message}');
  } on TimeoutException {
    throw ApiException(-1, 'Timeout ao conectar com o servidor');
  } on FormatException catch (e) {
    throw ApiException(-1, 'Erro ao processar resposta: ${e.message}');
  } finally {
    // não fechamos client se foi passado de fora; se criamos localmente, idealmente poderia ser fechado,
    // mas deixamos o gerenciamento de client para quem chamou (padrão similar ao anterior).
  }
}