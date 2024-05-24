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
        length: 4,
        child :
        Scaffold(
          appBar: AppBar(
            title: Text("고객센터"),
            backgroundColor: Colors.limeAccent,
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: 'FAQ'),
                Tab(text: '문의내역'),
                Tab(text: '고객의 소리'),
                Tab(text: '공지사항',)
              ],
            ),
          ),

          body: TabBarView(
            children: [
              FAQPage(),
              InquiryPage(),
              QuestionPage(),
              NoticePage()
            ],
          ),
        )
    );
  }

}