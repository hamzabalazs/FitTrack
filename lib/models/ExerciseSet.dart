class ExerciseSet {
  final int reps;
  final double weight;

  ExerciseSet({
    required this.reps,
    required this.weight,
  });

  ExerciseSet copyWith({
    int? reps,
    double? weight,
  }) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  @override
  String toString() {
    return "set: \nreps: $reps, weight:$weight";
  }

  Map<String, dynamic> toMap() {
    return {'reps': reps, 'weight': weight};
  }
}
