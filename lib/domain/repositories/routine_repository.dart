import '../entities/routine.dart';

/// Contrato del repositorio de rutinas.
abstract class RoutineRepository {
  Future<List<Routine>> fetchRoutines(String userId);
}
