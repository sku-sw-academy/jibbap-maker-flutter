import 'package:flutter_splim/dto/AuthLoginRequest.dart';
import 'package:flutter_splim/dto/AuthLoginResponse.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/RegisterDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';
import 'package:flutter_splim/dto/AuthLogoutRequest.dart';

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

  Future<String> changeNickName(int userId, String newNickName) async {
    var url = Uri.parse('${Constants.baseUrl}/api/auth/nickName');
    var response = await http.post(
      url,
      body: {
        'userId': userId.toString(),
        'NickName': newNickName,
      },
    );

    if (response.statusCode == 200) {
        return newNickName;
    } else {
      return "error";
    }
  }

  Future<String> changePassword(int userId, String currentPassword, String newPassword) async {
    final url = Uri.parse('${Constants.baseUrl}/api/auth/changePassword');
    final response = await http.post(
      url,
      body: {
        'userId': userId.toString(),
        'current': currentPassword,
        'new': newPassword,
      },
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      return responseBody;
      // Handle successful response
    } else {
      throw Exception('Failed to change password: ${response.statusCode}');
      // Handle error response
    }
  }

  Future<UserDTO> getUserInfo(String refreshToken) async {
    final url = Uri.parse('${Constants.baseUrl}/api/auth/userInfo/$refreshToken');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // 새로운 accessToken을 헤더에 포함
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return UserDTO.fromJson(responseData);
    } else {
      throw Exception('사용자 정보를 가져오는 데 실패했습니다.');
    }
  }

  Future<void> logout(AuthLogoutRequest request) async {
    final url = Uri.parse('${Constants.baseUrl}/api/auth/logout');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'id': request.id,
      'refreshToken': request.refreshToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // 로그아웃 성공
        print('로그아웃 성공');
      } else {
        // 로그아웃 실패
        print('로그아웃 실패: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류
      print('네트워크 오류: $e');
    }
  }

  Future<void> updateUserPushSettings(UserDTO user) async {
    final url = Uri.parse('${Constants.baseUrl}/api/auth/updatePushSettings');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update push settings');
    }
  }

}