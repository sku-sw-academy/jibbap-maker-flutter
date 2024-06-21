import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/recipeview/recipeview.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/myprofile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/service/userservice.dart';
import 'package:flutter_splim/constant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/mobile/camera/CameraRecipe.dart';

class MyPage extends StatefulWidget{

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Future<UserDTO> user;
  final UserService userService = UserService();
  XFile? _image;
  CroppedFile? _croppedFile;

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('사진 선택'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 찍기'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      _image = XFile(image.path);
      cropImage();
    }
  }

  Future<void> cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
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
            boundary: CroppieBoundary(width: 520, height: 520),
            viewPort: CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
          _analyzeImage(File(_croppedFile!.path));
        });
      }
    }
  }

  Future<void> _analyzeImage(File image) async {
    UserDTO? user = Provider.of<UserProvider>(context, listen: false).user;
    int? userId = user != null ? user?.id : 0;
    final uri = Uri.parse('${Constants.baseUrl}/api/gpt/');

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      String imageName = await response.stream.bytesToString();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('음식 이름 확인'),
          content: Text('이 이미지는 $imageName 입니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>
                        CameraPage(userId: userId!, name: imageName))
                );
              },
            ),
          ],
        ),
      );

      print('Response: $image');
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 인식하지 못했습니다.'),)
      );
    }
  }

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
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.grey),
              label: '홈',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search, color: Colors.grey),
                label: '검색',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.food_bank, color: Colors.grey),
                label: '레시피',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.black),
                label: '내 정보',
                backgroundColor: Colors.white
            ),
          ],
          backgroundColor: Colors.white,
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
