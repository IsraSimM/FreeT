import '../entities/routine.dart';

/// Caso de uso para generar rutinas con IA.
class GenerateRoutine {
  const GenerateRoutine();

  Future<Routine> call({required String focus}) async {
    // TODO: Integrar modelo IA y orquestación con Cloud Functions.
    return Routine(
      id: 'temp',
      name: 'Rutina $focus',
      focus: focus,
      exercises: const <RoutineExercise>[],
    );
  }
}
