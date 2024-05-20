import 'package:flutter/material.dart';
import 'package:flutter_splim/search/search.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('MyProfile'),
        backgroundColor: Colors.blue,
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
                    radius: 50,
                      // 프로필 사진 URL
                  ),

                  SizedBox(width: screenWidth / 100),

                  Column(
                    children: [
                      Text(
                        '닉네임', // 여기에 닉네임을 넣어주세요
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: screenHeight / 80),

                      Text(
                        '이메일: ', // 여기에 닉네임을 넣어주세요
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
              top: screenHeight / 100),
              child: Text(
                "Notification",
                style: TextStyle(fontSize: 24),
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
                  top: screenHeight / 100),
              child: Text(
                "My Account Information",
                style: TextStyle(fontSize: 24),
              ),

            ),

            ListTile(
              title: Text("프로필 수정"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),

            Divider(),

            ListTile(
              title: Text("비밀번호 변경"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),

            Container(
              color: Color(0x1FB9A2A2),
              width: double.infinity,
              height: screenHeight / 15,
              padding: EdgeInsets.only(left: screenWidth / 40,
                  top: screenHeight / 100),
              child: Text(
                "My custom",
                style: TextStyle(fontSize: 24),
              ),

            ),

            ListTile(
                title: Text("레시피"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),

            Divider(),

            ListTile(
                title: Text("식재료"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),

            Container(
              color: Color(0x1FB9A2A2),
              width: double.infinity,
              height: screenHeight / 15,
              padding: EdgeInsets.only(left: screenWidth / 40,
                  top: screenHeight / 100),
              child: Text(
                "Support",
                style: TextStyle(fontSize: 24),
              ),

            ),

            ListTile(
                title: Text("고객센터"),
                trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {

              },
            ),

            Divider(),

            Center(
              child: Container(
                width: screenWidth / 5, // 버튼의 폭 설정
                height: screenHeight / 15,
                color: Colors.white,
                margin: EdgeInsets.only(top: screenHeight / 60),
                child: ElevatedButton(
                  onPressed: () {
                    // 버튼 동작 추가
                  },
                  child: Text("Log out", style: TextStyle(color: Colors.black),),
                ),
              ),
            ),

          ],
      ),
    );
  }
}