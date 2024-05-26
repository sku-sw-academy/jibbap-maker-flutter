import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';

class ShoppingResultPage extends StatefulWidget {
  final String itemname;
  final String kindname;
  final String rankname;

  ShoppingResultPage({required this.itemname, required this.kindname, required this.rankname});

  @override
  _ShoppingResultPageState createState() => _ShoppingResultPageState();
}

class _ShoppingResultPageState extends State<ShoppingResultPage> {
  late DataTable dataTable;
  final PriceService priceService = PriceService();
  List<PriceDTO> searchData = [];
  List<FlSpot> spots = [];

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
    updateDataTable();
  }

  void updateDataTable() async {
      try {
        searchData = await priceService.fetchSearchdata(
            widget.itemname,
            widget.kindname,
            widget.rankname
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

  @override
  Widget build(BuildContext context) {
    String itemName = searchData.isNotEmpty && searchData[0].itemCode != null ? "(소매가격)"+searchData[0].itemCode.itemName+"/" : "";
    String rankName = searchData.isNotEmpty && searchData[0].rankName != null ? searchData[0].rankName + "/": "";
    String kindName = searchData.isNotEmpty && searchData[0].kindName != null ? searchData[0].kindName +"/": "";
    String unit = searchData.isNotEmpty && searchData[0].unit != null ? searchData[0].unit : "";

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itemname}'),
        centerTitle: true,
        backgroundColor: Colors.limeAccent,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20,),

          Center(
            child: Text("$itemName$kindName$rankName$unit", style: TextStyle(
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
                  reservedSize: 35,
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
      fontSize: 10,
    );
    double maxY = _calculateMaxY(searchData);
    String text = "";

    if(maxY <= 10000){
      if(value.toInt() % 200 == 0){
        text = (value.toDouble() / 1000).toString() + "k";
      }else{
        text = "";
      }
    }else if(maxY <= 50000){
      if(value.toInt() % 500 == 0){
        text = (value.toDouble() / 1000).toString() + "k";
      }else{
        text = "";
      }
    }else{
      if(value.toInt() % 1000 == 0){
        text = (value.toDouble() / 1000).toString() + "k";
      }else{
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

}
