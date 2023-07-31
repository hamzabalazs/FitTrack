import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';

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
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .orderBy('name', descending: false)
          .get();

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

  static Future<List<Workout>> fetchUserWorkouts() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();
      final List<Workout> fetchedWorkouts = querySnapshot.docs.map((doc) {
        final List<dynamic> workloadsData = doc['workloads'] as List<dynamic>;
        final List<Workload> workloads = workloadsData.map((map) {
          return Workload.fromMap(map as Map<String, dynamic>);
        }).toList();
        return Workout(
            id: doc.id,
            userId: doc['userId'] as String,
            type: WorkoutType.values.firstWhere(
                (element) => element.toString() == 'WorkoutType.${doc['type']}',
                orElse: () => WorkoutType.Other),
            workloads: workloads,
            date: doc['date']);
      }).toList();
      return fetchedWorkouts;
    } catch (e) {
      throw Exception('Failed to fetch user workouts!');
    }
  }

  static Future<Workout?> fetchWorkoutData(Timestamp selectedDate) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('date', isEqualTo: selectedDate)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      QueryDocumentSnapshot doc = querySnapshot.docs[0];
      final Workout fetchedWorkout = Workout(
          id: doc.id,
          userId: doc['userId'] as String,
          type: WorkoutType.values.firstWhere(
              (element) => element.toString() == 'WorkoutType.${doc['type']}',
              orElse: () => WorkoutType.Other),
          workloads: doc['workloads'] as List<Workload>,
          date: doc['date']);
      return fetchedWorkout;
    } catch (e) {
      throw Exception("Error fetching workout data");
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
