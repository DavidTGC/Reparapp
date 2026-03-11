import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';

void main() {
  runApp(const ReparappApp());
}

class ReparappApp extends StatelessWidget {
  const ReparappApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reparapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[600],
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/tasks': (context) => TasksScreen(),
      },
    );
  }
}
