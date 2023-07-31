import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/widgets/ExerciseListItem.dart';
import '../models/Exercise.dart';
import 'package:flutter/material.dart';
import '../screens/add_exercise_screen.dart';

class ExercisesWidget extends StatefulWidget {
  const ExercisesWidget({Key? key}) : super(key: key);

  @override
  State<ExercisesWidget> createState() => _ExercisesWidgetState();
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  List<Exercise> _exercises = [];
  String userRole = "";

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        setState(() {
          userRole = documentSnapshot['role'];
        });
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> _fetchExercises() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .orderBy('name')
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
      setState(() {
        _exercises = fetchedExercises;
      });
    } catch (e) {
      throw Exception("Failed getting exercise data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return ExerciseListItem(exercise: exercise);
        },
      ),
      floatingActionButton: userRole == "ADMIN"
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddExerciseScreen(
                            onExerciseAdded: _fetchExercises)));
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
