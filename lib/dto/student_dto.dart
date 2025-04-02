import 'package:w8_realtime_database/model/model.dart';

class StudentDto {
  static Student fromJson(String id, Map<String, dynamic> json) {
    return Student(id: id, name: json['name'], age: json['age']);
  }

  static Map<String, dynamic> toJson(Student student) {
    return {'name': student.name, 'age': student.age};
  }
}