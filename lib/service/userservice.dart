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
      headers: <String, String>{
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
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/email/auth'),
      body: {'to': email},
    );

    if (response.statusCode == 200) {
      // 서버로부터 받은 인증 번호를 반환
      return response.body;
    } else {
      throw Exception('Failed to send email');
    }
  }

  Future<String> sendPassword(String email) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/email/password'),
      body: {'to': email},
    );

    if (response.statusCode == 200) {
      // 서버로부터 받은 인증 번호를 반환
      return response.body;
    } else {
      throw Exception('Failed to send email');
    }
  }

}