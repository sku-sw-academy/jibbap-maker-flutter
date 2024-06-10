import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/AuthLogoutRequest.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/prefer.dart';
import 'package:flutter_splim/mobile/mypage/changeprofile.dart';
import 'package:flutter_splim/mobile/mypage/changepassword.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/center.dart';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'package:flutter_splim/mobile/mypage/recipeList.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/service/userservice.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_splim/mobile/home/notification.dart';
import 'package:flutter_splim/provider/notificationProvider.dart';
import 'package:badges/badges.dart' as badges;

final FlutterLocalNotificationsPlugin notiPlugin = FlutterLocalNotificationsPlugin();

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool _switchValue = false;
  final SecureService _secureService = SecureService();
  late UserDTO? user;
  late UserDTO? userdto;
  final UserService userService = UserService();
  String access = "accessToken";
  String refresh = "refreshToken";
  String fcm = "fcmToken";
  late int userId;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    // 사용자 정보 불러오기
    UserDTO? user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      _switchValue = user?.push ?? false;
      userId = user!.id;
    });
  }

  Future<void> _updatePushSettings(bool value) async {
    String? token = await _secureService.readToken(fcm);
    if (token != null) {
      user = Provider.of<UserProvider>(context, listen: false).user;
      userdto = user;
      userdto!.push = value;
      userdto!.fcmtoken = token;
      await userService.updateUserPushSettings(userdto!);
      user!.push = value;
      user!.fcmtoken = token;
      Provider.of<UserProvider>(context, listen: false).updateUser(user!);
      setState(() {
        _switchValue = value;
      });
    }
  }

  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _updatePushSettings(true);
    } else {
      setState(() {
        _switchValue = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    UserDTO? user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'My Page',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return badges.Badge(
                badgeContent: Text(
                  notificationProvider.notificationCount.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                showBadge: notificationProvider.notificationCount > 0,
                child: IconButton(
                  icon: Icon(notificationProvider.notificationCount > 0 ? Icons.notifications : Icons.notifications_none,),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationListPage(userId: userId),
                      ),
                    ).then((value) => setState(() {
                      Provider.of<NotificationProvider>(context, listen: false).resetCount();
                    }));
                  },
                ),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              ).then((value) => setState(() {}));
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
                  backgroundImage: user != null &&
                      user!.profile != null &&
                      user!.profile!.isNotEmpty
                      ? NetworkImage(
                      "${Constants.baseUrl}/api/auth/images/${user!.profile!}")
                      : null, // 빈 값을 사용하여 배경 이미지가 없음을 나타냄
                  child: user != null &&
                      user!.profile != null &&
                      user!.profile!.isNotEmpty
                      ? null // 프로필 이미지가 있는 경우에는 아이콘을 표시하지 않음
                      : Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ), // 프로필 이미지가 없는 경우에 아이콘을 표시
                ),
                SizedBox(width: screenWidth / 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.nickname ?? ''}', // 여기에 닉네임을 넣어주세요
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight / 80),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Color(0x1FB9A2A2),
            width: double.infinity,
            height: screenHeight / 15,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "Notification",
              style: TextStyle(fontSize: 20),
            ),
          ),
          SwitchListTile(
              value: _switchValue,
              title: Text("알림"),
              onChanged: (bool value) async {
                if (value) {
                  await _requestNotificationPermissions();
                } else {
                  await _updatePushSettings(false);
                }
              }),
          Container(
            color: Color(0x1FB9A2A2),
            width: double.infinity,
            height: screenHeight / 15,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "My Account Information",
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            title: Text("프로필 수정"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeProfilePage()),
              ).then((value) => setState(() {}));
            },
          ),
          Divider(),
          ListTile(
            title: Text("비밀번호 변경"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              ).then((value) => setState(() {}));
            },
          ),
          Container(
            color: Color(0x1FB9A2A2),
            width: double.infinity,
            height: screenHeight / 15,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
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
                MaterialPageRoute(builder: (context) => RecipeListPage(userId: userId)),
              ).then((value) => setState(() {}));
            },
          ),
          Divider(),
          ListTile(
            title: Text("식재료"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPrefer()),
              ).then((value) => setState(() {}));
            },
          ),
          Container(
            color: Color(0x1FB9A2A2),
            width: double.infinity,
            height: screenHeight / 15,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "Support",
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            title: Text("고객센터"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CenterPage()),
              ).then((value) => setState(() {}));
            },
          ),
          Divider(),
          Center(
            child: Container(
              width: screenWidth / 3, // 버튼의 폭 설정
              height: screenHeight / 15,
              color: Colors.white,
              margin: EdgeInsets.only(
                  top: screenHeight / 80, bottom: screenHeight / 80),
              child: ElevatedButton(
                onPressed: () async {
                  String? token = await _secureService.readToken(refresh);
                  userService.logout(
                      AuthLogoutRequest(id: user!.id, refreshToken: token!));
                  Constants.isSelelcted = true;
                  await _secureService.deleteToken(access);
                  await _secureService.deleteToken(refresh);
                  //Provider.of<UserProvider>(context).clearUser();
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
                child: Text("Log out",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
