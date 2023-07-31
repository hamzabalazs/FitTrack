import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittrack/models/Exercise.dart';
import 'package:fittrack/models/ExerciseSet.dart';
import 'package:fittrack/models/Workload.dart';
import 'package:fittrack/models/Workout.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  List<Workout> _workouts = [];
  List<Exercise> _exercises = [];
  Timestamp? selectedFirstDropdownValue;
  Timestamp? selectedSecondDropdownValue;
  Workout? firstWorkout;
  Workout? secondWorkout;

  Future<void> _fetchWorkouts() async {
    try {
      List<Workout> fetchedWorkouts = await FirebaseUtil.fetchUserWorkouts();
      setState(() {
        _workouts = fetchedWorkouts;
      });
    } catch (e) {
      throw Exception("Failed fetching user workouts!");
    }
  }

  Future<void> _fetchExercises() async {
    try {
      List<Exercise> fetchedExercises = await FirebaseUtil.fetchExercises();
      setState(() {
        _exercises = fetchedExercises;
      });
    } catch (e) {
      throw Exception("Failed fetching exercises!");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
    _fetchExercises();
  }

  int calculateTotalWeight(List<ExerciseSet> sets) {
    int totalWeight = 0;
    for (ExerciseSet set in sets) {
      totalWeight += set.reps * set.weight;
    }
    return totalWeight;
  }

  List<DropdownMenuItem<Timestamp>> _buildFirstDropdownItems() {
    List<DropdownMenuItem<Timestamp>> dropdownItems = [];

    for (var workout in _workouts) {
      dropdownItems.add(DropdownMenuItem<Timestamp>(
        value: workout.date,
        child: Text(
            "${workout.type.name} - ${DateFormat('dd/MM/yyyy').format(workout.date.toDate())}"),
      ));
    }

    return dropdownItems;
  }

  List<DropdownMenuItem<Timestamp>> _buildSecondDropdownItems() {
    List<DropdownMenuItem<Timestamp>> dropdownItems = [];
    Workout? selectedWorkout = _workouts.firstWhere(
        (element) => element.date == selectedFirstDropdownValue, orElse: () {
      return Workout(
          id: "",
          date: Timestamp.now(),
          type: WorkoutType.Other,
          userId: "",
          workloads: []);
    });
    if (selectedWorkout.id == "") return [];
    for (var workout in _workouts) {
      if (workout.type == selectedWorkout.type) {
        dropdownItems.add(DropdownMenuItem<Timestamp>(
          value: workout.date,
          child: Text(
              "${workout.type.name} - ${DateFormat('dd/MM/yyyy').format(workout.date.toDate())}"),
        ));
      }
    }
    return dropdownItems;
  }

  double getPercentage(Workload firstWorkload, Workload secondWorkload) {
    int firstWorkoutTotalWeight = calculateTotalWeight(firstWorkload.sets);
    int secondWorkoutTotalWeight = calculateTotalWeight(secondWorkload.sets);

    double percentageChange =
        ((secondWorkoutTotalWeight - firstWorkoutTotalWeight) /
                firstWorkoutTotalWeight) *
            100;
    return percentageChange.roundToDouble();
  }

  void setWorkoutsData() {
    if (selectedFirstDropdownValue != null &&
        selectedSecondDropdownValue != null) {
      setState(() {
        firstWorkout = _workouts
            .firstWhere((element) => element.date == selectedFirstDropdownValue,
                orElse: () {
          return Workout(
              id: "",
              date: Timestamp.now(),
              type: WorkoutType.Other,
              userId: "",
              workloads: []);
        });
        secondWorkout = _workouts.firstWhere(
            (element) => element.date == selectedSecondDropdownValue,
            orElse: () {
          return Workout(
              id: "",
              date: Timestamp.now(),
              type: WorkoutType.Other,
              userId: "",
              workloads: []);
        });
      });
    } else {
      setState(() {
        firstWorkout = null;
        secondWorkout = null;
      });
    }
  }

  Text percentageText(Workload firstWorkload, Workload secondWorkload) {
    if (firstWorkload.exerciseId == secondWorkload.exerciseId) {
      return Text(
        "${getPercentage(firstWorkload, secondWorkload)}%",
        style: TextStyle(
            fontSize: 16,
            color: getPercentage(firstWorkload, secondWorkload) < 0.0
                ? Colors.red
                : Colors.green),
      );
    } else {
      return const Text(
        "-.-%",
        style: TextStyle(color: Colors.grey, fontSize: 18),
      );
    }
  }

  Widget _displayOneElement(Workload firstWorkload, Workload secondWorkload) {
    List<Widget> firstColumnData = firstWorkload.sets
        .map(
          (set) => Text(
            'Reps: ${set.reps}, Weight: ${set.weight}',
            style: const TextStyle(fontSize: 16),
          ),
        )
        .toList();
    Widget secondColumnData = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: percentageText(firstWorkload, secondWorkload));

    List<Widget> thirdColumnData = secondWorkload.sets
        .map(
          (set) => Text(
            'Reps: ${set.reps}, Weight: ${set.weight}',
            style: const TextStyle(fontSize: 16),
          ),
        )
        .toList();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: FirebaseUtil.getExerciseName(
                    firstWorkload.exerciseId,
                    _exercises,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return Text(
                        snapshot.data as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                ...firstColumnData
              ],
            ),
          ),
          SizedBox(
            width: 95,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [secondColumnData],
            ),
          ),
          SizedBox(
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: FirebaseUtil.getExerciseName(
                    secondWorkload.exerciseId,
                    _exercises,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).width,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return Text(
                        snapshot.data as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                ...thirdColumnData
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _displayElements(Workout firstWorkout, Workout secondWorkout) {
    List<Widget> displayWidgetList = [];

    int firstLength = firstWorkout.workloads.length;
    int secondLength = secondWorkout.workloads.length;

    // Iterate over the first workout
    for (int i = 0; i < firstLength; i++) {
      if (i < secondLength) {
        // If both workouts have an exercise at this index, calculate the percentage
        displayWidgetList.add(
          _displayOneElement(
              firstWorkout.workloads[i], secondWorkout.workloads[i]),
        );
      } else {
        // If the second workout doesn't have an exercise at this index, add the first workout's exercise without calculating the percentage
        displayWidgetList.add(
          _displayOneElement(
              firstWorkout.workloads[i], Workload(exerciseId: "", sets: [])),
        );
      }
    }

    // If second workout has more exercises than the first workout, add the remaining exercises without calculating the percentage
    if (secondLength > firstLength) {
      for (int i = firstLength; i < secondLength; i++) {
        displayWidgetList.add(
          _displayOneElement(
              Workload(exerciseId: "", sets: []), secondWorkout.workloads[i]),
        );
      }
    }

    return displayWidgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "Choose a workout",
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
                const Text(
                  "Find out how much better you did",
                  style: TextStyle(fontSize: 16.0),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 161,
                            height: 40,
                            child: DropdownButton<Timestamp>(
                              value: selectedFirstDropdownValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedFirstDropdownValue = value;
                                  selectedSecondDropdownValue = null;
                                  setWorkoutsData();
                                });
                              },
                              items: _buildFirstDropdownItems(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 161,
                            height: 40,
                            child: DropdownButton<Timestamp>(
                              value: selectedSecondDropdownValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedSecondDropdownValue = value;
                                  setWorkoutsData();
                                });
                              },
                              items: _buildSecondDropdownItems(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((firstWorkout != null && secondWorkout != null))
                  ..._displayElements(firstWorkout!, secondWorkout!)
              ],
            ),
          )
        ]),
      ),
    );
  }
}
