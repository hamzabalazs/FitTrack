import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittrack/screens/login_screen.dart';
import 'package:fittrack/utils/ErrorDialog.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isValidEmail(String email) {
      String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
      RegExp regExp = RegExp(emailPattern);
      return regExp.hasMatch(email);
    }

    void navigateToLogin() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    Future<void> addUserToFirestore(
      String id,
      String firstName,
      String lastName,
      String email,
    ) async {
      try {
        await FirebaseFirestore.instance.collection('users').doc(id).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'role': "USER",
        });
      } catch (e) {
        throw Exception("Error adding user to Firestore: $e");
      }
    }

    Future<void> registerUser(String email, String password,
        String confirmPassword, String firstName, String lastName) async {
      if (!isValidEmail(email)) {
        ErrorDialog.showErrorDialog(context, "Invalid email format!");
      }
      if (password != confirmPassword) {
        ErrorDialog.showErrorDialog(context, "Passwords do not match!");
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;
        if (user != null) {
          await addUserToFirestore(user.uid, firstName, lastName, email);
          navigateToLogin();
        }
      } catch (e) {
        throw Exception("Error registering user: $e");
      }
    }

    Container registerTextField(
        String hintText, TextEditingController controller, bool isPassword) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              hintStyle: const TextStyle(color: Colors.black),
              hintText: hintText,
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
            title: const Text('FITTRACK'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        body: SingleChildScrollView(
          child: SizedBox(
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
                    const SizedBox(height: 12),
                    registerTextField(
                        "First Name", _firstNameController, false),
                    const SizedBox(height: 10),
                    registerTextField("Last Name", _lastNameController, false),
                    const SizedBox(height: 10),
                    registerTextField("Email", _emailController, false),
                    const SizedBox(height: 10),
                    registerTextField("Password", _passwordController, true),
                    const SizedBox(height: 10),
                    registerTextField(
                        "Confirm password", _confirmPasswordController, true),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        String firstName = _firstNameController.text;
                        String lastName = _lastNameController.text;
                        String email = _emailController.text;
                        String password = _passwordController.text;
                        String confirmPassword =
                            _confirmPasswordController.text;
                        registerUser(email, password, confirmPassword,
                            firstName, lastName);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
