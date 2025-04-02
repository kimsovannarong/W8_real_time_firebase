import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:w8_realtime_database/dto/student_dto.dart';
import 'package:w8_realtime_database/model/model.dart';
import 'package:w8_realtime_database/repo/student_repository.dart';

class FirebaseStudentRepository extends StudentRepository {
  static const String baseUrl = 'https://w8-crud-default-rtdb.asia-southeast1.firebasedatabase.app/';
  static const String studentCollection = "Students";
  static const String allStudentsUrl = '$baseUrl/$studentCollection.json';

  @override
  Future<Student> addStudent({required String name, required int age}) async {
    Uri uri = Uri.parse(allStudentsUrl);

    // Create a new data
    final newStudentData = {'name': name, 'age': age};
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newStudentData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add user');
    }

    // Firebase returns the new ID in 'name'
    final newId = json.decode(response.body)['name'];

    // Return created user
    return Student(id: newId, name: name, age: age);
  }

  @override
  Future<List<Student>> getStudents() async {
    Uri uri = Uri.parse(allStudentsUrl);
    final http.Response response = await http.get(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load');
    }

    // Return all users
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];
    return data.entries.map((entry) => StudentDto.fromJson(entry.key, entry.value)).toList();
  }
  @override
  Future<Student> deleteStudent({required String id}) async {
    Uri uri = Uri.parse('$baseUrl/$studentCollection/$id.json');
    final http.Response response = await http.delete(uri);

    // Handle errors
    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
      throw Exception('Failed to delete user');
    }

    // Return deleted user
    return Student(id: id, name: '', age: 0);
  }
  @override
  Future<Student> updateStudent({required String id, required String name, required int age}) async {
    Uri uri = Uri.parse('$baseUrl/$studentCollection/$id.json');
    final newStudentData = {'name': name, 'age': age};
    final http.Response response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newStudentData),
    );

    // Handle errors
    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
      throw Exception('Failed to update user');
    }

    // Return updated user
    return Student(id: id, name: name, age: age);
  }
}