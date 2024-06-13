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

  Future<List<PreferDTO>> getPreferList(int userId, int prefer) async {
    final apiUrl = '${Constants.baseUrl}/prefer/list/$userId/$prefer';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 응답이 성공하면 JSON을 PreferDTO 리스트로 변환하여 반환합니다.
        var responsebody = utf8.decode(response.bodyBytes);
        List<dynamic> body = jsonDecode(responsebody);
        List<PreferDTO> preferences = body.map((dynamic item) => PreferDTO.fromJson(item)).toList();
        return preferences;
      } else {
        throw Exception('Failed to fetch preferences');
      }
    } catch (e) {
      // 예외 처리
      print('Error fetching preferences: $e');
      // 예외가 발생하면 throw하지 않고 여기서 처리합니다.
      return []; // 빈 리스트를 반환하여 실패한 경우 처리합니다.
    }
  }

  Future<PreferDTO?> getPreference(int id, String itemName) async {
    final url = Uri.parse('${Constants.baseUrl}/prefer/$id/$itemName');
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      final body = jsonDecode(responsebody);
      return PreferDTO.fromJson(body);
    } else {
      print('Failed to load preference: ${response.statusCode}');
      return null;
    }
  }


}