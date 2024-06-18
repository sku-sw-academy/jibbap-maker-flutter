import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/AuthLogoutRequest.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/prefer.dart';
import 'package:flutter_splim/mobile/mypage/changeprofile.dart';
import 'package:flutter_splim/mobile/mypage/changepassword.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/center.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;

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
  bool? _isDefaultImage = false;
  XFile? _image;
  CroppedFile? _croppedFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    // 사용자 정보 불러오기
    user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      _switchValue = user?.push ?? false;
      userId = user?.id ?? -1;
      _isDefaultImage = user?.profile == null || user!.profile!.isEmpty ?? true;
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

  Future<void> getImage(ImageSource imageSource) async{
    try{
      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if(pickedFile != null){
        _image = XFile(pickedFile.path);
        cropImage();
      }
    }catch(e){

    }
  }

  Future<void> cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기/회전하기',
            toolbarColor: Colors.grey[100],
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '이미지 자르기/회전하기',
            aspectRatioLockEnabled: true,
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: CroppieViewPort(
              width: 480,
              height: 480,
              type: 'circle',
            ),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
          uploadImage(userId, croppedFile);
          _isDefaultImage = false;
        });
      }
    }
  }

  Future uploadImage(int userId, CroppedFile imageFile) async {
    var url = Uri.parse('${Constants.baseUrl}/api/auth/upload');
    var request = http.MultipartRequest('POST', url);
    request.fields['userId'] = userId.toString(); // 사용자 ID 추가
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      String image = await response.stream.bytesToString();
      print('Image: $image');
      setState(() {
        user!.profile = image;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 이미지 변경')),
        );// 서버에서 받은 이미지
      });
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  Future<void> resetProfileImage(int userId) async {
    var url = Uri.parse('${Constants.baseUrl}/api/auth/reset-profile');
    var response = await http.post(url, body: {'userId': userId.toString()});
    if (response.statusCode == 200 && response.body == "Ok") {
      print('Profile reset successfully');
      setState(() {
        user!.profile = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기본 이미지로 변경')),
        );// 프로필 이미지 URL을 빈 값으로 설정
      });
    } else {
      print('Failed to reset profile image');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지 변경 실패')),
      );
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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
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
                ),
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
                GestureDetector(
                  onTap: () {
                    showSheet(context);
                  },
                  child: CircleAvatar(
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
                        : Icon(Icons.person, size: 80, color: Colors.grey,), // 프로필 이미지가 없는 경우에 아이콘을 표시
                  ),
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
            decoration: BoxDecoration(
              color: Color(0x1FB9A2A2),
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey),
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            width: double.infinity,
            height: screenHeight  * 0.05,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "알림 설정",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
            decoration: BoxDecoration(
              color: Color(0x1FB9A2A2),
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey),
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            width: double.infinity,
            height: screenHeight  * 0.05,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "계정",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            child: ListTile(
              title: Text("프로필 수정"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeProfilePage()),
                ).then((value) => setState(() {}));
              },
            ),
          ),

          Container(
            child: ListTile(
              title: Text("비밀번호 변경"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                ).then((value) => setState(() {}));
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0x1FB9A2A2),
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey),
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            width: double.infinity,
            height: screenHeight  * 0.05,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "내 맞춤",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            child:

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
          ),

        Container(

          child: ListTile(
            title: Text("식재료"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPrefer()),
              ).then((value) => setState(() {}));
            },
          ),
      ),
          Container(
            decoration: BoxDecoration(
              color: Color(0x1FB9A2A2),
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey),
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            width: double.infinity,
            height: screenHeight  * 0.05,
            padding: EdgeInsets.only(
                left: screenWidth / 40, top: screenHeight / 90),
            child: Text(
              "이용 안내",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            child: ListTile(
              title: Text("고객센터"),
              trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CenterPage()),
              ).then((value) => setState(() {}));
            },
          ),
          ),

          Center(
            child: Container(
              width: screenWidth * 0.262, // 버튼의 폭 설정
              height: screenHeight * 0.06,
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
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                  ),
                  side: BorderSide(color: Colors.black, width: 1),
                  fixedSize: Size(40, 20),
                  // 다른 스타일 속성들...
                ),
                child: Text("로그아웃",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 경계선을 둥글게 만듦
          ),
          elevation: 5.0,
          title: Text('프로필 사진 변경'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.camera); // 카메라 열기
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 찍기'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.gallery); // 갤러리에서 이미지 선택
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: ListTile(
                leading: Icon(Icons.photo),
                title: Text('갤러리에서 선택'),
              ),
            ),
            if (user!.profile != null && user!.profile!.isNotEmpty && !_isDefaultImage! && user!.profile != "")
              SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    resetProfileImage(userId);// 기본 이미지로 변경
                    _croppedFile = null;
                  });
                  Navigator.pop(context); // 다이얼로그 닫기
                },
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('기본 이미지로 변경'),
                ),
              ),
          ],
        );
      },
    );
  }
}
