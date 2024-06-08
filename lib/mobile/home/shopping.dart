import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/Shop.dart';
import 'package:flutter_splim/mobile/search/search.dart';
import 'package:flutter_splim/mobile/search/shoppingresult.dart';
import 'package:flutter_splim/constant.dart';

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
        title: Text("알뜰장보기", style: TextStyle(fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
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
    return FutureBuilder<List<Shop>>(
      future: futureShops,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Shop> shops = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // 이 그리드뷰가 스크롤을 따로 하지 않도록 설정
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 한 줄에 두 개의 항목을 배치
              crossAxisSpacing: 8.0, // 항목 사이의 가로 간격
              mainAxisSpacing: 8.0, // 항목 사이의 세로 간격
              childAspectRatio: 2 / 3.9, // 카드의 가로 세로 비율
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return buildShopCard(shops[index]);
            },
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }

  Widget buildShopCard(Shop shop) {
    Color textColor = shop.values < 0 ? Colors.blue : Colors.red;
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShoppingResultPage(itemname: shop.name, kindname: shop.kind, rankname: shop.rank))).then((value) => setState(() {

        }));
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              shop.name + " (" + shop.unit + ")",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            AspectRatio(
              aspectRatio: 1, // 이미지를 정사각형 비율로 설정
              child: Container(
                color: Colors.grey[300], // 회색 배경색
                child: shop.image != null
                    ? Image.network(
                  '${Constants.baseUrl}/items/images/${shop.image}',
                  fit: BoxFit.cover, // 이미지를 위젯에 맞게 조정
                  // 가로 너비를 화면에 맞게 확장
                )
                    : Icon(Icons.food_bank, size: 50),
              ),
            ),

            SizedBox(height: 10),

            Text("품종: ${shop.kind}"),
            Text("등급: ${shop.rank}"),
            Text("이번주: ${shop.price}원"),
            Text("지난주: ${shop.week_price}원"),
            Text(
              "등락률: ${shop.values}%",
              style: TextStyle(color: textColor),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
