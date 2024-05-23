import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("상세페이지"),),
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
                  MaterialStateColor.resolveWith((states) => Colors.blue),
                  columnSpacing: 10,
                  columns: [
                    DataColumn(label: Text('품목')),
                    DataColumn(label: Text('품종')),
                    DataColumn(label: Text('단위')),
                    DataColumn(label: Text('등급')),
                    DataColumn(label: Text('당일가격')),
                    DataColumn(label: Text('등락률')),
                  ],
                  rows: prices.map((price) {
                    return DataRow(cells: [
                      DataCell(Text(price.itemCode.itemName)),
                      DataCell(Text(price.kindName)),
                      DataCell(Text(price.unit)),
                      DataCell(Text(price.rankName)),
                      DataCell(Text(price.dpr1)),
                      DataCell(Text(price.value.toString())),
                      // Add more cells as needed
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }

}
