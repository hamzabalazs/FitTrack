import 'package:flutter/material.dart';

import '../models/Exercise.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  Future<Image> _buildExerciseImage(String gif, BuildContext context) async {
    if (gif.isNotEmpty) {
      final image = Image.network(
        gif,
        height: MediaQuery.sizeOf(context).height / 2,
        width: 400,
      );
      await precacheImage(image.image, context);
      return image;
    } else {
      return Image.asset(
        'assets/images/default-pic.png',
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
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height / 2,
                      width: 400,
                      child: const Center(child: CircularProgressIndicator()),
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
