import 'package:flutter/foundation.dart';
import '../../domain/entities/discipline.dart';
import '../../domain/usecases/get_all_disciplines.dart';

enum ViewState { idle, busy, error }

class DisciplineController extends ChangeNotifier {
  final GetAllDisciplines getAllDisciplines;

  DisciplineController(this.getAllDisciplines);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? errorMessage;
  List<Discipline> disciplines = [];

  Future<void> fetchDisciplines() async {
    _state = ViewState.busy;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await getAllDisciplines();
      disciplines = result;
      _state = ViewState.idle;
    } catch (e) {
      _state = ViewState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}
