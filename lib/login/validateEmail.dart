import 'package:flutter/material.dart';
import 'package:flutter_splim/login/signout.dart';
import 'package:http/http.dart' as http;

class Account {
  String? email;
  String? nickname;
  String? password;

  Account({
    this.email,
    this.nickname,
    this.password,
  });
}

class ValidateEmail extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  //final String authkey;

  final String email;
  final String nickname;
  final String password;

  ValidateEmail({
    required this.email,
    required this.nickname,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double widthRatio = deviceWidth / 375;
    double heightRatio = deviceHeight / 812;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼 클릭 시 이전 화면으로 이동
          },
        ),
        title: Container(
          margin: EdgeInsets.only(
            left: widthRatio * 84,
          ),
          child: Text(
            "인증",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'GowunBatang',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: -0.40,
            ),
          ),
        ),
        backgroundColor: Color(0xA545B0C5),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          // 배경색상 설정
          decoration: BoxDecoration(

          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: heightRatio * 41, left: widthRatio * 33),
                child: Row(
                  children: [
                    Text(
                      '인증번호',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.40,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: widthRatio * 20,
                          top: heightRatio * 12,
                          bottom: heightRatio * 9),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      margin: EdgeInsets.only(left: widthRatio * 23),
                      width: widthRatio * 240,
                      height: heightRatio * 52,
                      child: TextFormField(
                        // TextFormField의 속성들 설정
                        textInputAction:TextInputAction.next,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '인증번호를 입력하세요',
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 13,
                            fontFamily: 'GowunBatang',
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: -0.33,
                          ),
                          // 다른 속성들 설정
                        ),
                        controller: _emailController,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: widthRatio * 300,
                height: heightRatio * 52,
                margin: EdgeInsets.only(
                  top: heightRatio * 22,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF46B1C6), // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 원하는 값으로 조절
                    ),
                  ),
                  onPressed: () async{
                    // 로그인 버튼이 눌렸을 때의 처리
                    // 아이디와 비밀번호를 사용하여 로그인을 시도하고 결과에 따라 처리
                    String num = _emailController.text.toString();

                    Map<String, dynamic> signUpData = {
                      'email': email,
                      'nickname': nickname,
                      'password': password,
                      // 다른 필요한 데이터도 추가할 수 있음
                    };

                    // 회원가입 데이터를 JSON 형태로 변환


                    // MySQL 서버 URL
                    String url = 'http://your_mysql_server_url';

                    showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Color(0xFF45B0C5),
                            title: Text("인증 되었습니다.",style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'GowunBatang',
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: -0.40,
                            ),),
                            content: Text("", style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'GowunBatang',
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: -0.40,
                            ),),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                },
                                child: Text("확인", style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'GowunBatang',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                  letterSpacing: -0.40,
                                ),),
                              )
                            ],
                          )
                      );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}