import 'package:sagitario/layers/data/datasources/disciplines_remote_datasource.dart';
import 'package:sagitario/layers/domain/entities/discplineEntity.dart';
import 'package:sagitario/layers/domain/repositories/disciplineRepository.dart';

class DisciplineRepositoryImpl implements DisciplineRepository {
  final DisciplineRemoteDatasource remote;
  DisciplineRepositoryImpl(this.remote);

  @override
  Future<List<Discipline>> fetchAll() async {
    final models = await remote.fetchAll();
    // DisciplineModel extends Discipline, so they are already Discipline objects
    return models;
  }
}
