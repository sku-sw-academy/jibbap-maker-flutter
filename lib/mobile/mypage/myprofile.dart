import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/prefer.dart';
import 'package:flutter_splim/mobile/mypage/changeprofile.dart';
import 'package:flutter_splim/mobile/mypage/changepassword.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/center.dart';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'package:flutter_splim/mobile/mypage/recipe/recipelist.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool _switchValue = false;
  final String nickname = '닉네임';
  final String email = 'test@example.com';
  final SecureService _secureService = SecureService();
  late UserDTO _userDTO;
  String key = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('MyProfile'),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),

      body: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue[200],
                    child: Icon(Icons.person, color: Colors.grey, size: 70),
                      // 프로필 사진 URL
                  ),

                  SizedBox(width: screenWidth / 50),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nickname}', // 여기에 닉네임을 넣어주세요
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: screenHeight / 80),

                      Text(
                        '이메일: ${email}', // 여기에 닉네임을 넣어주세요
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              color: Color(0x1FB9A2A2),
              width: double.infinity,
              height: screenHeight / 15,
              padding: EdgeInsets.only(left: screenWidth / 40,
              top: screenHeight / 90),
              child: Text(
                "Notification",
                style: TextStyle(fontSize: 20),
              ),

            ),

            SwitchListTile(
                value: _switchValue,
                title: Text("알림"),
                onChanged: (bool value){
                  setState(() {
                    _switchValue = value;
                  });
                }
            ),

            Container(
              color: Color(0x1FB9A2A2),
              width: double.infinity,
              height: screenHeight / 15,
              padding: EdgeInsets.only(left: screenWidth / 40,
                  top: screenHeight / 90),
              child: Text(
                "My Account Information",
                style: TextStyle(fontSize: 20),
              ),

            ),

            ListTile(
              title: Text("프로필 수정"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChangeProfilePage()),
                );
              },
            ),

            Divider(),

            ListTile(
              title: Text("비밀번호 변경"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),

            Container(
              color: Color(0x1FB9A2A2),
              width: double.infinity,
              height: screenHeight / 15,
              padding: EdgeInsets.only(left: screenWidth / 40,
                  top: screenHeight / 90),
              child: Text(
                "My Custom",
                style: TextStyle(fontSize: 20),
              ),

            ),

            ListTile(
                title: Text("레시피"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifyPage()),
                );
              },
            ),

            Divider(),

            ListTile(
                title: Text("식재료"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyPrefer()),
                );
              },
            ),

            Container(
              color: Color(0x1FB9A2A2),
              width: double.infinity,
              height: screenHeight / 15,
              padding: EdgeInsets.only(left: screenWidth / 40,
                  top: screenHeight / 90),
              child: Text(
                "Support",
                style: TextStyle(fontSize: 20),
              ),

            ),

            ListTile(
                title: Text("고객센터"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CenterPage()),
                );
              },
            ),

            Divider(),

            Center(
              child: Container(
                width: screenWidth / 3, // 버튼의 폭 설정
                height: screenHeight / 15,
                color: Colors.white,
                margin: EdgeInsets.only(top: screenHeight / 80, bottom: screenHeight / 80),
                child: ElevatedButton(
                  onPressed: () async {
                    await _secureService.deleteToken(key);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                    ),
                    side: BorderSide(color: Colors.black, width: 1),
                    fixedSize: Size(80, 30),
                    // 다른 스타일 속성들...
                  ),
                  child: Text("Log out", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
      ),
    );
  }
}