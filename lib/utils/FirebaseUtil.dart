import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittrack/models/Exercise.dart';

class FirebaseUtil {
  static Future<void> addUserToFirestore(
    String id,
    String firstName,
    String lastName,
    String email,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': "USER",
      });
    } catch (e) {
      throw Exception("Error adding user to Firestore: $e");
    }
  }

  static Future<List<Exercise>> fetchExercises() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('exercises').get();

      final List<Exercise> fetchedExercises = querySnapshot.docs.map((doc) {
        return Exercise(
          id: doc.id,
          name: doc['name'] as String,
          description: doc['description'] as String,
          gif: doc['gif'] as String,
          difficulty: ExerciseDifficulty.values.firstWhere(
            (diff) =>
                diff.toString() == 'ExerciseDifficulty.${doc['difficulty']}',
            orElse: () => ExerciseDifficulty.Easy,
          ),
        );
      }).toList();
      return fetchedExercises;
    } catch (e) {
      throw Exception("Failed getting exercise data");
    }
  }

  static Future<String> getExerciseName(
      String exerciseId, List<Exercise> exercises) async {
    Exercise exercise = exercises.firstWhere(
        (exercise) => exercise.id == exerciseId,
        orElse: () => Exercise(
            id: exerciseId,
            name: "",
            description: "ERROR",
            gif: "",
            difficulty: ExerciseDifficulty.Easy));
    return exercise.name;
  }
}
