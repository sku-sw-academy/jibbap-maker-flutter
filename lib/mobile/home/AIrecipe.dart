import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:flutter_splim/dto/gptchatrequest.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';

class AIRecipePage extends StatefulWidget {
  final int userId;
  final Future<List<PriceDTO>> futurePrices;

  AIRecipePage({required this.userId, required this.futurePrices});

  @override
  _AIRecipePageState createState() => _AIRecipePageState();
}

class _AIRecipePageState extends State<AIRecipePage> {
  late String responseText;
  late Future<String> futureRecipe;

  Future<String> sendGptChatRequest(int userId, List<PriceDTO> prices) async {
    final url = Uri.parse('${Constants.baseUrl}/api/gpt/recipe');

    GptChatRequest request = GptChatRequest(
      id: userId,
      thriftyItems: prices.map((price) => price.itemCode.itemName).join(', '),
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      setState(() {
        responseText = response.body;
      });
      return response.body;
    } else {
      throw Exception('Failed to load recipe: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    responseText = '';
    futureRecipe = fetchRecipe(); // 초기화 시에 응답을 받기 위해 initState에서 호출
  }

  // 응답을 받는 메서드
  Future<String> fetchRecipe() async {
    try {
      List<PriceDTO> prices = await widget.futurePrices;
      String response = await sendGptChatRequest(widget.userId, prices);
      print('Recipe: $response');
      return response;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("레시피"),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: futureRecipe,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView(
              children: [
                Divider(),
                // 여기에 데이터를 표시
                Text(
                  snapshot.data!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),

                Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 저장 버튼 로직 추가
                      },
                      child: Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.black, width: 1),
                        minimumSize: Size(50, 50),
                      ),
                    ),
                    SizedBox(width: 40),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureRecipe = fetchRecipe();
                        });
                      },
                      child: Icon(Icons.refresh),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.black, width: 1),
                        minimumSize: Size(50, 50),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
