import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/ExerciseSet.dart';
import 'package:fittrack/models/UserProfile.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/utils/ErrorDialog.dart';
import 'package:fittrack/widgets/WorkloadItem.dart';
import 'package:flutter/material.dart';

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

  static Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot['role'];
      }
      return "";
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  static Future<int> getNumberOfWorkouts(String uid) async {
    try {
      if (uid == "") return 0;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception("Failed to fetch number of workouts");
    }
  }

  static Future<UserProfile?> getUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return UserProfile(
            email: documentSnapshot['email'],
            firstName: documentSnapshot['firstName'],
            lastName: documentSnapshot['lastName'],
            role: documentSnapshot['role']);
      }
      return null;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  static Future<List<Workout>> getUserWorkouts(String uid) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? uid = currentUser?.uid;
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('userId', isEqualTo: uid)
          .get();
      final List<Workout> fetchedWorkouts = querySnapshot.docs.map((doc) {
        List<Map<String, dynamic>> workloadsData =
            (doc['workloads'] as List).cast<Map<String, dynamic>>();

        List<Workload> workloads = workloadsData.map((workloadData) {
          String exerciseId = workloadData['exerciseId'] as String;
          List<Map<String, dynamic>> setsData =
              (workloadData['sets'] as List).cast<Map<String, dynamic>>();

          List<ExerciseSet> sets = setsData.map((setData) {
            final reps = setData['reps'] as int;
            final weight = setData['weight'] as double;
            return ExerciseSet(reps: reps, weight: weight);
          }).toList();

          return Workload(exerciseId: exerciseId, sets: sets);
        }).toList();

        return Workout(
          id: doc.id,
          type: WorkoutType.values.firstWhere(
            (diff) => diff.toString() == 'WorkoutType.${doc['type']}',
            orElse: () => WorkoutType.Pull,
          ),
          workloads: workloads,
          userId: doc['userId'] as String,
          date: doc['date'] as Timestamp,
        );
      }).toList();
      return fetchedWorkouts;
    } catch (e) {
      throw Exception("Failed to fetch user workouts!");
    }
  }

  static Future<void> addExercise(String name, String description, String gif,
      ExerciseDifficulty difficulty) async {
    final newExercise = Exercise(
      id: "placeholder",
      name: name,
      description: description,
      gif: gif,
      difficulty: difficulty,
    );

    await FirebaseFirestore.instance
        .collection('exercises')
        .add(newExercise.toMap());
  }

  static Future<bool> addWorkout(List<WorkloadItem> workloadItems,
      WorkoutType selectedType, String? uid, BuildContext context) async {
    try {
      List<Workload> workloads = [];

      for (var item in workloadItems) {
        Workload workloadData = item.workload;
        if (workloadData.sets.isEmpty) {
          ErrorDialog.showErrorDialog(context, "Exercise cannot have 0 sets!");
          return false;
        }
        if (workloadData.exerciseId == "") {
          ErrorDialog.showErrorDialog(context, "No exercise chosen!");
          return false;
        }
        workloads.add(workloadData);
      }

      if (workloads.isEmpty) {
        ErrorDialog.showErrorDialog(
            context, "Workout cannot have 0 exercises!");
        return false;
      }

      final newWorkout = Workout(
          id: "placeholder",
          date: Timestamp.now(),
          type: selectedType,
          userId: uid ?? "",
          workloads: workloads);

      await FirebaseFirestore.instance
          .collection('workouts')
          .add(newWorkout.toMap());
      return true;
    } catch (e) {
      ErrorDialog.showErrorDialog(context, "Failed to add workout!");
      return false;
    }
  }

  static Future<bool> deleteWorkout(String workoutId) async {
    try {
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workoutId)
          .delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  static Future<bool> editWorkout(
      Workout workout,
      List<WorkloadItem> workloadItems,
      WorkoutType selectedType,
      BuildContext context) async {
    try {
      List<Workload> workloads = [];

      for (var item in workloadItems) {
        Workload workloadData = item.workload;
        if (workloadData.sets.isEmpty) {
          ErrorDialog.showErrorDialog(context, "Exercise cannot have 0 sets!");
          return false;
        }
        if (workloadData.exerciseId == "") {
          ErrorDialog.showErrorDialog(context, "No exercise chosen!");
          return false;
        }
        workloads.add(workloadData);
      }

      if (workloads.isEmpty) {
        ErrorDialog.showErrorDialog(
            context, "Workout cannot have 0 exercises!");
        return false;
      }

      final newWorkout = Workout(
          id: workout.id,
          date: workout.date,
          type: selectedType,
          userId: workout.userId,
          workloads: workloads);

      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workout.id)
          .update(newWorkout.toMap());
      return true;
    } catch (e) {
      ErrorDialog.showErrorDialog(context, "Failed to add workout!");
      return false;
    }
  }
}
