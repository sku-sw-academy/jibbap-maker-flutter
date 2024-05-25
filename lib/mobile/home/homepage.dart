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

  void initState(){
    super.initState();
    date = "2024-05-24";
    futurePrices = priceService.fetchPriceTop3(date!);
    _increaseValues = priceService.fetchPriceIncreaseValues(date!);
    _decreaseValues = priceService.fetchPriceDecreaseValues(date!);
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
                          child: isSelected
                              ? FutureBuilder<List<PriceDTO>>(
                            future: futurePrices,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                    child:
                                    CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('No data found'));
                              } else {
                                List<PriceDTO> prices = snapshot.data!;
                                return Column(
                                  children: prices.map((price) {
                                    return ListTile(
                                      title: Text(
                                        "${prices.indexOf(price) + 1}. ${price.itemCode.itemName}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        "${price.value}%",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      tileColor: Colors.green[(prices.indexOf(price) + 1) * 100],
                                      onTap: (){
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => DetailPage(regday: date!)),
                                          );
                                      },
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ): FutureBuilder<List<Shop>>(
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
                                      ListTile(
                                        leading: Icon(Icons.info),
                                        title: Text('식재료를 \n'
                                            '3가지 이상 \n선택하세요', textAlign: TextAlign.center,),
                                        tileColor: Colors.grey[200],
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => MyPrefer()),
                                          );
                                        },
                                      ),
                                    ] else ...[
                                      Expanded(
                                        child: ListTile(
                                          leading: Icon(Icons.arrow_upward),
                                          title: Text(increaseValues[0].name),
                                          trailing: Text('${increaseValues[0].price} 원'),
                                          tileColor: Colors.yellowAccent[100],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          leading: Icon(Icons.arrow_upward),
                                          title: Text(increaseValues[1].name),
                                          trailing: Text('${increaseValues[1].price} 원'),
                                          tileColor: Colors.yellowAccent[200],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          leading: Icon(Icons.arrow_upward),
                                          title: Text(increaseValues[2].name),
                                          trailing: Text('${increaseValues[2].price} 원'),
                                          tileColor: Colors.yellow,
                                        ),
                                      ),
                                    ]
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: screenWidth / 23),

                Expanded(child:
                  Container(
                  height: screenHeight / 4.2,
                    child: Card(
                      elevation: 5.0,
                      color: Colors.limeAccent[100],
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child:
                          Text(
                            '오늘의 추천 레시피',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                          SizedBox(height: 8.0),
                        // 나머지 카드 내용을 추가하세요.
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    Text(
                      '관심있는 품목 소비자 가격은?',
                      style: TextStyle(fontSize: 20, color: Colors.amber),
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
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight / 50,),

          Container(
            height: screenHeight / 3,
            color: Color(0xFFFCFCF1),
            child: GridView.count(
              crossAxisCount: 3, // 가로 방향으로 3개의 카드씩 배치
              childAspectRatio: 3 / 3, // 카드의 가로 세로 비율 설정
              children: [
                GestureDetector(
                  onTap: () {
                    // 첫 번째 Card를 클릭했을 때 실행되는 동작
                  },
                  child: Card(
                    // 첫 번째 Card
                    color: Colors.white,
                    elevation: 4.0,
                    child: Center(
                      child: Text('Card 1'), // Card에 들어갈 내용
                    ),
                  ),
                ),GestureDetector(
                  onTap: () {
                    // 첫 번째 Card를 클릭했을 때 실행되는 동작
                  },
                  child: Card(
                    // 첫 번째 Card
                    color: Colors.white,
                    elevation: 4.0,
                    child: Center(
                      child: Text('Card 1'), // Card에 들어갈 내용
                    ),
                  ),
                ),GestureDetector(
                  onTap: () {
                    // 첫 번째 Card를 클릭했을 때 실행되는 동작
                  },
                  child: Card(
                    // 첫 번째 Card
                    color: Colors.white,
                    elevation: 4.0,
                    child: Center(
                      child: Text('Card 1'), // Card에 들어갈 내용
                    ),
                  ),
                ),GestureDetector(
                  onTap: () {
                    // 첫 번째 Card를 클릭했을 때 실행되는 동작
                  },
                  child: Card(
                    // 첫 번째 Card
                    color: Colors.white,
                    elevation: 4.0,
                    child: Center(
                      child: Text('Card 1'), // Card에 들어갈 내용
                    ),
                  ),
                ),GestureDetector(
                  onTap: () {
                    // 첫 번째 Card를 클릭했을 때 실행되는 동작
                  },
                  child: Card(
                    // 첫 번째 Card
                    color: Colors.white,
                    elevation: 4.0,
                    child: Center(
                      child: Text('Card 1'), // Card에 들어갈 내용
                    ),
                  ),
                ),GestureDetector(
                  onTap: () {
                    // 첫 번째 Card를 클릭했을 때 실행되는 동작
                  },
                  child: Card(
                    // 첫 번째 Card
                    color: Colors.white,
                    elevation: 4.0,
                    child: Center(
                      child: Text('Card 1'), // Card에 들어갈 내용
                    ),
                  ),
                ),
                // 나머지 카드들에 대한 코드를 여기에 추가하세요.
              ],
            ),
          ),

          SizedBox(height: screenHeight / 40,),

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
                                    fontSize: 18,
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
          SizedBox(height: 15),
        ],
      ),
    );
  }
}