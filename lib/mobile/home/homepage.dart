import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:flutter_splim/service/userservice.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:flutter_splim/mobile/home/detail.dart';
import 'package:flutter_splim/mobile/home/shopping.dart';
import 'package:flutter_splim/dto/Shop.dart';
import 'package:flutter_splim/mobile/mypage/prefer.dart';
import 'package:flutter_splim/mobile/search/searchResult.dart';
import 'package:flutter/services.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:flutter_splim/mobile/home/preferdetail.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_splim/mobile/home/AIrecipe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSelected = true;
  String? date;
  String key = "accessToken";
  final PriceService priceService = PriceService();
  late Future<List<PriceDTO>> futurePrices;
  late Future<List<Shop>> _increaseValues;
  late Future<List<Shop>> _decreaseValues;
  late Future<List<PriceDTO>> _futurePopularNames;
  final UserService userService = UserService();
  late Future<UserDTO> userDTO;
  late Future<List<PriceDTO>> _futurePreferPrices;
  late int userId;
  bool isNow = false;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // 새로고침 로직을 여기에 구현하세요.
    await Future.delayed(Duration(seconds: 2));
    initializeData();
    isSelected = true;
    _refreshController.refreshCompleted();// 임시로 2초 대기
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initializeData();
  }

  Future<void> initializeData() async {
    date = await getDate();
    futurePrices = priceService.fetchPriceTop3(date!);
    _increaseValues = priceService.fetchPriceIncreaseValues(date!);
    _decreaseValues = priceService.fetchPriceDecreaseValues(date!);
    _futurePopularNames = priceService.fetchPopularItemPrices6();
    userDTO = _fetchUser();
    userDTO.then((user) {
      if (user != null) {
        userId = user.id;
        _futurePreferPrices = priceService.fetchPreferPrice(userId);
      }
    });
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

  Future<String> getDate() async {
    DateTime now = DateTime.now();
    DateTime previousDay = now.subtract(Duration(days: 1));
    if (now.hour < 16) {
      return DateFormat('yyyy-MM-dd').format(previousDay);
    } else {
      String _date = DateFormat('yyyy-MM-dd').format(now);
      await fetchLastRegday(_date);
      if (isNow)
        return DateFormat('yyyy-MM-dd').format(now);
      else
        return DateFormat('yyyy-MM-dd').format(previousDay);
    }
  }

  Future<void> fetchLastRegday(String _date) async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/last/regday'));
      if (response.statusCode == 200) {
        String responsebody = response.body;
        isNow = (_date == responsebody);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<void>(
        future: initializeData(),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
        } else {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              title: Text('알뜰집밥'),
              backgroundColor: Colors.lightBlueAccent,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    ).then((value) => setState(() {

                    }));
                  },
                ),
              ],
            ),
        body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
        children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: screenHeight * 0.01, right: screenWidth * 0.04),
              child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final storageService = Provider.of<SecureService>(context, listen: false);
                      String? token = await storageService.readToken(key);
                      if (token == null || token.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('로그인 필요'),
                            content: Text('로그인이 필요합니다. 로그인하시겠습니까?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('확인'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  ).then((value) => setState(() async {
                                    Future.delayed(Duration(milliseconds: 500), () {
                                      setState(() {
                                        // 여기서 필요한 로그인 이후의 동작 수행
                                      });
                                    });
                                  }));
                                },
                              ),
                            ],
                          ),
                        );
                        return;
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AIRecipePage(userId: userId, futurePrices: futurePrices,)));
                      }
                    },
                    child: Container(
                      height: screenHeight * 0.36,
                      child: Column(
                        children: [
                          SizedBox(height: 59,),
                          Card(
                            elevation: 6.0,
                            color: Colors.blue[700],
                            child: Container(
                              height: screenHeight * 0.24,
                              width: screenWidth * 0.4,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('asset/food/ai.jpeg'), // 여기에 로컬 이미지 경로를 입력하세요
                                  fit: BoxFit.fill, // 이미지를 Container의 크기에 맞게 조정합니다.
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '오늘의 추천 레시피',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 80.0),
                                  Text(
                                    'AI 기반 맞춤 레시피를\n확인해보세요!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.36,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: screenWidth  * 0.08),
                            Expanded(
                              child: ToggleButtons(
                              isSelected: [isSelected, !isSelected],
                              onPressed: (index) async {
                                if (index == 1) {
                                  final storageService = Provider.of<SecureService>(context, listen: false);
                                  String? token = await storageService.readToken(key);
                                  if (token == null || token.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('로그인 필요'),
                                        content: Text('로그인이 필요합니다. 로그인하시겠습니까?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => LoginPage()),
                                              ).then((value) => setState(() async {
                                                Future.delayed(Duration(milliseconds: 500), () {
                                                  setState(() {
                                                    // 여기서 필요한 로그인 이후의 동작 수행
                                                  });
                                                });

                                              }));
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(() {
                                  isSelected = index == 0 ? true : false;
                                });
                              },
                              borderRadius: BorderRadius.circular(5),
                              constraints: BoxConstraints.tightFor(
                                width: screenWidth / 6.2,
                                height: screenHeight / 20.5,
                              ),
                              children: [
                                Text(
                                  "알뜰 소비",
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.grey, // 버튼의 글자 색상
                                  ),
                                ),
                                Text(
                                  "맞춤 가격",
                                  style: TextStyle(
                                    color: !isSelected ? Colors.black : Colors.grey, // 버튼의 글자 색상
                                  ),
                                ),
                                ],
                                fillColor: Colors.amberAccent, // 선택된 버튼의 배경 색상
                                selectedBorderColor: Colors.grey, // 선택된 버튼의 테두리 색상
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              if (isSelected) ...[
                                FutureBuilder<List<PriceDTO>>(
                                  future: futurePrices,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Center(child: Text('No data found'));
                                    } else {
                                      List<PriceDTO> prices = snapshot.data!;
                                      return Column(
                                        children: prices.map((price) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4), // 위아래 간격 조절
                                            child: Container(
                                              height: 61, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(10), // 경계선 색상
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "${price.itemCode.itemName}\n${price.kindName}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Text(
                                                  "${price.value}%",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                tileColor: Colors.white,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => DetailPage(regday: date!)),
                                                  ).then((value) => setState(() {}));
                                                },
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    }
                                  },
                                ),
                              ] else ...[
                                FutureBuilder<List<PriceDTO>>(
                                  future: _futurePreferPrices,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Column(children: [Container(
                                        height: 100, // 고정 높이
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.circular(10),// 경계선 색상
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.info),
                                          title: Text(
                                            '선택하신 선호\n'
                                                '식재료 종류가 \n 부족합니다.',
                                            textAlign: TextAlign.center,
                                          ),
                                          tileColor: Colors.grey[200],
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => MyPrefer()),
                                            ).then((value) => setState(() {
                                              _futurePreferPrices = priceService.fetchPreferPrice(userId);
                                            }));
                                          },
                                        ),
                                      ),]);
                                    } else {
                                      List<PriceDTO> price = snapshot.data!;
                                      return Column(
                                        children: [
                                          if (price.length < 3) ...[
                                            Container(
                                              height: 100, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(10),// 경계선 색상
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.info),
                                                title: Text(
                                                  '선택하신 선호\n'
                                                      '식재료 종류가 \n 부족합니다.',
                                                  textAlign: TextAlign.center,
                                                ),
                                                tileColor: Colors.grey[200],
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => MyPrefer()),
                                                  ).then((value) => setState(() {
                                                    _futurePreferPrices = priceService.fetchPreferPrice(userId);
                                                  }));
                                                },
                                              ),
                                            ),
                                          ] else ...[
                                            SizedBox(height: 4,),
                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(10),// 경계선 색상
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "${price[0].itemCode.itemName}\n${price[0].kindName}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Text(
                                                  "${price[0].value}%",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: price[0].value < 0 ? Colors.blue : price[0].value == 0 ? Colors.black : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                tileColor: Colors.white,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => PreferDetailPage(price: price)),
                                                  ).then((value) => setState(() {
                                                    _futurePreferPrices = priceService.fetchPreferPrice(userId);
                                                  }));
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 8,),

                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(10),// 경계선 색상
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "${price[1].itemCode.itemName}\n${price[1].kindName}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Text(
                                                  "${price[1].value}%",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: price[1].value < 0 ? Colors.blue : price[1].value == 0 ? Colors.black : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                tileColor: Colors.white,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => PreferDetailPage(price: price)),
                                                  ).then((value) => setState(() {
                                                    _futurePreferPrices = priceService.fetchPreferPrice(userId);
                                                  }));
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 8,),
                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(10),// 경계선 색상
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "${price[2].itemCode.itemName}\n${price[2].kindName}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Text(
                                                  "${price[2].value}%",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: price[2].value < 0 ? Colors.blue : price[2].value == 0 ? Colors.black : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                tileColor: Colors.white,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => PreferDetailPage(price: price)),
                                                  ).then((value) => setState(() {
                                                    _futurePreferPrices = priceService.fetchPreferPrice(userId);
                                                  }));
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 4,),
                                          ],
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingPage(increaseValues: _increaseValues, decreaseValues: _decreaseValues)),
              ).then((value) => setState(() {

              }));
            },
            child: FutureBuilder<List<List<Shop>>>(
              future: Future.wait([_increaseValues, _decreaseValues]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<Shop> increaseValues = snapshot.data![0];
                  List<Shop> decreaseValues = snapshot.data![1];
                  return Container(
                    height: screenHeight / 3.8,
                    color: Colors.white,
                    child: Card(
                      color: Colors.white,
                      elevation: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 8),
                            Expanded(
                              child: Image.asset(
                                'asset/food/market.png', // 이미지 경로
                                fit: BoxFit.cover, // 이미지가 적절하게 확장되도록 설정
                              ),
                            ),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35, // 원형의 크기 조절
                                  backgroundColor: Colors.blue[100], // 원형의 배경색
                                  child: Text(
                                    "Weekly", // 원형 안에 들어갈 글자
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Text(
                                    "알뜰장보기",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "${increaseValues[0].name}, ${increaseValues[1].name}",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  "${decreaseValues[0].name}, ${decreaseValues[1].name}",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(child: Text('No data found'));
                }
              },
            ),
          ),

          SizedBox(height: 20,),

          Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    Text(
                      '관심있는 품목 소비자 가격은?',
                      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                  children: [
                    Text(
                      '가격단위 : 원 기준일 ($date)',
                      style: TextStyle(fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight / 50,),

          FutureBuilder<List<PriceDTO>>(
            future: _futurePopularNames,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data found'));
              } else {
                List<PriceDTO> popularPrices = snapshot.data!;
                return Container(
                  height: screenHeight / 3,
                  color: Colors.white,
                  child: GridView.count(
                    crossAxisCount: 3, // 가로 방향으로 3개의 카드씩 배치
                    childAspectRatio: 3 / 3, // 카드의 가로 세로 비율 설정
                    children: popularPrices.map((price) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (contex) => SelectedPage(itemname: price.itemCode.itemName)),
                          ).then((value) => setState(() {
                            _futurePopularNames = priceService.fetchPopularItemPrices6();
                          }));
                        },
                        child: Card(
                          color: Colors.blue[50],
                          elevation: 1.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 10,),
                                    Text(
                                      price.itemCode.itemName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${price.unit} ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 10,)
                                  ],
                                ),

                                SizedBox(height: 6,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${price.dpr1} 원',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 10,)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          SizedBox(height: 15),
        ],
      ),
      ),
      );
        },
        );
        }
      },
    );
  }
}