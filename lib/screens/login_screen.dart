import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/screens/home_screen.dart';
import 'package:fittrack/screens/register_screen.dart';
import 'package:flutter/material.dart';

import '../utils/ErrorDialog.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  Stream<User?>? _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream!.listen((user) {
      if (user != null) {
        navigateToMain();
      }
    });
  }

  void navigateToMain() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    void login(String email, String password) async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        if (user != null) {
          navigateToMain();
        } else {
          throw Exception("Failed to login user.");
        }
      } catch (e) {
        ErrorDialog.showErrorDialog(context, "Invalid credentials!");
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
          title: const Text('FITTRACK'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FITTRACK',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        hintText: 'Email',
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        hintText: 'Password',
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    login(email, password);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
