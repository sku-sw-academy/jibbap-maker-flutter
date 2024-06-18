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
  bool isSave = false;

  Future<void> saveRecipe(GptChatResponse recipe) async {
    final url = Uri.parse('${Constants.baseUrl}/recipe/save');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': widget.userId.toString(),
        'title': recipe.title.replaceAll("title : ", ""),
        'content': recipe.content.replaceAll("content : ", ""),
      },
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('성공'),
          content: Text('저장되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      setState(() {
        isSave = true;
      });
    } else {
      throw Exception('Failed to save recipe: ${response.statusCode}');
    }
  }

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
        scrolledUnderElevation: 0,
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

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    snapshot.data!.content.replaceAll("content : ", "내용"),
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if(!isSave){
                            await saveRecipe(snapshot.data!);
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('이미 저장되었습니다.'),)
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save recipe: $e')),
                          );
                        }
                      },
                      child: Text("저장", textAlign: TextAlign.center,),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.black, width: 1),
                        minimumSize: Size(80, 50),
                      ),
                    ),
                    SizedBox(width: 40),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isSave = false;
                          futureRecipe = fetchRecipe();
                        });
                      },
                      child: Text("재시도", textAlign: TextAlign.center, style: TextStyle(fontSize: 11),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.black, width: 1),
                        fixedSize: Size(80, 50),
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