import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
import 'package:fittrack/widgets/WorkloadItem.dart';
import 'package:flutter/material.dart';

class EditWorkoutScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final Workout workout;
  final Future<void> Function() onWorkoutChanged;
  const EditWorkoutScreen(
      {Key? key,
      required this.onWorkoutChanged,
      required this.workout,
      required this.exercises})
      : super(key: key);

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  WorkoutType selectedType = WorkoutType.Pull;
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<WorkloadItem> workloadItems = [];

  @override
  void initState() {
    super.initState();
    workloadItems =
        buildWorkloadItems(widget.exercises, widget.workout.workloads);
  }

  List<WorkloadItem> buildWorkloadItems(
      List<Exercise> exercises, List<Workload> workloads) {
    List<WorkloadItem> workloadItemList = [];
    for (var item in workloads) {
      workloadItemList.add(
        WorkloadItem(
          key: Key(workloadItems.length.toString()),
          exercises: exercises,
          workload: Workload(exerciseId: item.exerciseId, sets: item.sets),
          index: workloadItems.length,
          onUpdateWorkload: (index, updatedWorkload) =>
              updateWorkload(index, updatedWorkload),
        ),
      );
    }
    return workloadItemList;
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
          exercises: widget.exercises,
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
      appBar: AppBar(title: const Text("Edit Workout")),
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
                final isSuccess = await FirebaseUtil.editWorkout(
                    widget.workout, workloadItems, selectedType, context);
                if (isSuccess) {
                  await widget.onWorkoutChanged();
                  if (!mounted) return;
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text('Edit Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
