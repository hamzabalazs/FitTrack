import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/UserProfile.dart';
import 'package:fittrack/screens/login_screen.dart';
import 'package:fittrack/utils/FirebaseUtil.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  UserProfile? currentUser;
  int numberOfWorkouts = 0;

  Future<void> _getUser() async {
    try {
      UserProfile? user = await FirebaseUtil.getUser(
          FirebaseAuth.instance.currentUser?.uid ?? "");
      if (user != null) {
        setState(() {
          currentUser = user;
        });
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> _getNumberOfWorkouts() async {
    try {
      int workoutsNum = await FirebaseUtil.getNumberOfWorkouts(
          FirebaseAuth.instance.currentUser?.uid ?? "");
      setState(() {
        numberOfWorkouts = workoutsNum;
      });
    } catch (e) {
      throw Exception("Failed to fetch number of workouts");
    }
  }

  void logOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    _getNumberOfWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Name: ${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Email: ${currentUser?.email ?? ''}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Number of Workouts: $numberOfWorkouts',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Role: ${currentUser?.role ?? ''}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
              child: ElevatedButton(
                onPressed: logOut,
                child: const Text('Logout'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
