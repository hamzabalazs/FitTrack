import 'package:fittrack/widgets/DashboardWidget.dart';
import 'package:fittrack/widgets/ExercisesWidget.dart';
import 'package:fittrack/widgets/ProfileWidget.dart';
import 'package:fittrack/widgets/WorkoutsWidget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isNavigating = false;

  static const List<Widget> _pages = <Widget>[
    DashboardWidget(),
    ExercisesWidget(),
    WorkoutsWidget(),
    ProfileWidget(),
  ];

  void _onItemTapped(int index) async {
    if (isNavigating) return;
    setState(() {
      _selectedIndex = index;
      isNavigating = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(
      () {
        isNavigating = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FITTRACK'),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_martial_arts),
            label: 'My Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
