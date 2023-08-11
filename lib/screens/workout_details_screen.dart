import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/screens/edit_workout_screen.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final Workout workout;
  final Future<void> Function() onWorkoutChanged;

  const WorkoutDetailsScreen(
      {super.key, required this.workout, required this.onWorkoutChanged});

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  List<Exercise> _exercises = [];

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
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500))
        .then((_) => _fetchExercises());
  }

  void _editWorkout() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditWorkoutScreen(
                exercises: _exercises,
                workout: widget.workout,
                onWorkoutChanged: widget.onWorkoutChanged)));
  }

  void _deleteWorkout() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      final isSuccess = await FirebaseUtil.deleteWorkout(widget.workout.id);
      if (isSuccess) {
        await widget.onWorkoutChanged();
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.workout.type.name} workout'.toUpperCase()),
        ),
        body: const SizedBox(child: Center(child: CircularProgressIndicator())),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.workout.type.name} workout'.toUpperCase()),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        '${widget.workout.type.name} workout',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(widget.workout.date.toDate()),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                for (var workload in widget.workout.workloads)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: FirebaseUtil.getExerciseName(
                          workload.exerciseId,
                          _exercises,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: MediaQuery.sizeOf(context).height,
                              width: MediaQuery.sizeOf(context).width,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return Text(
                              snapshot.data as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      for (var set in workload.sets)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Reps: ${set.reps}, Weight: ${set.weight}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _editWorkout,
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _deleteWorkout,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
