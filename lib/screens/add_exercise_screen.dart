import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
import 'package:flutter/material.dart';

class AddExerciseScreen extends StatefulWidget {
  final Future<void> Function() onExerciseAdded;
  const AddExerciseScreen({Key? key, required this.onExerciseAdded})
      : super(key: key);

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _gifUrlController = TextEditingController();

  ExerciseDifficulty selectedDifficulty = ExerciseDifficulty.Easy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add New Exercise'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 2),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 2),
              TextField(
                controller: _gifUrlController,
                decoration: const InputDecoration(labelText: 'Gif Url'),
              ),
              const SizedBox(height: 2),
              DropdownButton<ExerciseDifficulty>(
                value: selectedDifficulty,
                onChanged: (ExerciseDifficulty? newValue) {
                  setState(() {
                    selectedDifficulty = newValue!;
                  });
                },
                items: ExerciseDifficulty.values.map((difficulty) {
                  return DropdownMenuItem<ExerciseDifficulty>(
                    value: difficulty,
                    child: Text(difficulty.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 2),
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseUtil.addExercise(
                        _nameController.text,
                        _descriptionController.text,
                        _gifUrlController.text,
                        selectedDifficulty);
                    await widget.onExerciseAdded();
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Add Exercise'))
            ],
          ),
        ));
  }
}
