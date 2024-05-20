import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/search/search.dart';
import 'package:flutter_splim/home/paint.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSelected = true;
  final String date = "2024-05-17";

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
            margin: EdgeInsets.all(screenWidth / 27),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: screenHeight / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ToggleButtons(
                              isSelected: [isSelected, !isSelected],
                              onPressed: (index) {
                                setState(() {
                                  isSelected = index == 0 ? true : false;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              constraints: BoxConstraints.tightFor(
                                width: screenWidth / 6.5,
                                height: screenHeight / 18.5,
                              ),
                              children: [
                                Text("알뜰"),
                                Text("맞춤")
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                // 아이콘 버튼이 눌렸을 때 실행될 코드 추가
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: isSelected
                              ? Column(
                              children: [
                               Expanded(
                                child: ListTile(
                                  leading: Icon(Icons.favorite),
                                  title: Text('사과'),
                                  tileColor: Colors.red[100],
                                ),
                              ),
                                Expanded(
                                  child: ListTile(
                                    title: Text('쌀'),
                                    tileColor: Colors.red[200],
                                ),
                              ),
                                Expanded(
                                  child: ListTile(
                                    title: Text('배'),
                                    tileColor: Colors.red[300],
                                ),
                              ),
                            ],
                          ) : Column(
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

          Container(
            height: screenHeight / 4,
            color: Colors.white70,
            child: Card(
              color: Colors.lightGreenAccent[100],
            ),
          ),
        ],
      ),
    );
  }
}