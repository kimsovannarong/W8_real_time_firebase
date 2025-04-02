import 'package:flutter/material.dart';
import 'package:w8_realtime_database/model/model.dart';
import 'package:w8_realtime_database/repo/student_repository.dart';
import 'package:w8_realtime_database/utils/async_value.dart';

class Studentprovider extends ChangeNotifier {
  final StudentRepository _repository;
  AsyncValue<List<Student>>? studentsState;

  Studentprovider(this._repository) {
    fetchUsers();
  }

  bool get isLoading => studentsState != null && studentsState!.state == AsyncValueState.loading;
  bool get hasData => studentsState != null && studentsState!.state == AsyncValueState.success;

  void fetchUsers() async {
    try {
      // 1- loading state
      studentsState = AsyncValue.loading();
      notifyListeners();

      // 2 - Fetch users
      List<Student> students = await _repository.getStudents();

      studentsState = AsyncValue.success(students);

      // print("SUCCESS: list size ${studentsState!.data!.length.toString()}");

      // 3 - Handle errors
    } catch (error) {
      // print("ERROR: $error");
      studentsState = AsyncValue.error(error);
    }

    notifyListeners();
  }

  void addStudent(String name, int age) async {
    // 1- Call repo to add
    await _repository.addStudent(name: name, age: age);

    // 2- Call repo to fetch
    fetchUsers();
  }

  void deleteStudent(String id) async {
    // 1- Call repo to delete
    await _repository.deleteStudent(id: id);

    // 2- Call repo to fetch
    fetchUsers();
  }
  void updateStudent(String id, String name, int age) async {
    // 1- Call repo to update
    await _repository.updateStudent(id: id, name: name, age: age);

    // 2- Call repo to fetch
    fetchUsers();
  }
}