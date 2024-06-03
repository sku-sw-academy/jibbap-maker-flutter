import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

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
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상세페이지"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
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
            return _buildTableView(prices);
          }
        },
      ),
    );
  }

  Widget _buildTableView(List<PriceDTO> prices) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: TableView.builder(
        columnCount: 7,
        rowCount: prices.length + 1,
        pinnedRowCount: 1,
        pinnedColumnCount: 0,
        columnBuilder: (index) {
          return TableSpan(
            foregroundDecoration: index == 0 ? decoration : null,
            extent: const FractionalTableSpanExtent(1 / 7),
          );
        },
        rowBuilder: (index) {
          return TableSpan(
            foregroundDecoration: index == 0 ? decoration : null,
            extent: const FixedTableSpanExtent(50),
          );
        },
        cellBuilder: (context, vicinity) {
          final isStickyHeader = vicinity.yIndex == 0;
          String label = '';
          TextStyle textStyle = const TextStyle();

          if (isStickyHeader) {
            switch (vicinity.xIndex) {
              case 0:
                label = '품목';
                break;
              case 1:
                label = '품종';
                break;
              case 2:
                label = '단위';
                break;
              case 3:
                label = '등급';
                break;
              case 4:
                label = '당일가격';
                break;
              case 5:
                label = '등락률';
                break;
              case 6:
                label = '날짜';
                break;
            }
          } else {
            final price = prices[vicinity.yIndex - 1];
            switch (vicinity.xIndex) {
              case 0:
                label = price.itemCode.itemName;
                break;
              case 1:
                label = price.kindName;
                break;
              case 2:
                label = price.unit;
                break;
              case 3:
                label = price.rankName;
                break;
              case 4:
                label = price.dpr1;
                break;
              case 5:
                label = price.value.toString();
                textStyle = TextStyle(
                  color: price.value < 0
                      ? Colors.blue
                      : price.value == 0
                      ? Colors.black
                      : Colors.red,
                );
                break;
              case 6:
                label = price.regday;
                break;
            }
          }

          return TableViewCell(
            child: ColoredBox(
              color: isStickyHeader ? Colors.transparent : colorScheme.background,
              child: Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      label,
                      style: isStickyHeader
                          ? TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      )
                          : textStyle,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
