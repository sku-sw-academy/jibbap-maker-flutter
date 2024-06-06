import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

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
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Scrollbar(
                child: TableView.builder(
                  columnCount: 4,
                  rowCount: users.length + 1,
                  pinnedRowCount: 1,
                  pinnedColumnCount: 0,
                  columnBuilder: (index) {
                    double extent;
                    switch (index) {
                      case 0:
                      case 1:
                      case 2:
                        extent = 0.25; // equal width for ID, Name, Email
                        break;
                      case 3:
                        extent = 0.25; // equal width for Actions
                        break;
                      default:
                        extent = 1 / 4;
                        break;
                    }
                    return TableSpan(
                      foregroundDecoration: index == 0 ? decoration : null,
                      extent: FractionalTableSpanExtent(extent),
                    );
                  },
                  rowBuilder: (index) {
                    return TableSpan(
                      foregroundDecoration: index == 0 ? decoration : null,
                      extent: FixedTableSpanExtent(50),
                    );
                  },
                  cellBuilder: (context, vicinity) {
                    final isStickyHeader = vicinity.yIndex == 0;
                    String label = '';
                    Widget content;
                    TextStyle textStyle = const TextStyle();

                    if (isStickyHeader) {
                      switch (vicinity.xIndex) {
                        case 0:
                          label = 'ID';
                          break;
                        case 1:
                          label = 'Name';
                          break;
                        case 2:
                          label = 'Email';
                          break;
                        case 3:
                          label = 'Actions';
                          break;
                      }
                      content = Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      );
                    } else {
                      final user = users[vicinity.yIndex - 1];
                      switch (vicinity.xIndex) {
                        case 0:
                          label = user['id']!;
                          content = Text(label);
                          break;
                        case 1:
                          label = user['name']!;
                          content = Text(label);
                          break;
                        case 2:
                          label = user['email']!;
                          content = Text(label);
                          break;
                        case 3:
                          content = Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _addUser();
                                },
                                child: Text('Edit'),
                              ),

                            ],
                          );
                          break;
                      }
                    }

                    return TableViewCell(
                      child: ColoredBox(
                        color: isStickyHeader ? Colors.transparent : colorScheme.background,
                        child: Center(
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                label,
                                style: isStickyHeader
                                    ? TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                )
                                    : textStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
