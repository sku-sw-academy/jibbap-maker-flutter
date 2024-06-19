import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/dto/RegisterDTO.dart';
import 'package:flutter_splim/service/userservice.dart';

class ValidateEmail extends StatefulWidget {
  final String email;
  final String nickname;
  final String password;

  ValidateEmail({
    required this.email,
    required this.nickname,
    required this.password,
  });

  @override
  _ValidateEmailState createState() => _ValidateEmailState();
}

class _ValidateEmailState extends State<ValidateEmail> {
  final TextEditingController _authController = TextEditingController();
  final UserService _userService = UserService();
  String code = '';
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes countdown
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    code = await _userService.sendAuthEmail(widget.email);
    _startTimer();
    setState(() {}); // UI 업데이트를 위해 상태를 갱신
  }

  void _startTimer() {
    _remainingSeconds = 300;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
          code = "";
        });
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
        title: Text(
            "인증",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'GowunBatang',
              fontWeight: FontWeight.w400,
              height: 0,
              letterSpacing: -0.40,
            )
        ),
        centerTitle: true,
        backgroundColor: Color(0xA545B0C5),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          // 배경색상 설정
          decoration: BoxDecoration(),
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
                        textInputAction: TextInputAction.next,
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
                        controller: _authController,
                        onFieldSubmitted: (_) async {
                          String authCode = _authController.text.toString();

                          try {
                            if (authCode == code) {
                              final result = await _userService.register(
                                  widget.email, widget.nickname,
                                  widget.password);
                              if (result == 'OK') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('회원가입 성공')),
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('인증번호가 틀렸습니다. 다시 입력하세요.')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to register: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: heightRatio * 10),
                child: Text(
                  '남은 시간: ${_formatTime(_remainingSeconds)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'GowunBatang',
                    fontWeight: FontWeight.w700,
                  ),
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
                    backgroundColor: Colors.white, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 원하는 값으로 조절
                    ),
                  ),
                  onPressed: _canResend
                      ? () async {
                    try {
                      code = await _userService.sendAuthEmail(widget.email);
                      _startTimer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('인증 이메일을 다시 전송했습니다.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send email: $e')),
                      );
                    }
                  }
                      : () async {
                    String authCode = _authController.text.toString();

                    try {
                      if (authCode == code) {
                        final result = await _userService.register(widget.email,
                            widget.nickname, widget.password);
                        if (result == 'OK') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('회원가입 성공')),
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('인증번호가 틀렸습니다. 다시 해주세요.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to register: $e')),
                      );
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      _canResend ? '재전송' : '확인', // 타이머가 종료되면 '재전송' 버튼으로 변경
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
            ],
          ),
        ),
      ),
    );
  }
}
