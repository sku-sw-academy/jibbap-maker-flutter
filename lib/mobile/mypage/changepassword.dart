import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/login/validate.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>(); // 폼의 키

  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  FocusNode _passwordFocus = FocusNode();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("비밀번호 변경"),
        backgroundColor: Colors.limeAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // 폼의 키 설정
          child: SingleChildScrollView(
           child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: '현재 비밀번호',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                    icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: !_showCurrentPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: !_showNewPassword,
                validator: (value) {
                  if (CheckValidate().validatePassword(_passwordFocus, value) != null) {
                    return CheckValidate().validatePassword(_passwordFocus, value);
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '새 비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
                obscureText: !_showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  } else if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // 폼의 유효성 검사를 실행하고 유효할 경우 비밀번호 변경 로직 실행
                  if (_formKey.currentState!.validate()) {
                    // 비밀번호 변경 로직 추가
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('비밀번호 변경 완료'),
                        content: Text('비밀번호가 성공적으로 변경되었습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // 다이얼로그 닫기
                              Navigator.pop(context); // 이전 화면으로 돌아가기
                            },
                            child: Text('확인'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20), // 버튼의 세로(padding) 길이를 조정합니다.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 버튼의 모서리를 조정하여 네모로 만듭니다.
                  ),
                  minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기를 조정합니다. double.infinity로 설정하면 가로폭을 꽉 채우도록 만듭니다.
                ),
                child: Text('변경'),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
