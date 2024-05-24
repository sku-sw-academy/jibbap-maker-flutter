import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/Shop.dart';

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
      ),
      body: ListView(
        children: [
          buildCategory("이번주 동향(상승)", widget.increaseValues),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          buildCategory("이번주 동향(하락)", widget.decreaseValues),
        ],
      ),
    );
  }

  Widget buildCategory(String categoryName, Future<List<Shop>> futureShops) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            categoryName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey,
        ),

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
                  Row(
                    children: [
                    buildShopCard(shops[0]),
                    SizedBox(width: 8), // 카드 사이 간격 조절
                    buildShopCard(shops[1]),
                    ],
                  ),
                    Row(
                      children: [
                        buildShopCard(shops[2]),
                        SizedBox(width: 8), // 카드 사이 간격 조절
                        buildShopCard(shops[3]),
                      ],
                    ),
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
      child: Card(
        child: Column(
          children: [
            Container(
              height: 100,
              color: Colors.grey[300], // 회색 배경색
              child: Placeholder(), // 이미지 위젯을 대신하여 회색 영역을 나타냅니다.
            ),
            SizedBox(height: 10),
            Text(
              shop.name + "\("+  shop.unit + "\)",
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
    );
  }
}