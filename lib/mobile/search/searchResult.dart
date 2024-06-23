import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/PreferDTO.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_splim/constant.dart';
import 'dart:io';
import 'package:flutter_splim/service/preferservice.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';

class SelectedPage extends StatefulWidget {
  final String itemname;

  SelectedPage({required this.itemname});

  @override
  _SelectedPageState createState() => _SelectedPageState();
}

class _SelectedPageState extends State<SelectedPage> {
  List<String> kinds = [];
  List<List<String>> ranks = [];
  int? selectedKindIndex;
  int? selectedRankIndex;
  late DataTable dataTable;
  final PriceService priceService = PriceService();
  final PreferService preferService = PreferService();
  List<PriceDTO> searchData = [];
  List<FlSpot> spots = [];
  UserDTO? user;
  PreferDTO? preferDTO;

  @override
  void initState() {
    super.initState();
    dataTable = DataTable(
      columns: [
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
      ],
      rows: [],
    );
    fetchKinds();
    user = Provider.of<UserProvider>(context, listen: false).user;
    if(user != null)
      fetchPreference();
  }

  Future<void> fetchPreference() async {
    PreferService preferService = PreferService();
    PreferDTO? result = await preferService.getPreference(user!.id, widget.itemname);
    setState(() {
      preferDTO = result;
    });
  }

  Future<void> fetchKinds() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/prices/kinds/${widget.itemname}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        String responsebody = utf8.decode(response.bodyBytes);
        kinds = List<String>.from(json.decode(responsebody));
        if (kinds.isNotEmpty) {
          selectedKindIndex = 0;
          fetchRanks(selectedKindIndex!);// 초기 선택된 종류의 등급을 가져옴
        }
      });
    } else {
      print('Failed to load kinds: ${response.statusCode}');
    }
  }

  Future<void> fetchRanks(int kindIndex) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/prices/ranks/${widget.itemname}/${kinds[kindIndex]}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        String responsebody = utf8.decode(response.bodyBytes);
        List<String> rankList = List<String>.from(json.decode(responsebody));
        if (ranks.length > kindIndex) {
          ranks[kindIndex] = rankList;
        } else {
          ranks.add(rankList);
        }
        selectedRankIndex = 0;
        updateDataTable();// 등급 리스트의 첫 번째 값을 선택
      });
    } else {
      print('Failed to load ranks for ${kinds[kindIndex]}: ${response.statusCode}');
    }
  }

  void updateDataTable() async {
    if (selectedKindIndex != null && selectedRankIndex != null) {
      try {
        searchData = await priceService.fetchSearchdata(
            widget.itemname,
            kinds[selectedKindIndex!],
            ranks[selectedKindIndex!][selectedRankIndex!]
        );
        setState((){
          dataTable = DataTable(
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black26),
            border: TableBorder.all(
              width: 3.0,
              color: Colors.black12,
            ),
            columns: [
              DataColumn(label: Expanded(child: Text('날짜', textAlign: TextAlign.center, style: TextStyle(fontSize: 12),),)),
              DataColumn(label: Expanded(child: Text('가격(원)', textAlign: TextAlign.center , style: TextStyle(fontSize: 12)), )),
              DataColumn(label: Expanded(child: Text('등락률(%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
            ],
            rows: searchData.map((price) {
              Color textColor;
              if (price.value > 0) {
                textColor = Colors.red;
              } else if (price.value < 0) {
                textColor = Colors.blue;
              } else {
                textColor = Colors.black;
              }
              return DataRow(
                cells: [
                  DataCell(Text(price.regday, textAlign: TextAlign.center)),
                  DataCell(Text(price.dpr1, textAlign: TextAlign.center)),
                  DataCell(Text(price.value.toString()+"%", textAlign: TextAlign.center, style: TextStyle(color: textColor),)),
                ],
              );
            }).toList(),
          );

          spots = _getSpots(searchData);
        });
      } catch (e) {
        print('Failed to load search data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (searchData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.itemname}', style: TextStyle(fontSize: 25),),
          centerTitle: true,
          backgroundColor: Colors.grey[100],
        ),
        body: Center(
          child: CircularProgressIndicator(), // 데이터를 로딩하는 동안 로딩 표시기 표시
        ),
      );
    }

    String rankName = searchData.isNotEmpty && searchData[0].rankName != null ? "등급: " + searchData[0].rankName+", ": "";
    String kindName = searchData.isNotEmpty && searchData[0].kindName != null ? "종류: " + searchData[0].kindName + ", ": "";
    String unit = searchData.isNotEmpty && searchData[0].unit != null ? "단위: " + searchData[0].unit : "";

    List<Widget> _buildAppBarActions() {
      List<Widget> actions = [];

      if (user != null) {
        actions.addAll([
          TextButton(
              onPressed:() async{
                if (preferDTO != null) {
                  if (preferDTO!.prefer != 0) {
                    setState(() {
                      preferDTO!.prefer = 0;
                    });
                    await preferService.updatePrefer(preferDTO!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('선호 명단에 추가되었습니다.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이미 선호 식재료에 있습니다.'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preference data not loaded yet.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

          } , child: Text("선호",
            style: TextStyle(color: Colors.green),
          ),
          ),

          TextButton(
            onPressed:() async{
              if (preferDTO != null) {
                if (preferDTO!.prefer != 2) {
                  setState(() {
                    preferDTO!.prefer = 2;
                  });
                  await preferService.updatePrefer(preferDTO!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('차단 명단에 추가되었습니다.'),
                      backgroundColor: Colors.red[200],
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이미 차단된 식재료 입니다.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preference data not loaded yet.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } , child: Text("차단",
            style: TextStyle(color: Colors.red),
          ),

          ),
        ]);
      }

      return actions;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itemname}', style: TextStyle(fontSize: 25),),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.grey[100],
        actions: _buildAppBarActions(),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (kinds.isNotEmpty)
                    Container(
                      width: 100, // 너비 설정
                      height: 50, // 높이 설정
                      child: DropdownButton<int>(
                        value: selectedKindIndex,
                        isExpanded: true,
                        onChanged: (int? newIndex) {
                          setState(() {
                            selectedKindIndex = newIndex;
                            if (newIndex != null) {
                              fetchRanks(newIndex);
                            }
                          });
                        },
                        items: List.generate(kinds.length, (index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(kinds[index], style: TextStyle(
                              fontSize: _calculateFontSize(kinds[index]), // 글자 크기 동적으로 조절
                            ),),
                            key: Key(kinds[index]),
                          );
                        }),
                      ),
                    )
                  else
                    CircularProgressIndicator(),

                  SizedBox(width: 20),

                  if (selectedKindIndex != null && ranks.length > selectedKindIndex! && ranks[selectedKindIndex!] != null && ranks[selectedKindIndex!].isNotEmpty)
                    Container(
                      width: 85, // 너비 설정
                      height: 50, // 높이 설정
                      child: DropdownButton<int>(
                        value: selectedRankIndex,
                        isExpanded: true,
                        onChanged: (int? newIndex) {
                          setState(() {
                            selectedRankIndex = newIndex;
                            updateDataTable();
                          });
                          print('Selected item: ${ranks[selectedKindIndex!][selectedRankIndex!]}');
                        },
                        items: List.generate(ranks[selectedKindIndex!].length, (index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(ranks[selectedKindIndex!][index]),
                            key: Key(ranks[selectedKindIndex!][index]),
                          );
                        }),
                      ),
                    )
                  else
                    CircularProgressIndicator(),
                ],
              ),

              SizedBox(width: 20),

            ],
          ),

          SizedBox(height: 20),

          Center(
            child: Text("$kindName$rankName$unit", style: TextStyle(
              fontSize: 18, // 폰트 크기
              fontWeight: FontWeight.bold, // 폰트 굵기
              color: Colors.black, // 폰트 색상
            ),
            ),
          ),

          SizedBox(height: 20),

          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: dataTable,
            ),
          ),

          SizedBox(height: 20),

          _buildLineChart(searchData),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<PriceDTO> searchData) {
    double maxY = _calculateMaxY(searchData);
    double minY = _calculateMinY(searchData);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _getSpots(searchData.reversed.toList()),
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 4,
                isStrokeCapRound: false,
                belowBarData: BarAreaData(show: true, color: Colors.lightBlue.withOpacity(0.3)),
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 30,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: rightTitleWidgets,
                  reservedSize: 28,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black, width: 1)),
            minX: 0,
            maxX: searchData.length.toDouble() - 1,
            minY: minY,
            maxY: maxY,
          ),
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    double maxY = _calculateMaxY(searchData);
    double minY = _calculateMinY(searchData);
    double result = maxY - minY;
    String text = "";

    String truncateToOneDecimal(double number) {
      String numberStr = (number.toDouble() / 1000).toString();
      int decimalIndex = numberStr.indexOf('.');
      if (decimalIndex != -1 && decimalIndex + 2 < numberStr.length) {
        return numberStr.substring(0, decimalIndex + 2) + "k";
      } else {
        return numberStr + "k";
      }
    }

    if (result <= 100) {
      if (value.toInt() % 50 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    } else if (result <= 1000) {
      if (value.toInt() % 200 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    } else if (result <= 5000) {
      if (value.toInt() % 1000 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    } else {
      if (value.toInt() % 10000 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    }

    return SideTitleWidget(
      axisSide: AxisSide.left, // 왼쪽에 배치
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    int dataSize = searchData.length;
    if (dataSize > 0) {
      // searchData에서 regday 값을 가져옵니다.
      List<PriceDTO> reverse = searchData.reversed.toList();
      String regday = reverse[value.toInt()].regday.substring(5,10).replaceAll("-", "/");
      // 가져온 regday 값을 사용하여 텍스트 위젯 생성
      text = Text(regday, style: style);
    } else {
      // searchData가 비어있을 경우 빈 텍스트 반환
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text = "";

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  double _calculateMaxY(List<PriceDTO> searchData) {
    if(searchData != null && searchData.isNotEmpty){
      double maxDpr1 = double.parse(searchData[0].dpr1.replaceAll(",", ""));

      for(int i = 1; i < searchData.length; i++){
        double num = double.parse(searchData[i].dpr1.replaceAll(",", ""));

        if(num > maxDpr1){
          maxDpr1 = num;
        }
      }

      return maxDpr1 * 1.03; //
    }else{
      return 1.0;
    }

  }

  double _calculateMinY(List<PriceDTO> searchData) {
    if(searchData != null && searchData.isNotEmpty){
      double minDpr1 = double.parse(searchData[0].dpr1.replaceAll(",", ""));

      for(int i = 1; i < searchData.length; i++){
        double num = double.parse(searchData[i].dpr1.replaceAll(",", ""));

        if(num < minDpr1){
          minDpr1 = num;
        }
      }

      return minDpr1 * 0.95;
    }else{
      return 0.0;
    }

  }

  List<FlSpot> _getSpots(List<PriceDTO> searchData) {
    List<FlSpot> spots = [];
    for (int i = searchData.length-1; i >= 0; i--) {
      spots.add(FlSpot(i.toDouble(), double.parse(searchData[i].dpr1.replaceAll(",", ""))));
    }
    return spots;
  }

  double _calculateFontSize(String text) {
    // 글자 길이에 따라 동적으로 크기 계산 또는 원하는 방식으로 크기 계산
    if (text.length <= 5) {
      return 16.0;
    } else if (text.length <= 10) {
      return 10.0;
    } else {
      return 8.0;
    }
  }

}
