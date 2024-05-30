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
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionPage()));
          },
          child: Text("문의하기"),

        ),
      ),
    );
  }

}