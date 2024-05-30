import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/faq.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/inquiry.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/qustion.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/notice.dart';

class CenterPage extends StatefulWidget{
  @override
  _CenterPageState createState() => _CenterPageState();
}

class _CenterPageState extends State<CenterPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 3,
        child :
        Scaffold(
          appBar: AppBar(
            title: Text("고객센터"),
            scrolledUnderElevation: 0,
            backgroundColor: Colors.lightBlueAccent,
            centerTitle: true,
            bottom:
            PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Container(
                color: Colors.white, // TabBar 배경색 설정
                child: TabBar(
                  labelColor: Colors.black, // 선택된 탭의 글자 색상
                  unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 글자 색상
                  indicatorColor: Colors.blue, // 선택된 탭의 하단 선 색상
                  indicatorWeight: 3.0, // 선택된 탭의 하단 선 두께
                  tabs: [
                    Tab(text: 'FAQ'),
                    Tab(text: '고객 지원'),
                    Tab(text: '공지사항'),
                  ],
                ),
              ),
            ),
          ),

          body: TabBarView(
            children: [
              FAQPage(),
              InquiryPage(),
              NoticePage()
            ],
          ),
        )
    );
  }

}