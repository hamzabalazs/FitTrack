import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';
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

  void _removeWorkloadItem(int index) {
    setState(() {
      workloadItems.removeAt(index);
    });
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
              child: Column(children: [
                for (var index = 0; index < workloadItems.length; index++)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeWorkloadItem(index),
                      ),
                      Expanded(child: workloadItems[index]),
                    ],
                  ),
              ]),
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
                final isSuccess = await FirebaseUtil.addWorkout(
                    workloadItems, selectedType, currentUser?.uid, context);
                if (isSuccess) {
                  await widget.onWorkoutAdded();
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
