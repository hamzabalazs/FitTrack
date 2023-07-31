import 'package:flutter/material.dart';

import '../models/Exercise.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  Future<Image> _buildExerciseImage(String gif, BuildContext context) async {
    if (gif.isNotEmpty) {
      final image = Image.network(
        gif,
        height: 400,
        width: 400,
      );
      await precacheImage(image.image, context);
      return image;
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
              FutureBuilder<Image>(
                future: _buildExerciseImage(exercise.gif, context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 400,
                      width: 400,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Error loading image!');
                  } else {
                    return snapshot.data!;
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
