import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/home/homepage.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/mypage/mypage.dart';
import 'package:flutter_splim/mobile/recipeview/recipeview.dart';
import 'package:flutter_splim/mobile/DB/DBHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/service/userservice.dart';
import 'package:flutter_splim/constant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_splim/provider/notificationProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter_splim/mobile/camera/CameraRecipe.dart';

final FlutterLocalNotificationsPlugin notiPlugin = FlutterLocalNotificationsPlugin();
NotificationProvider? notificationProvider;

Future<void> cancelNotification() async{
  await notiPlugin.cancelAll();
}

Future<void> requestPermissions() async{
  await notiPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true
  );
}

Future<void> showNotification({
  required title,
  required message
}) async{
  notiPlugin.show(11, title, message,
    NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        channelDescription: "channelDescription",
        icon: "@drawable/img",
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  RemoteNotification? notification = message.notification;
  print('noti - title : ${notification?.title}, body : ${notification?.body}');
  if (notification != null) {
    if(notification.title != null && notification.body != null){
      await showNotification(
        title: notification.title ?? 'No Title',
        message: notification.body ?? 'No Body',
      );
    }
  }
  //await showNotification(title: notification?.title, message: notification?.body);
  notificationProvider?.incrementCount();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(!kIsWeb){
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    var token = await FirebaseMessaging.instance.getToken();
    final SecureService secureService = SecureService();
    String? fcm = await secureService.readToken("fcmToken");
    if(fcm != null){
      await secureService.deleteToken("fcmToken");
    }
    await secureService.writeToken('fcmToken', token ?? 'token NULL');
    print("token: ${token ?? 'token NULL'}");
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(MyApp());
    });
  }
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SecureService>(create: (_) => SecureService()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget{
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String key = "accessToken";
  String refresh = "refreshToken";
  late Future<UserDTO> user;
  final UserService userService = UserService();
  XFile? _image;
  CroppedFile? _croppedFile;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      Provider.of<NotificationProvider>(context, listen: false).incrementCount();
      RemoteNotification? notification = message.notification;
      print('noti - title : ${notification?.title}, body : ${notification?.body}');
      await showNotification(title: notification?.title, message: notification?.body);
    });
  }

  Future<void> _checkLoginStatus() async {
    final storageService = Provider.of<SecureService>(context, listen: false);
    String? token = await storageService.readToken(refresh);
    if (token != null && token.isNotEmpty) {
      try {
        UserDTO user = await userService.getUserInfo(token);
        Provider.of<UserProvider>(context, listen: false).updateUser(user);
        setState(() {
          Constants.isLogined = true;
        });
      } catch (e) {
        setState(() {
          Constants.isLogined = false;
        });
      }
    } else {
      setState(() {
        Constants.isLogined = false;
      });
    }
  }

  Future<UserDTO> _fetchUser() async {
    final storageService = Provider.of<SecureService>(context, listen: false);
    String? token = await storageService.readToken("refreshToken");
    if (token != null && token.isNotEmpty) {
      UserDTO user = await userService.getUserInfo(token);
      Provider.of<UserProvider>(context, listen: false).updateUser(user);
      return user;
    } else {
      throw Exception("유효한 토큰이 없습니다.");
    }
  }

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
      ..files.add(await http.MultipartFile.fromPath('imageFile', image.path));

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final storageService = Provider.of<SecureService>(context, listen: false);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: TabBarView(
          children: [
            MyHomePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black),
                label: '홈',
                backgroundColor: Colors.white
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.grey),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera, color: Colors.blue),
              label: '카메라',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank, color: Colors.grey),
              label: '레시피',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.grey),
              label: '내 정보',
            ),
          ],
          selectedItemColor: Colors.black,
          backgroundColor: Colors.white,
          onTap: (int index) {
            if(index == 0){
              setState(() {
                _checkLoginStatus();
              });
            } else if (index == 1) {
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
              ).then((value) {
                storageService.readToken(key).then((token) {
                  setState(() {
                    Constants.isLogined = token != null && token.isNotEmpty;
                  });
                });
              });
            } else if (index == 2) {
              if (Constants.isLogined) {
                _showPicker(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((value) {
                  storageService.readToken(key).then((token) {
                    setState(() {
                      Constants.isLogined = token != null && token.isNotEmpty;
                    });
                  });
                });
              }
            } else if (index == 3) {
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
              ).then((value) {
                storageService.readToken(key).then((token) {
                  setState(() {
                    Constants.isLogined = token != null && token.isNotEmpty;
                  });
                });
              });
            } else if (index == 4) {
              if (Constants.isLogined) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => MyPage(),
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
                ).then((value) {
                  storageService.readToken(key).then((token) {
                    setState(() {
                      Constants.isLogined = token != null && token.isNotEmpty;
                    });
                  });
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((value) {
                  storageService.readToken(key).then((token) {
                    setState(() {
                      Constants.isLogined = token != null && token.isNotEmpty;
                    });
                  });
                });
              }
            }
          },
        ),
      ),
    );
  }
}
