import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client client;
  final String baseUrl;

  ApiClient(this.client, {this.baseUrl = 'https://redusilva.github.io/agrupa-sistemas/'});

  Future<http.Response> get(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return client.get(uri, headers: {'Accept': 'application/json'});
  }
}
