import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../datasources/routine_remote_datasource.dart';
import '../dtos/routine_dto.dart';

/// Implementación concreta del repositorio de rutinas apoyado en Firestore.
class RoutineRepositoryImpl implements RoutineRepository {
  RoutineRepositoryImpl(this.remoteDataSource);

  final RoutineRemoteDataSource remoteDataSource;

  @override
  Future<List<Routine>> fetchRoutines(String userId) async {
    final routines = await remoteDataSource.fetchUserRoutines(userId);
    return routines.map((dto) => dto.toDomain()).toList();
  }
}
