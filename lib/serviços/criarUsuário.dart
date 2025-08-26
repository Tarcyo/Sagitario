import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class AuthService {
  static const _baseUrl = 'https://sistema-de-login-final.onrender.com';

  /// Cria um novo usuário no servidor.
  /// Lança [ApiException] em caso de erro de requisição ou validação.
  Future<User> createUser({
    required String email,
    required String name,
    required String password,
    required String type,
    required String phone,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth');
    final payload = jsonEncode({
      'email': email,
      'name': name,
      'password': password,
      'type': type,
      'phone': phone,
    });

    print("dados: "+payload);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: payload,
    );
   print("resposta: "+response.body);
    switch (response.statusCode) {
      case 201:
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userJson = data['user'] as Map<String, dynamic>;
        return User.fromJson(userJson);
      case 400:
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errors = (errorData['errors'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .join(', ') ??
            'Dados inválidos';
        throw ApiException('400 Bad Request: ${errorData['message']} ($errors)');
      case 500:
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw ApiException('500 Internal Server Error: ${errorData['message']}');
      default:
        throw ApiException(
            'Unexpected status code: ${response.statusCode}. Body: ${response.body}');
    }
  }
}
