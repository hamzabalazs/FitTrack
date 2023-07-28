import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittrack/models/Workload.dart';

class Workout {
  final String id;
  final String userId;
  final WorkoutType type;
  final List<Workload> workloads;
  final Timestamp date;

  Workout({
    required this.id,
    required this.userId,
    required this.type,
    required this.workloads,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> workloadsData =
        workloads.map((workload) => workload.toMap()).toList();
    return {
      'userId': userId,
      'type': type.name,
      'date': date,
      'workloads': workloadsData
    };
  }
}

// ignore: constant_identifier_names
enum WorkoutType { Push, Pull, Legs }
