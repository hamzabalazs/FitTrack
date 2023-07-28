import 'package:fittrack/models/Workout.dart';
import 'package:flutter/material.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FITTRACK'),
      ),
    );
  }
}
