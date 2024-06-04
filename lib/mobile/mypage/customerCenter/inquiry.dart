import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/question.dart';

class InquiryPage extends StatefulWidget{
  @override
  _InquiryPageState createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '문의사항이 있으면 아래 버튼을 클릭하세요.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionPage()));
        },
        child: Icon(Icons.question_answer),
        tooltip: '문의하기',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 버튼 위치를 화면의 오른쪽 하단으로 설정
    );
  }
}