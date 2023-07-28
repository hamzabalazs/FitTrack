import 'package:firebase_core/firebase_core.dart';
import 'package:fittrack/firebase_options.dart';
import 'package:flutter/material.dart';
import './screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fittrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.blueAccent,
            brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.dark(
              background: Colors.grey.shade900,
              primary: Colors.grey.shade300,
              secondary: Colors.grey.shade700)),
      themeMode: ThemeMode.dark,
      home: LoginScreen(),
    );
  }
}
