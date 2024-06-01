import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/login/validate.dart';
import 'package:flutter_splim/mobile/login/validateEmail.dart';
import 'package:flutter_splim/service/userservice.dart';

class CreateAccountScreen extends StatefulWidget{
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  FocusNode _emailFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();

  late List<String> emailList =[];
  late UserService userService = UserService();


  @override
  void initState() {
    super.initState();
    fetchEmail();
  }

  Future<void> fetchEmail() async {
    try {
      emailList = await userService.fetchEmails();
      print(emailList);
    } catch (e) {
      print('Error fetching emails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                "회원가입",
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
        body : Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: heightRatio * 30),
                    width: widthRatio * 250,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.badge),
                        labelText: "닉네임",
                        labelStyle: TextStyle(
                          color: Color(0xE5001F3F),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xE5001F3F),
                          ),
                        ),
                        isDense: true,
                        hintText: "닉네임을 입력하세요",
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.33,
                      ),
                      controller: _nickNameController,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return '닉네임을 입력하세요.';
                        }else if(value.length > 20){
                          return '닉네임을 20자 이하로 해주세요.';
                        }
                          return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: heightRatio * 30),
                    width: widthRatio * 250,
                    child: TextFormField(
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "e-mail",
                        labelStyle: TextStyle(
                          color: Color(0xE5001F3F),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xE5001F3F),
                          ),
                        ),
                        isDense: true,
                        hintText: '이메일을 입력하세요',
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 10,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.33,
                      ),
                      controller: _emailController,
                      validator: (value) => CheckValidate().validateEmail(_emailFocus, value, emailList),
                        onSaved: (value) {}
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: heightRatio * 30),
                    width: widthRatio * 250,
                    child: TextFormField(
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "P/W",
                        labelStyle: TextStyle(
                          color: Color(0xE5001F3F),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xE5001F3F),
                          ),
                        ),
                        isDense: true,
                        hintText: '특수문자, 대소문자, 숫자 포함 8자리 이상 입력하세요.',
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),

                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.33,
                      ),
                      controller: _passwordController,
                      validator: (value) => CheckValidate().validatePassword(_passwordFocus, value),
                      onSaved: (value) {},
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: heightRatio * 30),
                    width: widthRatio * 250,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.enhanced_encryption),
                        labelText: "P/W C",
                        labelStyle: TextStyle(
                          color: Color(0xE5001F3F),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xE5001F3F),
                          ),
                        ),
                        isDense: true,
                        hintText: '비밀번호를 한번 더 입력하세요',
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontFamily: 'GowunBatang',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.33,
                        ),

                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'GowunBatang',
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.33,
                      ),
                      controller: _passwordConfirmController,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return '비밀번호를 한 번 더 입력해주세요.';
                        }else if(value != _passwordController.text.toString()){
                          return '비밀번호가 일치하지 않습니다.';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                  ),
                  Container(
                    width: widthRatio * 250,
                    height: heightRatio * 52,
                    margin: EdgeInsets.symmetric(
                      vertical: heightRatio * 30,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF46B1C6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async{
                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();

                          String emailValue = _emailController.text.toString();
                          String nicknameValue = _nickNameController.text.toString();
                          String passwordValue = _passwordController.text.toString();

                          Navigator.push(context, MaterialPageRoute(builder: (context) => ValidateEmail(email: emailValue, nickname: nicknameValue, password: passwordValue,)));

                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '가입하기',
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
      )
    );
  }

}

