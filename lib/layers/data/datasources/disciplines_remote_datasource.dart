import 'dart:convert';
import '../../dto/discipline_model.dart';
import '../../dto/classroom_model.dart';
import '../../dto/user_model.dart';
import '../../dto/schedule_model.dart';
import '../../core/api/api_client.dart';

abstract class DisciplineRemoteDatasource {
  Future<List<DisciplineModel>> fetchAll();
}

class DisciplineRemoteDatasourceImpl implements DisciplineRemoteDatasource {
  final ApiClient apiClient;
  DisciplineRemoteDatasourceImpl(this.apiClient);

  @override
  Future<List<DisciplineModel>> fetchAll() async {
    final response = await apiClient.get('/discipline');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => DisciplineModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load disciplines: ${response.statusCode}');
    }
  }
}
