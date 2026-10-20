import 'package:flutter/material.dart';

import 'students_screen.dart';
import 'routes.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';
import 'students.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    ),
    initialRoute: Routes.students,
    routes: {Routes.students: (_) => const StudentsScreen()},
    onGenerateRoute: (settings) => switch (settings.name) {
      Routes.student => MaterialPageRoute(
        builder: (_) => DetailScreen(student: settings.arguments as Student),
      ),
      Routes.edit => MaterialPageRoute<String>(
        builder: (_) => EditScreen(student: settings.arguments as Student),
      ),
      _ => null, // unknown name
    },
  );
}
