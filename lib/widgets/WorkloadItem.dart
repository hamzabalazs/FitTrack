import 'package:fittrack/models/ExerciseSet.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:flutter/material.dart';

import '../models/Exercise.dart';

// ignore: must_be_immutable
class WorkloadItem extends StatefulWidget {
  final List<Exercise> exercises;
  Workload workload;
  final int index;
  final void Function(int, Workload) onUpdateWorkload;

  WorkloadItem({
    Key? key,
    required this.exercises,
    required this.workload,
    required this.index,
    required this.onUpdateWorkload,
  }) : super(key: key);

  @override
  State<WorkloadItem> createState() => _WorkloadItemState();
}

class _WorkloadItemState extends State<WorkloadItem> {
  String? selectedExerciseId;
  List<ExerciseSet> sets = [];
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];

  void _updateWorkload() {
    Workload updatedWorkload =
        Workload(exerciseId: selectedExerciseId ?? '', sets: sets);
    widget.onUpdateWorkload(widget.index, updatedWorkload);
  }

  void _removeSet(int setIndex) {
    setState(() {
      sets.removeAt(setIndex);
      _updateWorkload();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedExerciseId =
        widget.workload.exerciseId == "" ? null : widget.workload.exerciseId;
    sets = List.from(widget.workload.sets);
    for (var item in sets) {
      _repsControllers.add(TextEditingController(text: item.reps.toString()));
      _weightControllers
          .add(TextEditingController(text: item.weight.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButton<String>(
                    value: selectedExerciseId,
                    onChanged: (value) {
                      setState(() {
                        selectedExerciseId = value ?? '';
                        _updateWorkload();
                      });
                    },
                    items: widget.exercises.map((exercise) {
                      return DropdownMenuItem<String>(
                        value: exercise.id,
                        child: Text(exercise.name),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    for (var index = 0; index < sets.length; index++)
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _repsControllers[index],
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  _repsControllers[index].selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: _repsControllers[index]
                                              .text
                                              .length);
                                },
                                onChanged: (value) {
                                  setState(() {
                                    sets[index] = sets[index].copyWith(
                                      reps: int.tryParse(value) ?? 0,
                                    );
                                    _updateWorkload();
                                  });
                                },
                                decoration:
                                    const InputDecoration(labelText: 'Reps'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _weightControllers[index],
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  _weightControllers[index].selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              _weightControllers[index]
                                                  .text
                                                  .length);
                                },
                                onChanged: (value) {
                                  setState(() {
                                    sets[index] = sets[index].copyWith(
                                      weight: double.tryParse(value) ?? 0.0,
                                    );
                                    _updateWorkload();
                                  });
                                },
                                decoration:
                                    const InputDecoration(labelText: 'Weight'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeSet(index),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    sets.add(ExerciseSet(reps: 0, weight: 0));
                    _repsControllers.add(TextEditingController(text: '0'));
                    _weightControllers.add(TextEditingController(text: '0.0'));
                  });
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
