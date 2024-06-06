import 'package:flutter/material.dart';
import 'package:flutter_splim/desktop/admin.dart';
import 'package:flutter_splim/dto/AdminDTO.dart';
import 'package:flutter_splim/service/adminservice.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';
import 'package:flutter_splim/provider/adminprovider.dart';
import 'package:flutter_splim/dto/AuthLoginRequest.dart';
import 'package:flutter_splim/dto/AuthLoginResponse.dart';
import 'package:flutter_splim/service/adminservice.dart';

class LoginAdminPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final secureService = Provider.of<SecureService>(context, listen: false);
    final AdminService  adminService = AdminService();

    void _loginSuccess(AdminDTO adminDTO) {
      adminProvider.updateAdmin(adminDTO);
    }



    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double widthRatio = deviceWidth / 375;
    double heightRatio = deviceHeight / 812;

    return Scaffold(
        appBar: AppBar(
          title: Text("로그인"),
          backgroundColor: Color(0xA545B0C5),
          centerTitle: true,
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
                          onFieldSubmitted: (_) async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();

                            try {
                              final response = await adminService.login(email, password);
                              secureService.writeToken("admin_accessToken", response.accessToken);
                              secureService.writeToken("admin_refreshToken", response.refreshToken);
                              final admin = await adminService.getAdminInfo(response.refreshToken);

                               _loginSuccess(admin);

                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('로그인 실패')),
                              );
                            }
                          },
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
                      onPressed: () async {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();

                        try {

                          final response = await adminService.login(email, password);
                          secureService.writeToken("admin_accessToken", response.accessToken);
                          secureService.writeToken("admin_refreshToken", response.refreshToken);
                          final admin = await adminService.getAdminInfo(response.refreshToken);
                          _loginSuccess(admin);

                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그인 실패: $e')),
                          );
                          print(e);
                        }
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
                ],
              )
          ),
        )
    );
  }
}