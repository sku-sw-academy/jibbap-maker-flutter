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
import 'package:flutter_splim/mobile/home/market.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSelected = true;
  String? date;
  late Future<List<PriceDTO>> futurePrices;
  final PriceService priceService = PriceService();
  String key = "";

  void initState(){
    super.initState();
    date = getDate();
    futurePrices = priceService.fetchPriceTop3(date!);
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
        backgroundColor: Colors.blue,
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
                                  final storageService =
                                  Provider.of<SecureService>(context, listen: false);
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
                          ): Column(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    leading: Icon(Icons.favorite),
                                    title: Text('사과'),
                                    tileColor: Colors.blue[100],
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text('사과'),
                                    tileColor: Colors.blue[200],
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text('사과'),
                                    tileColor: Colors.blue[300],
                                  ),
                                ),
                              ],
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

          SizedBox(height: screenHeight / 40,),

          Container(
            height: screenHeight / 4,
            color: Color(0xFFFCFCF1),
            child: Column(
              children: [
                Row(),
                Row(),
              ],
            ),
          ),

          SizedBox(height: screenHeight / 40,),

        GestureDetector(
          onTap: () {
          Navigator.push(
          context,  MaterialPageRoute(builder: (context) => MarketPage()),
          );
        },
          child: Container(
            height: screenHeight / 4,
            color: Colors.white70,
            child: Card(
            color: Colors.lightGreenAccent[100],
            elevation: 8.0,
                // 카드 내용 추가
              ),
            ),
          ),
        ],
      ),
    );
  }
}