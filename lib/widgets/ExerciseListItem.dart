import 'package:flutter/material.dart';

import '../models/Exercise.dart';
import '../screens/exercise_details_screen.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;

  const ExerciseListItem({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailsScreen(exercise: exercise),
            ),
          );
        },
        titleTextStyle: const TextStyle(fontSize: 32),
        subtitleTextStyle: const TextStyle(fontSize: 18),
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.description),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Difficulty: ',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  TextSpan(
                    text: exercise.difficulty.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 18,
                      color: exercise.getColorByDifficulty(exercise.difficulty),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
