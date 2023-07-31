import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/utils/ErrorDialog.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
import 'package:fittrack/widgets/WorkloadItem.dart';
import 'package:flutter/material.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Future<void> Function() onWorkoutAdded;
  const AddWorkoutScreen({Key? key, required this.onWorkoutAdded})
      : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  List<Exercise> _exercises = [];
  WorkoutType selectedType = WorkoutType.Pull;
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<WorkloadItem> workloadItems = [];

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
    _fetchExercises();
  }

  void updateWorkload(int index, Workload updatedWorkload) {
    setState(() {
      workloadItems[index].workload = updatedWorkload;
    });
  }

  void _addWorkloadItem() {
    setState(() {
      workloadItems.add(
        WorkloadItem(
          key: Key(workloadItems.length.toString()),
          exercises: _exercises,
          workload: Workload(exerciseId: '', sets: []),
          index: workloadItems.length,
          onUpdateWorkload: (index, updatedWorkload) =>
              updateWorkload(index, updatedWorkload),
        ),
      );
    });
  }

  Future<void> _addWorkout() async {
    try {
      List<Workload> workloads = [];

      for (var item in workloadItems) {
        Workload workloadData = item.workload;
        workloads.add(workloadData);
      }

      final newWorkout = Workout(
          id: "placeholder",
          date: Timestamp.now(),
          type: selectedType,
          userId: currentUser?.uid ?? "",
          workloads: workloads);

      await FirebaseFirestore.instance
          .collection('workouts')
          .add(newWorkout.toMap());
    } catch (e) {
      ErrorDialog.showErrorDialog(context, "Failed to add workout!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add new Workout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: workloadItems
                    .map((workloadItem) => Container(
                          child: workloadItem,
                        ))
                    .toList(),
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DropdownButton<WorkoutType>(
                    value: selectedType,
                    onChanged: (WorkoutType? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: WorkoutType.values.map((type) {
                      return DropdownMenuItem<WorkoutType>(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  onPressed: _addWorkloadItem,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                _addWorkout();
                await widget.onWorkoutAdded();
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Add Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
