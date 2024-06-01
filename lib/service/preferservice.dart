import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';
import 'package:flutter_splim/dto/PreferDTO.dart';

class PreferService{
  Future<List<PreferDTO>> getListPreferences(int id) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prefer/list/$id'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      List<PreferDTO> preferences = body.map((dynamic item) => PreferDTO.fromJson(item)).toList();
      return preferences;
    } else {
      throw Exception('Failed to load preferences');
    }
  }

  Future<void> updatePrefer(PreferDTO preferDTO) async {
    final apiUrl = '${Constants.baseUrl}/prefer/update';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(preferDTO.toJson()), // PreferDTO를 JSON 문자열로 직렬화하여 본문에 전송합니다.
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 요청이 성공하면 아무 것도 반환하지 않습니다.
      } else {
        throw Exception('Failed to update preferDTO');
      }
    } catch (e) {
      // 예외 처리
      print('Error updating preferDTO: $e');
      // 예외가 발생하면 throw하지 않고 여기서 처리합니다.
    }
  }
}