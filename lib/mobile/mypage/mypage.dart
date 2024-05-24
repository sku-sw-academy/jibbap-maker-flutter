import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/recipeview/recipeview.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/myprofile.dart';

class MyPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1, // 탭의 개수// 초기화할 탭의 인덱스 (0부터 시작)
      child: Scaffold(
        body: TabBarView(
          children: [
            MyProfile (), // 마이페이지
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.blueAccent),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.blueAccent),
                label: 'Search',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view, color: Colors.blueAccent),
                label: 'Recipe',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.redAccent),
                label: 'My Page',
                backgroundColor: Colors.limeAccent
            ),
          ],

          selectedItemColor: Colors.redAccent,

          onTap: (int index) {
            if (index == 0) {
              Navigator.pop(context);
            }
            else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            }
            else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeView()),
              );
            }
          },
        ),
      ),
    );
  }
}
