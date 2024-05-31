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

    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(registerDTO.toJson()),
    );

    if (response.statusCode == 200 && response.body == 'OK') {
      return 'OK';
    } else {
      throw Exception('Failed to register');
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

  Future<String> sendPassword(String email) async {
    final url = Uri.parse('${Constants.baseUrl}/email/password');
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'}; // 서버가 기대하는 Content-Type
    final body = 'to=$email'; // 서버가 기대하는 형식으로 body를 구성
    final response = await http.post(
      url,
      body: body,
      headers: headers,
    );

    if (response.statusCode == 200) {
      // 서버로부터 받은 인증 번호를 반환
      return response.body;
    } else if (response.statusCode == 404) {
      // 유효하지 않은 이메일 주소에 대한 오류 처리
      throw Exception('User not found');
    } else {
      throw Exception('Failed to send email');
    }
  }

}