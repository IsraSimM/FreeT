import '../dtos/routine_dto.dart';

/// Fuente de datos remota para rutinas desde Firestore/Cloud Functions.
abstract class RoutineRemoteDataSource {
  Future<List<RoutineDto>> fetchUserRoutines(String userId);
}

class FirebaseRoutineRemoteDataSource implements RoutineRemoteDataSource {
  @override
  Future<List<RoutineDto>> fetchUserRoutines(String userId) async {
    // TODO: Integrar Firestore queries reales.
    return const <RoutineDto>[];
  }
}
