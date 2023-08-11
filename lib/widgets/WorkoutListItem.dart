import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/screens/workout_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutListItem extends StatelessWidget {
  final Workout workout;
  final Future<void> Function() onWorkoutChanged;

  const WorkoutListItem(
      {super.key, required this.workout, required this.onWorkoutChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${workout.type.name} workout',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(DateFormat('dd/MM/yyyy').format(workout.date.toDate())),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailsScreen(
                  workout: workout, onWorkoutChanged: onWorkoutChanged),
            ),
          );
        },
      ),
    );
  }
}
