
import 'package:sagitario/layers/core/domain/entities/discplineEntity.dart';
import 'package:sagitario/layers/core/domain/repositories/disciplineRepository.dart';

class GetAllDisciplines {
  final DisciplineRepository repository;
  GetAllDisciplines(this.repository);

  Future<List<Discipline>> call() async {
    return await repository.fetchAll();
  }
}
