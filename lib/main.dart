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
//import 'package:easy_localization/easy_localization.dart';

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
          // 배경색 설정
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
    //user = _fetchUser();
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final storageService = Provider.of<SecureService>(context, listen: false);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: TabBarView(
          children: [
            MyHomePage(), // 홈 화면
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black),
                label: 'Home',
                backgroundColor: Colors.white
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
              icon: Icon(Icons.person, color: Colors.grey),
              label: 'My Page',
            ),
          ],

          selectedItemColor: Colors.black,

          onTap: (int index) {
            if(index == 0){
              setState(() {
                _checkLoginStatus();
              });
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
              ).then((value) {
                storageService.readToken(key).then((token) {
                  setState(() {
                    Constants.isLogined = token != null && token.isNotEmpty;
                  });
                });
              });
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
              ).then((value) {
                storageService.readToken(key).then((token) {
                  setState(() {
                    Constants.isLogined = token != null && token.isNotEmpty;
                  });
                });
              });
            } else if (index == 3) {
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
              }
              else {
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
