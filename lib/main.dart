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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          //useMaterial3: true,
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
  bool _isLoggedIn = false;
  String key = "";

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final storageService = Provider.of<SecureService>(context, listen: false);
    String? token = await storageService.readToken(key);
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                icon: Icon(Icons.home, color: Colors.redAccent),
                label: 'Home',
                backgroundColor: Colors.limeAccent
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
              icon: Icon(Icons.person, color: Colors.blueAccent),
              label: 'My Page',
            ),
          ],

          selectedItemColor: Colors.redAccent,

          onTap: (int index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            } else if (index == 2) {
              // 마이페이지는 홈 화면과 같이 TabBarView에 표시됩니다.
              // 탭 인덱스를 이용하여 화면을 전환합니다.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipePage()),
              );
            }else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPage()),
              );
              // if (_isLoggedIn) {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => MyPage()),
              //   );
              // } else {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => LoginPage()),
              //   );
              // }
            }
          },
        ),
      ),
    );
  }
}

