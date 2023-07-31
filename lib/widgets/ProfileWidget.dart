import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/models/UserProfile.dart';
import 'package:fittrack/screens/login_screen.dart';
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
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        setState(() {
          currentUser = UserProfile(
              email: documentSnapshot['email'],
              firstName: documentSnapshot['firstName'],
              lastName: documentSnapshot['lastName'],
              role: documentSnapshot['role']);
        });
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> _getNumberOfWorkouts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      setState(() {
        numberOfWorkouts = querySnapshot.docs.length;
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
