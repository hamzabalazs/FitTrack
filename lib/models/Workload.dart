import 'package:fittrack/models/ExerciseSet.dart';

class Workload {
  final String exerciseId;
  final List<ExerciseSet> sets;

  Workload({
    required this.exerciseId,
    required this.sets,
  });

  @override
  String toString() {
    String setString = "Sets: \n";
    for (var item in sets) {
      setString += item.toString();
      setString += "\n\n";
    }
    return "workload: \nexerciseId:$exerciseId, sets:$setString";
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> setsData =
        sets.map((set) => set.toMap()).toList();
    return {'exerciseId': exerciseId, 'sets': setsData};
  }

  factory Workload.fromMap(Map<String, dynamic> map) {
    final exerciseId = map['exerciseId'] as String;
    final List<dynamic> setsData = map['sets'] as List<dynamic>;

    final List<ExerciseSet> sets = setsData.map((setData) {
      final reps = setData['reps'] as int;
      final weight = setData['weight'] as double;
      return ExerciseSet(reps: reps, weight: weight);
    }).toList();

    return Workload(exerciseId: exerciseId, sets: sets);
  }
}
