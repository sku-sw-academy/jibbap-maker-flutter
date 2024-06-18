import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/login/validate.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/service/userservice.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late UserDTO user;// 폼의 키
  late UserService userService = UserService();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  FocusNode _passwordFocus = FocusNode();
  bool _showCurrentPassword = false;

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("비밀번호 변경", style: TextStyle(fontSize: 25),),
        backgroundColor: Colors.grey[100],
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
                maxLength: 15,
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
                maxLength: 15,
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
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  } else if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) async {
                  if (_formKey.currentState!.validate()) {
                    try{
                      String current = _currentPasswordController.text;
                      String newPassword = _newPasswordController.text;
                      String respone = await userService.changePassword(user.id, current, newPassword);

                      if(respone != "Wrong password"){
                        user.password = respone;
                        Navigator.pop(context); // 다이얼로그 닫기
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
                        );
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('현재 비밀번호가 잘못되었습니다.')),
                        );
                      }

                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("오류가 발생했습니다.")),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  // 폼의 유효성 검사를 실행하고 유효할 경우 비밀번호 변경 로직 실행
                  if (_formKey.currentState!.validate()) {
                    try{
                      String current = _currentPasswordController.text;
                      String newPassword = _newPasswordController.text;
                      String respone = await userService.changePassword(user.id, current, newPassword);

                      if(respone != "Wrong password"){
                        user.password = respone;
                        Navigator.pop(context); // 다이얼로그 닫기
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
                        );
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('현재 비밀번호가 잘못되었습니다.')),
                        );
                      }

                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("오류가 발생했습니다.")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20), // 버튼의 세로(padding) 길이를 조정합니다.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey, width: 1),
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
