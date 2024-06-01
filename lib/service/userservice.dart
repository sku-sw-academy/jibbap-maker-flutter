import 'package:flutter_splim/dto/AuthLoginRequest.dart';
import 'package:flutter_splim/dto/AuthLoginResponse.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/RegisterDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';

class UserService{

  Future<String> register(String email, String nickname, String password) async {
    final registerDTO = RegisterDTO(
      email: email,
      nickname: nickname,
      password: password,
    );
    
    final url = Uri.parse('${Constants.baseUrl}/api/auth/signup');
    
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(registerDTO.toJson()),
    );

    if (response.statusCode == 200) {
      return 'OK';
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<AuthLoginResponse> login(String email, String password) async {
    final authLoginRequest = AuthLoginRequest(
      email: email,
      password: password,
    );

    final url = Uri.parse('${Constants.baseUrl}/api/auth/login');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(authLoginRequest.toJson()),
    );

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responsebody);
      return AuthLoginResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String> sendAuthEmail(String email) async {
    final url = Uri.parse('${Constants.baseUrl}/email/auth'); // 엔드포인트를 /email/auth로 설정
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'}; // 서버가 기대하는 Content-Type
    final body = 'to=$email'; // 서버가 기대하는 형식으로 body를 구성

    print('Sending POST request to $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body; // 인증번호를 그대로 반환
    } else {
      throw Exception('Failed to send email: ${response.body}');
    }
  }

  Future<String> sendPassword(String email, String nickname) async {
    final url = Uri.parse('${Constants.baseUrl}/email/password');
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = 'to=$email&nickname=$nickname'; // 닉네임 추가
    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to send email');
    }
  }

  Future<UserDTO> fetchUser() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/api/auth/user'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      return UserDTO.fromJson(json.decode(responsebody));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<String>> fetchEmails() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/api/auth/emails'));

    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = json.decode(responseBody);
      List<String> emailList = jsonList.cast<String>();
      return emailList;
    } else {
      throw Exception('Failed to load emails');
    }
  }

}