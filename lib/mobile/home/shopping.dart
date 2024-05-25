import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/Shop.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/search/shoppingresult.dart';

class ShoppingPage extends StatefulWidget {
  final Future<List<Shop>> increaseValues;
  final Future<List<Shop>> decreaseValues;
  ShoppingPage({required this.increaseValues, required this.decreaseValues});

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알뜰장보기"),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
            "이번주 동향",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),

          buildCategory(widget.increaseValues),

          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),

          buildCategory(widget.decreaseValues),
        ],
      ),
    );
  }

  Widget buildCategory(Future<List<Shop>> futureShops) {
    return Column(
      children: [
        FutureBuilder<List<Shop>>(
          future: futureShops,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              List<Shop> shops = snapshot.data!;
              return Column(
                children:
                [

                  SizedBox(height: 10,),

                  Row(
                    children: [
                    buildShopCard(shops[0]),
                    SizedBox(width: 8), // 카드 사이 간격 조절
                    buildShopCard(shops[1]),
                    ],
                  ),

                  SizedBox(height: 10,),

                    Row(
                      children: [
                        buildShopCard(shops[2]),
                        SizedBox(width: 8), // 카드 사이 간격 조절
                        buildShopCard(shops[3]),
                      ],
                    ),

                  SizedBox(height: 10,),
                ],
              );
            } else {
              return Text('No data available');
            }
          },
        ),
      ],
    );
  }

  Widget buildShopCard(Shop shop) {
    Color textColor = shop.values < 0 ? Colors.blue : Colors.red;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ShoppingResultPage(itemname: shop.name, kindname: shop.kind, rankname: shop.rank)));
        },
        child: Card(
          elevation: 4.0,
          child: Column(
            children: [
              Container(
                height: 100,
                color: Colors.grey[300], // 회색 배경색
                child: Placeholder(), // 이미지 위젯을 대신하여 회색 영역을 나타냅니다.
              ),
              SizedBox(height: 10),
              Text(
                shop.name + " (" + shop.unit + ")",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("품종: ${shop.kind}, 상태: ${shop.rank}"),
              Text("이번주: ${shop.price}원"),
              Text("지난주: ${shop.week_price}원"),
              Text(
                "등락률: ${shop.values}",
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}