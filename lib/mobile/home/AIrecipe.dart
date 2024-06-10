import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/GptChatResponse.dart';
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
  late Future<GptChatResponse> futureRecipe;

  Future<GptChatResponse> sendGptChatRequest(int userId, List<PriceDTO> prices) async {
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
      var responsebody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responsebody);
      return GptChatResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to load recipe: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    futureRecipe = fetchRecipe(); // 초기화 시에 응답을 받기 위해 initState에서 호출
  }

  // 응답을 받는 메서드
  Future<GptChatResponse> fetchRecipe() async {
    try {
      List<PriceDTO> prices = await widget.futurePrices;
      GptChatResponse response = await sendGptChatRequest(widget.userId, prices);
      print('Recipe: ${response.title}');
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
        title: FutureBuilder<GptChatResponse>(
          future: futureRecipe,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.title.isEmpty) {
              return Text('No title available');
            } else {
              return Text(snapshot.data!.title.replaceAll("title :", ""));
            }
          },
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<GptChatResponse>(
        future: futureRecipe,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.content.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView(
              children: [
                Divider(),
                // 여기에 데이터를 표시
                Text(
                  snapshot.data!.content.replaceAll("content : ", "내용"),
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