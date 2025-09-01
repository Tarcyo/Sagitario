import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sagitario/layers/core/api/api_client.dart';
import 'package:sagitario/layers/data/datasources/disciplines_remote_datasource.dart';
import 'package:sagitario/layers/data/repositories/repositoryIMPL.dart';
import 'package:sagitario/layers/domain/repositories/disciplineRepository.dart';
import 'package:sagitario/layers/domain/useCases/getAllDiscplinesUseCase.dart';
import 'package:sagitario/layers/presentation/controllers/disciplineControler.dart';



final getIt = GetIt.instance;

Future<void> initInjection() async {
  // External
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt()));

  // Data sources
  getIt.registerLazySingleton<DisciplineRemoteDatasource>(
      () => DisciplineRemoteDatasourceImpl(getIt()));

  // Repositories
  getIt.registerLazySingleton<DisciplineRepository>(
      () => DisciplineRepositoryImpl(getIt()));

  // Use cases
  getIt.registerLazySingleton<GetAllDisciplines>(
      () => GetAllDisciplines(getIt()));

  // Presentation / Controller (factory to create fresh controller)
  getIt.registerFactory<DisciplineController>(
      () => DisciplineController(getIt()));
}
