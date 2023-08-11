import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
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
      List<Workout> fetchedWorkouts = await FirebaseUtil.getUserWorkouts(
          FirebaseAuth.instance.currentUser?.uid ?? "");
      setState(() {
        _workouts = fetchedWorkouts;
      });
    } catch (e) {
      throw Exception("Failed to fetch user workouts!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          final workout = _workouts[index];
          return WorkoutListItem(
              workout: workout, onWorkoutChanged: _fetchUserWorkouts);
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
