import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/login/signup.dart';
import 'package:flutter_splim/mobile/login/findpassword.dart';

class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

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
            ), onPressed: () {
            Navigator.pop(context);
          },
          ),
          title: Container(
            margin: EdgeInsets.only(
              left: widthRatio * 104,
            ),
            child: Text(
                "로그인",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'GowunBatang',
                  fontWeight: FontWeight.w400,
                  height: 0,
                  letterSpacing: -0.40,
                )
            ),
          ),
          backgroundColor: Color(0xA545B0C5),
        ),
        body: Center(
          child: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: heightRatio * 41, left: widthRatio * 33
                    ),
                    child: Row(
                      children: [
                        Text('이메일',
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
                              bottom: heightRatio * 9
                          ),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                            ),
                          ),
                          margin: EdgeInsets.only(left: widthRatio * 23),
                          width: widthRatio * 240,
                          height: heightRatio * 52,
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '이메일을 입력하세요',
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontSize: 13,
                                fontFamily: 'GowunBatang',
                                fontWeight: FontWeight.w700,
                                height: 0,
                                letterSpacing: -0.33,
                              ),
                            ),
                            controller: _emailController,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: heightRatio * 22,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: widthRatio * 37),
                    child: Row(children: [
                      Text(
                        'P/W',
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
                            bottom: heightRatio * 9
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        margin: EdgeInsets.only(left: widthRatio * 28),
                        width: widthRatio * 240,
                        height: heightRatio * 52,
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '비밀번호를 입력하세요',
                            hintStyle: TextStyle(
                              color: Color(0xFFCCCCCC),
                              fontSize: 13,
                              fontFamily: 'GowunBatang',
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: -0.33,
                            ),

                          ),
                          controller: _passwordController,
                        ),
                      )
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
                        backgroundColor: Color(0xFF46B1C6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async{
                        String email = _emailController.text.toString();
                        String password = _passwordController.text.toString();

                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.black,
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
                  Container(
                    margin: EdgeInsets.only(top: heightRatio * 26,
                        left: widthRatio * 30,
                        right: widthRatio * 30),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountScreen()));
                          },
                          child: Text(
                            "회원가입",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'GowunBatang',
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              decorationThickness: 1.5,
                              height: 0,
                              letterSpacing: -0.40,
                            ),
                          ),
                        ),
                        Spacer(),
                        TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FindPasswordScreen()));
                            },
                            child: Text(
                              "P/W 찾기",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'GowunBatang',
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationThickness: 1.5,
                                decorationColor: Colors.white,
                                height: 0,
                                letterSpacing: -0.40,
                              ),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              )
          ),
        )
    );
  }
}

