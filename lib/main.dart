// REPOSITORY
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'async_value.dart';

// REPOS
abstract class StudentRepository {
  Future<Student> addStudent({required String name, required int age});
  Future<List<Student>> getStudents();
  Future<Student> deleteStudent({required String id});
  Future<Student> updateStudent({required String id, required String name, required int age});
}

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

// class MockStudentRepository extends StudentRepository{
//   final List<Student> students = [];

//   @override
//   Future<Student> addStudent({required String name, required int age}) {
//     return Future.delayed(Duration(seconds: 1), () {
//       Student newStudent = Student(id: "0", name: 'Bing Rong', age: 19);
//       students.add(newStudent);
//       return newStudent;
//     });
//   }

//   @override
//   Future<List<Student>> getStudents() {
//     return Future.delayed(Duration(seconds: 1), () => students);
//   }
// }

// MODEL & DTO 
class StudentDto {
  static Student fromJson(String id, Map<String, dynamic> json) {
    return Student(id: id, name: json['name'], age: json['age']);
  }

  static Map<String, dynamic> toJson(Student student) {
    return {'name': student.name, 'age': student.age};
  }
}

// MODEL
class Student {
  final String id;
  final String name;
  final int age;

  Student({required this.id, required this.name, required this.age});

  @override
  bool operator ==(Object other) {
    return other is Student && other.id == id;
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode;
}

// PROVIDER
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

class App extends StatelessWidget {
  const App({super.key});
  
  // function to delete
  void _onDeletePressed(BuildContext context, String id) {
    final Studentprovider studentprovider = context.read<Studentprovider>();
    studentprovider.deleteStudent(id);
  }
  // function to update
  void _onUpdatePressed(BuildContext context, String id,String name, int age) {
    final TextEditingController nameController = TextEditingController(text: name);
    final TextEditingController ageController = TextEditingController(text: age.toString());
    final Studentprovider studentprovider = context.read<Studentprovider>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final String updatedName = nameController.text;
                final int updatedAge = int.parse(ageController.text.trim());
                if (updatedName.isNotEmpty && updatedAge >0) {
                  studentprovider.updateStudent(id, updatedName, updatedAge);
                }
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
  // function to add
  void _onAddPressed(BuildContext context) {
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final Studentprovider studentprovider = context.read<Studentprovider>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final String inputName = nameController.text;
                final int inputAge = int.parse(ageController.text.trim());
                if (inputName.isNotEmpty && inputAge >0) {
                  studentprovider.addStudent(inputName, inputAge);
                }
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );

    // function to delete
    
    // studentprovider.addStudent(nameController, ageController);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<Studentprovider>(context);

    Widget content = Text('');
    if (studentProvider.isLoading) {
      content = CircularProgressIndicator();
    } else if (studentProvider.hasData) {
      List<Student> students = studentProvider.studentsState!.data!;

      if (students.isEmpty) {
        content = Text("No data yet");
      } else {
        content = SizedBox(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder:
                (context, index) => ListTile(
                  title: Text(students[index].name),
                  subtitle: Text("${students[index].age}"),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(icon: Icon(Icons.edit,color: Colors.blue,),onPressed: ()=>_onUpdatePressed(context,students[index].id,students[index].name,students[index].age),),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _onDeletePressed(context, students[index].id)),
                      ],
                    ),
                  ),
                ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [IconButton(onPressed: () => _onAddPressed(context), icon: const Icon(Icons.add))],
      ),
      body: Center(child: content),
    );
  }
}

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
