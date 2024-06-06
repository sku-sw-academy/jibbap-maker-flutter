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
import 'package:flutter_splim/mobile/recipeview/recipe.dart';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/service/userservice.dart';
import 'package:flutter_splim/desktop/admin.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/provider/adminprovider.dart';
import 'package:flutter_splim/desktop/signout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(kIsWeb){
    runApp(MyAppDesktop());
  }else{
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
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
  late UserDTO? user;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
              icon: Icon(Icons.grid_view, color: Colors.grey),
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
                MaterialPageRoute(builder: (context) => SearchPage()),
              ).then((value) => setState(() {

              }));
            } else if (index == 2) {
              // 마이페이지는 홈 화면과 같이 TabBarView에 표시됩니다.
              // 탭 인덱스를 이용하여 화면을 전환합니다.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipePage()),
              ).then((value) => setState((){

              }));
            }else if (index == 3) {
              if (Constants.isLogined) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
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

class MyAppDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SecureService>(create: (_) => SecureService()),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        home: FutureBuilder<bool>(
          future: _isAdminLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터를 기다리는 동안 로딩 표시를 표시할 수 있습니다.
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                // 에러가 발생한 경우 처리할 수 있습니다.
                return Center(child: Text('Error occurred'));
              } else {
                // 토큰의 존재 여부에 따라 페이지를 결정합니다.
                if (snapshot.data!) {
                  return AdminPage();
                } else {
                  return LoginAdminPage();
                }
              }
            }
          },
        ),
      ),
    );
  }

  // 관리자가 로그인되어 있는지 확인하는 비동기 함수
  Future<bool> _isAdminLoggedIn() async {
    final storageService = SecureService();
    String? token = await storageService.readToken("admin_accessToken");
    return token != null && token.isNotEmpty;
  }
}