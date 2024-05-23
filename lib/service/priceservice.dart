import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceService{
  Future<List<PriceDTO>> fetchPriceDetails(String regday) async {
    final response = await http.get(Uri.parse('http://192.168.0.54:8080/prices/saving/detail/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price details');
    }
  }

  Future<List<PriceDTO>> fetchPriceTop3(String regday) async {
    final response = await http.get(Uri.parse('http://192.168.0.54:8080/prices/saving/top3/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price details');
    }
  }

}