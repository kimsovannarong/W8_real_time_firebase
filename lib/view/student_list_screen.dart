import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w8_realtime_database/model/model.dart';
import 'package:w8_realtime_database/provider/student_provider.dart';

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
        content = ListView.builder(
          itemCount: students.length,
          itemBuilder:
              (context, index) => ListTile(
                title: Text(students[index].name),
                subtitle: Text("${students[index].age}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.edit,color: Colors.blue,),onPressed: ()=>_onUpdatePressed(context,students[index].id,students[index].name,students[index].age),),
                    IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _onDeletePressed(context, students[index].id)),
                  ],
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