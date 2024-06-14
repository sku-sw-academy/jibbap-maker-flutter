import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/DB/DBHelper.dart';
import 'package:flutter_splim/mobile/search/searchResult.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/service/itemservice.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:flutter_splim/mobile/search/result.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>  with SingleTickerProviderStateMixin {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ItemService itemService = ItemService();
  final PriceService priceService = PriceService();
  String searchText = '';
  List<String> suggestions = []; // 예시 자동완성 목록
  late Future<List<Record>> recentSearches;
  late Future<List<PriceDTO>> futurePopularNames;
  stt.SpeechToText _speech = stt.SpeechToText(); // SpeechToText instance
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  late AnimationController _animationController;
  bool _isSpeechActive = false;
  String recognizedText = '';

  void _onRefresh() async {
    // 새로고침 로직을 여기에 구현하세요.
    recentSearches = dbHelper.getRecords();
    futurePopularNames = priceService.fetchPopularItemPrices9();
    fetchSuggestions();
    await Future.delayed(Duration(seconds: 2));
    _refreshController.refreshCompleted();// 임시로 2초 대기
  }

  @override
  void initState() {
    super.initState(); // widget에서 dbHelper를 가져와서 초기화
    recentSearches = dbHelper.getRecords();
    futurePopularNames = priceService.fetchPopularItemPrices9();
    fetchSuggestions();
    _initializeSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleSearchChange(String searchTerm) {
    setState(() {
      searchText = searchTerm;
    });
  }

  List<String> getFilteredSuggestions(String searchTerm) {
    // 입력된 검색어와 일치하는 자동완성 결과를 필터링하여 반환합니다.
    return suggestions
        .where((suggestion) =>
        suggestion.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  Future<void> fetchSuggestions() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/items/names'));
    if (response.statusCode == 200) {
      setState(() {
        String responsebody = utf8.decode(response.bodyBytes);
        suggestions = List<String>.from(json.decode(responsebody));
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onError: (error) {
        showToast("발음이 명확하지 않습니다.");
        setState(() {
          _isSpeechActive = false; // Speech to Text 비활성화
        });
      },
      onStatus: (status) {
        print('Status: $status');
      },
    );

    if (available) {
      print('Speech recognition initialized');
    } else {
      print('Speech recognition not available');
    }
  }

  void _startListening() {
    setState(() {
      _isSpeechActive = true; // Speech to Text 활성화
    });
    _speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords;
          searchText = result.recognizedWords;
          if(suggestions.contains(searchText))
            handleSearchChange(searchText);
          _isSpeechActive = false;
        });
      },

      localeId: 'ko_KR', // 한국어 설정
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isSpeechActive = false; // Deactivate animation when speech stops
    });
    _animationController.stop();
  }


  @override
  Widget build(BuildContext context) {
    List<String> filteredSuggestions = getFilteredSuggestions(searchText);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: screenWidth * 0.7, // 너비를 전체 화면 너비의 70%로 설정
          child: TextField(
            onChanged: handleSearchChange,
            decoration: InputDecoration(
              hintText: "검색어를 입력하세요",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // 내용과 경계 사이의 여백 조정
            ),
            onSubmitted: (String searchText) {
              if (searchText.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultPage(searchText: searchText, suggestions: suggestions),
                  ),
                ).then((value) => setState(() {
                  futurePopularNames = priceService.fetchPopularItemPrices9();
                }));
              }
            },
            controller: TextEditingController(text: searchText),
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return IconButton(
                icon: Icon(Icons.mic,
                    color: _speech.isListening
                        ? Colors.red.withOpacity(_animationController.value)
                        : Colors.black),
                onPressed: () {
                  if (_speech.isListening) {
                    _stopListening(); // Stop listening and hide animation
                  } else {
                    _startListening(); // Start listening and show animation
                  }
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchText.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultPage(searchText: searchText, suggestions: suggestions),
                  ),
                ).then((value) => setState(() {
                  futurePopularNames = priceService.fetchPopularItemPrices9();
                }));
              }
            },
          ),
          SizedBox(width: 25,)
        ],
      ),

      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: Stack(
            children:[

          ListView(
        children: [
          if (searchText.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "최근 검색어",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                FutureBuilder(
                  future: recentSearches,
                  builder: (context, AsyncSnapshot<List<Record>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Record> recentSearchList = snapshot.data!;
                      return recentSearchList.isEmpty
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                           child: Text(
                          "검색어가 없습니다",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                          : Column(
                        children: recentSearchList.map((record) {
                          return ListTile(
                            title: Text(
                              record.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text((record.date as String).substring(5,10).replaceAll("-", "."), style: TextStyle(fontSize: 13),),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await dbHelper.deleteRecord(record.name);
                                    setState(() {
                                      recentSearches = dbHelper.getRecords();
                                    });
                                  },
                                ),
                                // 다른 위젯들을 추가할 수 있음
                              ],
                            ),

                            onTap: () async {
                              bool isExisting = await dbHelper.checkIfSuggestionExists(record.name);

                              if (isExisting) {
                                // suggestion이 이미 존재하면 업데이트 수행
                                await dbHelper.updateRecord(Record(name: record.name, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                              }

                              else {
                                // suggestion이 존재하지 않으면 데이터베이스에 삽입
                                await dbHelper.insertRecord(Record(name: record.name, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                              }

                              await itemService.incrementItemCount(record.name);

                              setState(() {
                                recentSearches = dbHelper.getRecords();
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SelectedPage(itemname: record.name),
                                ),
                              ).then((value) => setState(() {

                              }));
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),

                Divider( // 여기에 선을 추가합니다.
                  thickness: 2.0,
                  color: Colors.grey[300],
                  indent: 16.0,
                  endIndent: 16.0,
                ),

                FutureBuilder<List<PriceDTO>>(
                  future: futurePopularNames,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data found'));
                    } else {
                      List<PriceDTO> popularPrices = snapshot.data!;
                      return Container(
                        height: screenHeight / 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                "추천 검색어",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0), // Wrap 위젯에 왼쪽 패딩 추가
                            child:
                                Wrap(
                              spacing: 3.0,
                              runSpacing: 3.0,
                              children: popularPrices.map((price) {
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // 반지름 값을 버튼의 너비 또는 높이보다 작게 지정하여 원형으로 만듭니다.
                                    ),
                                    side: BorderSide(color: Colors.black, width: 2),
                                    elevation: 2.0,

                                    minimumSize: Size(63, 40),
                                  ),
                                  onPressed: () async {
                                    bool isExisting = await dbHelper.checkIfSuggestionExists(price.itemCode.itemName);

                                    if (isExisting) {
                                      // suggestion이 이미 존재하면 업데이트 수행
                                      await dbHelper.updateRecord(Record(name: price.itemCode.itemName, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                                    } else {
                                      // suggestion이 존재하지 않으면 데이터베이스에 삽입
                                      await dbHelper.insertRecord(Record(name: price.itemCode.itemName, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                                    }

                                    await itemService.incrementItemCount(price.itemCode.itemName);

                                    setState(() {
                                      recentSearches = dbHelper.getRecords();
                                    });

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SelectedPage(itemname: price.itemCode.itemName),
                                      ),
                                    ).then((value) => setState(() {
                                      futurePopularNames = priceService.fetchPopularItemPrices9();
                                    }));
                                  },
                                  child: Text(
                                    price.itemCode.itemName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

          if (searchText.isNotEmpty && filteredSuggestions.isNotEmpty)
            Column(
              children: filteredSuggestions.map((suggestion) {
                List<TextSpan> textSpans = [];
                int index = 0;
                String lowerCaseSuggestion = suggestion.toLowerCase();
                String lowerCaseSearchText = searchText.toLowerCase();

                while (index < suggestion.length) {
                  int startIndex = lowerCaseSuggestion.indexOf(lowerCaseSearchText, index);
                  if (startIndex == -1) {
                    // 검색어와 일치하는 부분이 더 이상 없는 경우 나머지 텍스트를 그대로 추가
                    textSpans.add(TextSpan(text: suggestion.substring(index)));
                    break;
                  }

                  // 검색어 앞에 있는 텍스트 추가
                  textSpans.add(TextSpan(text: suggestion.substring(index, startIndex)));

                  // 검색어 부분 추가 (빨간색으로 표시)
                  textSpans.add(TextSpan(
                    text: suggestion.substring(startIndex, startIndex + searchText.length),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ));

                  // 다음 검색 시작 위치 설정
                  index = startIndex + searchText.length;
                }
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: textSpans,
                    ),
                  ),
                  onTap: () async {
                    bool isExisting = await dbHelper.checkIfSuggestionExists(suggestion);

                    if (isExisting) {
                      // suggestion이 이미 존재하면 업데이트 수행
                      await dbHelper.updateRecord(Record(name: suggestion, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                      setState(() {
                        recentSearches = dbHelper.getRecords();
                      });
                    }

                    else {
                      // suggestion이 존재하지 않으면 데이터베이스에 삽입
                      await dbHelper.insertRecord(Record(name: suggestion, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                      setState(() {
                        recentSearches = dbHelper.getRecords();
                      });
                    }

                    await itemService.incrementItemCount(suggestion);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectedPage(itemname: suggestion),
                      ),
                    ).then((value) => setState(() {
                      futurePopularNames = priceService.fetchPopularItemPrices9();
                    }));
                  },
                );
              }).toList(),
            ),
        ],
      ),
              if (_isSpeechActive)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 100, // 원하는 높이 설정
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return IgnorePointer(
                        ignoring: !_isSpeechActive,
                        child: CustomPaint(
                          painter: WavePainter(_animationController),
                        ),
                      );
                    },
                  ),
                ),

            ]
      ),
    ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> _animation;

  WavePainter(this._animation) : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent.withOpacity(0.5);
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 3;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i,
        size.height / 2 + waveHeight * sin((i / waveLength + _animation.value * 2 * pi)),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}