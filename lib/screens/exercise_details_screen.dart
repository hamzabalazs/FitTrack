import 'package:flutter/material.dart';

import '../models/Exercise.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  Future<void> _delayedGifLoad() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  Image _buildExerciseImage(String gif) {
    if (gif.isNotEmpty) {
      return Image.network(
        gif,
        height: 400,
        width: 400,
      );
    } else {
      return Image.network(
        'https://firebasestorage.googleapis.com/v0/b/fittrack-5c86e.appspot.com/o/default-pic.png?alt=media&token=45f6fd9d-0b7e-4720-9895-45de4d5c5137',
        height: 400,
        width: 400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FITTRACK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(exercise.description, style: const TextStyle(fontSize: 16)),
              //_buildExerciseImage(exercise.gif),
              FutureBuilder<void>(
                future: _delayedGifLoad(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 400,
                      width: 400,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return _buildExerciseImage(exercise.gif);
                  }
                },
              ),
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
                        color:
                            exercise.getColorByDifficulty(exercise.difficulty),
                      ),
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
