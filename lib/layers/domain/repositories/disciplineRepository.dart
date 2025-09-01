import '../entities/discipline.dart';

abstract class DisciplineRepository {
  Future<List<Discipline>> fetchAll();
}
