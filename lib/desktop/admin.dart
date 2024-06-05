import 'package:flutter/material.dart';
import 'package:flutter_splim/desktop/usermanagement.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    UserManagementPage(),
    Text('식재료'),  // 예제용 설정 페이지
    Text('FAQ'),
    Text('답변'),
    Text('공지사항'),
    Text('레시피 목록'),
    Text('로그'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();  // Drawer를 닫기 위해
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('사용자'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.food_bank_outlined),
              title: Text('식재료'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text('FAQ'),
              onTap: () => _onItemTapped(2),
            ),ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('답변'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.speaker_notes),
              title: Text('공지사항'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('레시피 목록'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: Icon(Icons.timelapse),
              title: Text('로그'),
              onTap: () => _onItemTapped(6),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

