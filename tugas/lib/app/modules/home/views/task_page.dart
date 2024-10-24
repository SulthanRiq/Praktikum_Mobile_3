import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final CollectionReference tasksCollection = FirebaseFirestore.instance.collection('tasks');

  final TextEditingController _taskController = TextEditingController();

  // Function to add a new task
  Future<void> _addTask(String title) async {
    await tasksCollection.add({
      'title': title,
    });
  }

  // Function to edit a task
  Future<void> _editTask(String id, String title) async {
    await tasksCollection.doc(id).update({
      'title': title,
    });
  }

  // Function to delete a task
  Future<void> _deleteTask(String id) async {
    await tasksCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Enter Task'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                _addTask(_taskController.text);
                _taskController.clear();
              }
            },
            child: const Text('Add Task'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: tasksCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final tasks = snapshot.data!.docs.map((doc) {
                  return Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) async {
                          if (value == 'edit') {
                            _showEditDialog(task);
                          } else if (value == 'delete') {
                            _deleteTask(task.id);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to show dialog for editing task
  void _showEditDialog(Task task) {
    _taskController.text = task.title;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(labelText: 'Edit Task'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  _editTask(task.id, _taskController.text);
                  Navigator.of(context).pop();
                  _taskController.clear();
                }
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
