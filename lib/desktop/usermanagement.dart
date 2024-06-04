import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<Map<String, String>> users = List.generate(10, (index) => {
    'id': 'ID_$index',
    'name': 'User $index',
    'email': 'user$index@example.com',
  });

  void _addUser() {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  users.add({
                    'id': idController.text,
                    'name': nameController.text,
                    'email': emailController.text,
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: DataTable2(
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user['id']!)),
                    DataCell(Text(user['name']!)),
                    DataCell(Text(user['email']!)),
                    DataCell(Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Edit action
                          },
                          child: Text('Edit'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Delete action
                            setState(() {
                              users.remove(user);
                            });
                          },
                          child: Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),

        ],
      ),
    );
  }
}