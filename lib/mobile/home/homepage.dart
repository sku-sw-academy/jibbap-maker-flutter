import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/login/signout.dart';
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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSelected = true;
  String? date;
  String key = "";
  final PriceService priceService = PriceService();
  late Future<List<PriceDTO>> futurePrices;
  late Future<List<Shop>> _increaseValues;
  late Future<List<Shop>> _decreaseValues;
  late Future<List<PriceDTO>> _futurePopularNames;

  void initState(){
    super.initState();
    date = getDate();
    futurePrices = priceService.fetchPriceTop3(date!);
    _increaseValues = priceService.fetchPriceIncreaseValues(date!);
    _decreaseValues = priceService.fetchPriceDecreaseValues(date!);
    _futurePopularNames = priceService.fetchPopularItemPrices6();
  }

  String getDate(){
    DateTime now = DateTime.now();
    if(now.hour < 16){
      DateTime previousDay = now.subtract(Duration(days: 1));
      return DateFormat('yyyy-MM-dd').format(previousDay);
    }else{
      return DateFormat('yyyy-MM-dd').format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('알뜰집밥'),
        centerTitle: true,
        backgroundColor: Colors.limeAccent,
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
            margin: EdgeInsets.all(screenWidth / 40),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: screenHeight / 3.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: screenWidth / 20),
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
                                              );
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
                              borderRadius: BorderRadius.circular(17),
                              constraints: BoxConstraints.tightFor(
                                width: screenWidth / 6.2,
                                height: screenHeight / 20.5,
                              ),
                              children: [
                                Text("알뜰 소비"),
                                Text("맞춤 가격")
                                ],
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
                                          return Container(
                                            height: 60, // 고정 높이
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black), // 경계선 색상
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                "${price.itemCode.itemName}-${price.kindName}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic
                                                ),
                                              ),
                                              trailing: Text(
                                                "${price.rankName}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle: FontStyle.italic
                                                ),
                                              ),
                                              tileColor: Colors.red[(prices.indexOf(price) + 1) * 100],
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => DetailPage(regday: date!)),
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    }
                                  },
                                ),
                              ] else ...[
                                FutureBuilder<List<Shop>>(
                                  future: _increaseValues,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Center(child: Text('No data found'));
                                    } else {
                                      List<Shop> increaseValues = snapshot.data!;
                                      return Column(
                                        children: [
                                          if (increaseValues.length < 3) ...[
                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey), // 경계선 색상
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.info),
                                                title: Text(
                                                  '식재료를 \n'
                                                      '3가지 이상 \n선택하세요',
                                                  textAlign: TextAlign.center,
                                                ),
                                                tileColor: Colors.grey[200],
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => MyPrefer()),
                                                  );
                                                },
                                              ),
                                            ),
                                          ] else ...[
                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black), // 경계선 색상
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.arrow_upward),
                                                title: Text(increaseValues[0].name),
                                                trailing: Text('${increaseValues[0].price} 원'),
                                                tileColor: Colors.yellowAccent[100],
                                              ),
                                            ),
                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black), // 경계선 색상
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.arrow_upward),
                                                title: Text(increaseValues[1].name),
                                                trailing: Text('${increaseValues[1].price} 원'),
                                                tileColor: Colors.yellowAccent[200],
                                              ),
                                            ),
                                            Container(
                                              height: 60, // 고정 높이
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black), // 경계선 색상
                                              ),
                                              child: ListTile(
                                                leading: Icon(Icons.arrow_upward),
                                                title: Text(increaseValues[2].name),
                                                trailing: Text('${increaseValues[2].price} 원'),
                                                tileColor: Colors.yellow,
                                              ),
                                            ),
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

                SizedBox(width: screenWidth / 23),

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
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                        return;
                      } else {
                        // 추가적인 액션을 여기에 추가하세요.
                      }
                    },
                    child: Container(
                      height: screenHeight / 4.2,

                      child: Card(
                        elevation: 5.0,
                        color: Colors.transparent, // 카드 배경색을 투명으로 설정
                        child: Container(
                          decoration: BoxDecoration(
                          gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.tealAccent,
                            Colors.amberAccent,
                            Colors.redAccent,
                        ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0), // 카드 모서리 둥글게
                          ),
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '오늘의 추천 레시피',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Icon(
                              Icons.receipt_long,
                              size: 80.0,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 10.0),
                              Text(
                                'AI 기반 맞춤 레시피를\n  확인해보세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingPage(increaseValues: _increaseValues, decreaseValues: _decreaseValues)),
              );
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
                    height: screenHeight / 4,
                    color: Colors.white70,
                    child: Card(
                      color: Colors.redAccent,
                      elevation: 8.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 12),
                            Expanded(
                              child: Image.asset(
                                'asset/food/market.png', // 이미지 경로
                                fit: BoxFit.cover, // 이미지가 적절하게 확장되도록 설정
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35, // 원형의 크기 조절
                                  backgroundColor: Colors.white, // 원형의 배경색
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
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "${increaseValues[0].name}, ${increaseValues[1].name}, ${decreaseValues[0].name}, ${decreaseValues[1].name}",
                                  style: TextStyle(
                                    color: Colors.black,
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
                          //decoration: TextDecoration.underline,
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
                  color: Color(0xFFFCFCF1),
                  child: GridView.count(
                    crossAxisCount: 3, // 가로 방향으로 3개의 카드씩 배치
                    childAspectRatio: 3 / 3, // 카드의 가로 세로 비율 설정
                    children: popularPrices.map((price) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (contex) => SelectedPage(itemname: price.itemCode.itemName)),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 4.0,
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
    );
  }
}