import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class PreferDetailPage extends StatefulWidget {
  final List<PriceDTO> price;

  PreferDetailPage({required this.price});

  @override
  _PreferDetailPageState createState() => _PreferDetailPageState();
}

class _PreferDetailPageState extends State<PreferDetailPage> {
  late List<PriceDTO> _data;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _data = widget.price;
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
        title: Text("맞춤 소비(등락률 기준)"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent[100],
        scrolledUnderElevation: 0,
      ),
      body: _data.isEmpty
          ? Center(child: Text('No data found'))
          : Scrollbar(
        child: _buildTableView(_data),
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
          double extent;
          switch (index) {
            case 0:
            case 1:
              extent = 0.15; // 좁은 열
              break;
            case 2:
              extent = 0.10; // 좁은 열
              break;
            case 3:
              extent = 0.10; // 좁은 열
              break;
            case 4:
              extent = 0.20; // 넓은 열
              break;
            case 5:
              extent = 0.10; // 좁은 열
              break;
            case 6:
              extent = 0.20; // 넓은 열
              break;
            default:
              extent = 1 / 7;
              break;
          }
          return TableSpan(
            foregroundDecoration: index == 0 ? decoration : null,
            extent: FractionalTableSpanExtent(extent),
          );
        },
        rowBuilder: (index) {
          return TableSpan(
            foregroundDecoration: index == 0 ? decoration : null,
            extent: FixedTableSpanExtent(50),
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
                label = '당일가격\n(원)';
                break;
              case 5:
                label = '등락률\n(%)';
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
