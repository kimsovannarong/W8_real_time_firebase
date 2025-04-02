
import 'package:w8_realtime_database/model/model.dart';

abstract class StudentRepository {
  Future<Student> addStudent({required String name, required int age});
  Future<List<Student>> getStudents();
  Future<Student> deleteStudent({required String id});
  Future<Student> updateStudent({required String id, required String name, required int age});
}