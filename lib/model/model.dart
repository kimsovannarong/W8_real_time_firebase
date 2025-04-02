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