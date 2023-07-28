import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/ExerciseSet.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/widgets/WorkoutListItem.dart';
import 'package:flutter/material.dart';

import '../screens/add_workout_screen.dart';

class WorkoutsWidget extends StatefulWidget {
  const WorkoutsWidget({Key? key}) : super(key: key);
  @override
  State<WorkoutsWidget> createState() => _WorkoutsWidgetState();
}

class _WorkoutsWidgetState extends State<WorkoutsWidget> {
  List<Workout> _workouts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserWorkouts();
  }

  Future<void> _fetchUserWorkouts() async {
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
            int reps = setData['reps'] as int;
            int weight = setData['weight'] as int;
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
      setState(() {
        _workouts = fetchedWorkouts;
      });
    } catch (e) {
      throw Exception("Failed getting exercise data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          final workout = _workouts[index];
          return WorkoutListItem(workout: workout);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddWorkoutScreen(onWorkoutAdded: _fetchUserWorkouts)));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
