import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:flutter/services.dart';

class DetailPage extends StatefulWidget {
  final String regday;

  DetailPage({required this.regday});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<PriceDTO>> _data;
  final PriceService priceService = PriceService();

  @override
  void initState() {
    super.initState();
    _data = priceService.fetchPriceDetails(widget.regday);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 세로
      DeviceOrientation.landscapeLeft, // 가로
      DeviceOrientation.landscapeRight, // 가로
    ]);
  }

  @override
  void dispose() {
    // 페이지가 dispose 될 때 기본 회전 모드로 복원
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 세로
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상세페이지"),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<List<PriceDTO>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            List<PriceDTO> prices = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로 스크롤을 위해 설정
              child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor:
                        MaterialStateColor.resolveWith((states) => Colors.grey),
                      border: TableBorder.all(
                        width: 3.0,
                        color:Colors.black12,
                      ),
                      columns: [
                        DataColumn(
                            label:
                          Expanded(
                            child: Text('품목', textAlign:TextAlign.center)
                          )
                        ),

                        DataColumn(label: Expanded(
                            child:
                            Text('품종', textAlign:TextAlign.center))
                        ),

                        DataColumn(label: Expanded(
                            child:
                            Text('단위', textAlign:TextAlign.center))
                        ),

                        DataColumn(label: Expanded(
                            child:
                            Text('등급', textAlign:TextAlign.center))
                        ),

                        DataColumn(label: Expanded(
                            child:
                            Text('당일가격', textAlign:TextAlign.center))
                        ),

                        DataColumn(label: Expanded(
                            child:
                            Text('등락률', textAlign:TextAlign.center))
                        ),

                        DataColumn(label: Expanded(
                            child:
                            Text('날짜', textAlign:TextAlign.center))
                        ),

                      ],
                      rows: prices.map((price) {
                        return DataRow(cells: [
                          DataCell(Text(price.itemCode.itemName, textAlign:TextAlign.center)),
                          DataCell(Text(price.kindName, textAlign:TextAlign.center)),
                          DataCell(Text(price.unit, textAlign:TextAlign.center)),
                          DataCell(Text(price.rankName, textAlign:TextAlign.center)),
                          DataCell(Text(price.dpr1, textAlign:TextAlign.center)),
                          DataCell(
                          Text( price.value.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                          color: price.value < 0
                          ? Colors.blue
                              : price.value == 0
                          ? Colors.black
                              : Colors.red,
                            ),
                          ),
                        ),
                          DataCell(Text(price.regday, textAlign:TextAlign.center)),
                          // Add more cells as needed
                        ]
                        );
                      }
                      ).toList(),
                    ),
                  ),
            );
          }
        },
      ),
    );
  }

}
