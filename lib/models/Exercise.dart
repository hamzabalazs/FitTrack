import 'package:flutter/material.dart';

class Exercise {
  String id;
  String name;
  String description;
  String gif;
  ExerciseDifficulty difficulty;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.gif,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'gif': gif,
      'difficulty': difficulty.toString().split('.').last,
    };
  }

  Color getColorByDifficulty(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.Easy:
        return Colors.green;
      case ExerciseDifficulty.Medium:
        return Colors.amber;
      case ExerciseDifficulty.Hard:
        return Colors.red;
    }
  }
}

// ignore: constant_identifier_names
enum ExerciseDifficulty { Easy, Medium, Hard }
