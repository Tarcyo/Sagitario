import 'package:sagitario/layers/domain/entities/discplineEntity.dart';


abstract class DisciplineRepository {
  Future<List<Discipline>> fetchAll();
}
