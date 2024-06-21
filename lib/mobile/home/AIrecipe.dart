import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/GptChatResponse.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:flutter_splim/dto/gptchatrequest.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

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
  File? _savedImageFile;
  int _currentMessageIndex = 0;
  late Timer _timer;

  final List<String> _loadingMessages = [
    '잠시만 기다려주세요...',
    '레시피를 생성 중입니다...',
    '이미지 생성 중입니다...',
    '거의 완료되었습니다...',
  ];

  @override
  void initState() {
    super.initState();
    futureRecipe = fetchRecipe(); // 초기화 시에 응답을 받기 위해 initState에서 호출
    _startLoadingMessagesTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startLoadingMessagesTimer() {
    setState(() {
      _currentMessageIndex = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 9), (timer) {
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  Future<void> saveRecipe(GptChatResponse recipe) async {
    File? imageFile;
    String? imagePath;

    // 이미지 다운로드 및 저장
    if (recipe.imageUrl.isNotEmpty) {
      imageFile = await _downloadImage(recipe.imageUrl);
      if (imageFile != null) {
        imagePath = imageFile.path;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('저장 중입니다...'),
              ],
            ),
          ),
        );
      },
    );

    // 서버 URL 정의
    final url = Uri.parse('${Constants.baseUrl}/recipe/save');

    // HTTP 요청 생성
    final request = http.MultipartRequest('POST', url);

    // 필수 파라미터 추가
    request.fields['userId'] = widget.userId.toString();
    request.fields['title'] = recipe.title.replaceAll("title : ", "");
    request.fields['content'] = recipe.content.replaceAll("content : ", "");

    // 이미지 파일이 있으면 추가
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('imageFile', imagePath));
    }

    // HTTP 요청 보내기
    final streamedResponse = await request.send();

    // 응답 처리
    final response = await http.Response.fromStream(streamedResponse);
    Navigator.of(context).pop();
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

  Future<void> _saveAndDisplayImage(GptChatResponse recipe) async {
    try {
      if (recipe.imageUrl.isNotEmpty) {
        // 이미지 다운로드
        File imageFile = await _downloadImage(recipe.imageUrl);
        setState(() {
          _savedImageFile = imageFile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 URL이 비어 있습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 다운로드할 수 없습니다: $e')),
      );
    }
  }

// 이미지 다운로드 및 저장 메서드 수정
  Future<File> _downloadImage(String url) async {
    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(url);

    if (fileInfo != null) {
      return fileInfo.file;
    } else {
      final file = await cacheManager.downloadFile(url);
      return file.file;
    }
  }

  // 응답을 받는 메서드
  Future<GptChatResponse> fetchRecipe() async {
    try {
      List<PriceDTO> prices = await widget.futurePrices;
      GptChatResponse response = await sendGptChatRequest(widget.userId, prices);
      print('Recipe: ${response.title}');
      print('content: ${response.content}');
      return response;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: FutureBuilder<GptChatResponse>(
          future: futureRecipe,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('불러오는 중...');
            } else if (snapshot.hasError) {
              return Text('레시피 생성 실패');
            } else if (!snapshot.hasData || snapshot.data!.title.isEmpty) {
              return Text('레시피 생성 실패');
            } else if (!snapshot.hasData || snapshot.data!.content.isEmpty) {
              return Text('레시피 생성 실패');
            } else {
              return Text(snapshot.data!.title);
            }
          },
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<GptChatResponse>(
        future: futureRecipe,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Column의 시작 부분에 배치합니다.
                children: [
                  Lottie.asset(
                    'asset/lottie/food_animation.json',
                    width: screenWidth * 0.8,
                  ),
                  SpinKitThreeBounce(
                    color: Colors.amber,
                    size: 30.0,
                  ),
                  SizedBox(height: screenHeight * 0.1),
                  Text(
                    _loadingMessages[_currentMessageIndex],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '레시피 생성에 실패했습니다. 다시 시도하세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSave = false;
                        futureRecipe = fetchRecipe();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.black, width: 1),
                      minimumSize: Size(100, 50),
                    ),
                    child: Text("다시 시도", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.content.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '레시피 생성에 실패했습니다. 다시 시도하세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSave = false;
                        futureRecipe = fetchRecipe();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.black, width: 1),
                      minimumSize: Size(100, 50),
                    ),
                    child: Text("다시 시도", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          } else {
            return ListView(
              children: [
                _buildPhotoArea(snapshot.data!.imageUrl),

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
                            //await _saveAndDisplayImage(snapshot.data!);
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
                        _timer?.cancel();
                        setState(() {
                          isSave = false;
                          futureRecipe = fetchRecipe();
                        });
                        _startLoadingMessagesTimer();
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

                SizedBox(height: 20,)
              ],

            );
          }
        },
      ),
    );
  }

  Widget _buildPhotoArea(String imageUrl) {
    return Center(
      child: GestureDetector(
        // 이미지 선택 기능 추가
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.blue[200],
          ),
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
          )
              : Icon(
            Icons.food_bank,
            color: Colors.grey,
            size: 70,
          ),
        ),
      ),
    );
  }

  Widget _buildSavedImage() {
    return _savedImageFile != null
        ? Image.file(_savedImageFile!)
        : Container(
      width: 300,
      height: 300,
      color: Colors.grey[300],
      child: Center(
        child: Text('이미지가 저장되지 않았습니다.'),
      ),
    );
  }

}