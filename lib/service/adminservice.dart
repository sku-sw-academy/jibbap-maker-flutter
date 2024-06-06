import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';
import 'package:flutter_splim/dto/AuthLoginRequest.dart';
import 'package:flutter_splim/dto/AuthLoginResponse.dart';
import 'package:flutter_splim/dto/AdminDTO.dart';

class AdminService{
  Future<AdminDTO> getAdminInfo(String refreshToken) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/api/admin/AdminInfo/$refreshToken'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // 새로운 accessToken을 헤더에 포함
      },// 서버의 엔드포인트 URL을 여기에 입력하세요
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AdminDTO.fromJson(jsonDecode(responseData));
    } else {
      // 서버에서 오류 응답을 받은 경우
      throw Exception('Failed to load admin info: ${response.body}');
    }
  }

  Future<AuthLoginResponse> login(String email, String password) async {
    final url = Uri.parse('${Constants.baseUrl}/api/admin/login'); // 엔드포인트 URL을 여기에 입력하세요

    Map<String, String> requestBody = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // 서버에서 올바른 응답을 받은 경우
      var responsebody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responsebody);
      return AuthLoginResponse.fromJson(responseData);
    } else {
      // 서버에서 오류 응답을 받은 경우
      throw Exception('Failed to login: ${response.body}');
    }
  }
}