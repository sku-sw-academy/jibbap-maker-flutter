import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/search/searchResult.dart';
import 'package:flutter_splim/dto/PreferDTO.dart';
import 'package:flutter_splim/service/preferservice.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';

class BannedPage extends StatefulWidget {
  @override
  _BannedPageState createState() => _BannedPageState();
}

class _BannedPageState extends State<BannedPage>{

  final PreferService preferService = PreferService();
  List<PreferDTO> list = [];

  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      preferService.getPreferList(user.id, 2).then((preferences) {
        setState(() {
          list = preferences;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: ListView.builder(
        itemCount: list.length,  // _childLists의 길이만큼 아이템을 생성
        itemBuilder: (context, index) {
          final prefer = list[index];

          return ListTile(
            title: Text(list[index].item.itemName),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                setState(() {
                  prefer.prefer = 1;  // prefer 값을 0으로 설정
                });

                try {
                  await preferService.updatePrefer(prefer);  // 서버에 업데이트 요청

                  setState(() {
                    list.removeAt(index);  // 리스트에서 해당 항목 삭제
                  });
                } catch (e) {
                  print('Error updating preference: $e');
                  setState(() {
                    prefer.prefer = 1;  // 업데이트 실패 시 prefer 값을 복원
                  });
                }
              },
            ),// 각 아이템을 ListTile로 변환하여 표시
          );
        },
      ),
    );

  }

}