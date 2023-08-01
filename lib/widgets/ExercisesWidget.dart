import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
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
      String currentUserRole = await FirebaseUtil.getUserRole(
          FirebaseAuth.instance.currentUser!.uid);
      if (currentUserRole != "") {
        setState(() {
          userRole = currentUserRole;
        });
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> _fetchExercises() async {
    try {
      List<Exercise> fetchedExercises = await FirebaseUtil.fetchExercises();
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
