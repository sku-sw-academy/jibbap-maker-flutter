import 'package:flutter/material.dart';
import 'package:flutter_splim/service/userservice.dart';

class FindPasswordScreen extends StatefulWidget{
  FindPasswordScreen({super.key});

  @override
  _FindPasswordScreenState createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final UserService userService = UserService();
  String password = '';

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
            "비밀번호 재설정",
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
                      '이메일',
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
                          hintText: '이메일을 입력하세요',
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
                    String email = _emailController.text.toString();
                    password = await userService.sendPassword(email);

                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Color(0xFF45B0C5),
                          title: Text("전송완료",style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'GowunBatang',
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: -0.40,
                          ),),
                          content: Text("해당 이메일로 비밀번호 재설정\n링크를 전송하였습니다.", style: TextStyle(
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
                                Navigator.pop(context);
                                Navigator.pop(context);
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
                      '링크 전송',
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