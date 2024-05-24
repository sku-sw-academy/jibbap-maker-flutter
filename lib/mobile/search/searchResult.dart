import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';

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
  List<PriceDTO> searchData = [];
  List<FlSpot> spots = [];

  @override
  void initState() {
    super.initState();
    dataTable = DataTable(
      columns: [
        DataColumn(label: Text('날짜')),
        DataColumn(label: Text('가격')),
        DataColumn(label: Text('등락률')),
      ],
      rows: [],
    );
    fetchKinds();
  }

  Future<void> fetchKinds() async {
    final response = await http.get(
      Uri.parse('http://172.30.1.22:8080/prices/kinds/${widget.itemname}'),
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
      Uri.parse('http://172.30.1.22:8080/prices/ranks/${widget.itemname}/${kinds[kindIndex]}'),
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
              DataColumn(label: Expanded(child: Text('날짜', textAlign: TextAlign.center),)),
              DataColumn(label: Expanded(child: Text('가격', textAlign: TextAlign.center))),
              DataColumn(label: Expanded(child: Text('등락률', textAlign: TextAlign.center))),
            ],
            rows: searchData.map((price) {
              return DataRow(
                cells: [
                  DataCell(Text(price.regday, textAlign: TextAlign.center)),
                  DataCell(Text(price.dpr1, textAlign: TextAlign.center)),
                  DataCell(Text(price.value.toString(), textAlign: TextAlign.center)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itemname}'),
        centerTitle: true,
        backgroundColor: Colors.limeAccent,
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
                    DropdownButton<int>(
                      value: selectedKindIndex,
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
                          child: Text(kinds[index]),
                          key: Key(kinds[index]),
                        );
                      }),
                    )
                  else
                    DropdownButton<int>(
                      items: [], // 빈 리스트 전달하여 빈 드롭다운 버튼 생성
                      onChanged: null, // onChanged를 null로 설정하여 클릭 불가능하게 함
                    ),
                  SizedBox(width: 20),

                  if (selectedKindIndex != null && ranks.length > selectedKindIndex! && ranks[selectedKindIndex!] != null && ranks[selectedKindIndex!].isNotEmpty)
                    DropdownButton<int>(
                      value: selectedRankIndex,
                      onChanged: (int? newIndex) {
                        setState(() {
                          selectedRankIndex = newIndex;
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
                    )
                  else
                    DropdownButton<int>(
                      items: [], // 빈 리스트 전달하여 빈 드롭다운 버튼 생성
                      onChanged: null, // onChanged를 null로 설정하여 클릭 불가능하게 함
                    ),
                ],
              ),

              SizedBox(width: 20),

              ElevatedButton(
                onPressed: () async {
                  if (selectedKindIndex != null && selectedRankIndex != null) {
                    updateDataTable();
                  }
                },
                child: Text('검색'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 사각형 모양의 버튼을 원하는 경우 원하는 모양의 BorderRadius 설정
                  ),
                ),
              ),
            ],
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
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _getSpots(searchData),
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 20,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: rightTitleWidgets,
                  reservedSize: 20,
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
      fontSize: 15,
    );
    String text = "";

    return Text(text, style: style, textAlign: TextAlign.left);
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
      String regday = searchData[value.toInt()].regday.substring(5,10).replaceAll("-", "/");
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

      return maxDpr1 * 1.2; // 20% 여유를 더해줍니다.
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

      return minDpr1 * 0.5;
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

}
