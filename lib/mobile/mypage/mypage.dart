import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/recipeview/recipeview.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/myprofile.dart';

class MyPage extends StatefulWidget{

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

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
              icon: Icon(Icons.home, color: Colors.grey),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.grey),
                label: 'Search',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.food_bank, color: Colors.grey),
                label: 'Recipe',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.black),
                label: 'My Page',
                backgroundColor: Colors.white
            ),
          ],

          selectedItemColor: Colors.black,

          onTap: (int index) {
            if (index == 0) {
              Navigator.pop(context);
            }
            else if (index == 1) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => SearchPage(),
                  transitionsBuilder: (context, animation1, animation2, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation1),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 400),
                ),
              ).then((value) => setState(() {
              }));
            }
            else if (index == 2) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => RecipeView(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 400),
                ),
              ).then((value) => setState(() {
              }));
            }
          },
        ),
      ),
    );
  }
}
