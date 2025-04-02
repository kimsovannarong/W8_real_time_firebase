// REPOSITORY

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w8_realtime_database/provider/student_provider.dart';
import 'package:w8_realtime_database/repo/firebase_repository.dart';
import 'package:w8_realtime_database/repo/student_repository.dart';
import 'package:w8_realtime_database/view/student_list_screen.dart';



// 5 - MAIN
void main() async {
  // 1 - Create repository
  final StudentRepository studentRepository = FirebaseStudentRepository();

  // 2-  Run app
  runApp(
    ChangeNotifierProvider(
      create: (context) => Studentprovider(studentRepository),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: App()),
    ),
  );
}
