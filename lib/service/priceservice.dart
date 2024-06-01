import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/dto/Shop.dart';
import 'package:flutter_splim/constant.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class PriceService{
  Future<List<PriceDTO>> fetchPriceDetails(String regday) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/saving/detail/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price details');
    }
  }

  Future<List<PriceDTO>> fetchPriceTop3(String regday) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/saving/top3/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price top3');
    }
  }

  Future<List<Shop>> fetchPriceIncreaseValues(String regday) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/shopping/increase/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => Shop.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shop increase');
    }
  }

  Future<List<Shop>> fetchPriceDecreaseValues(String regday) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/shopping/decrease/$regday'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => Shop.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shop decrease');
    }
  }

  Future<List<PriceDTO>> fetchSearchdata(String itemName, String kindName, String rankName) async{
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/search/$itemName/$kindName/$rankName'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load search');
    }
  }

  Future<List<PriceDTO>> fetchPopularItemPrices6() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/popular6'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();

    } else {
      throw Exception('Failed to load popular item prices');
    }
  }

  Future<List<PriceDTO>> fetchPopularItemPrices9() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/popular9'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();

    } else {
      throw Exception('Failed to load popular item prices');
    }
  }

  Future<List<PriceDTO>> fetchPreferPrice(int id) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/prices/prefer/$id'));

    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((dynamic item) => PriceDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load price top3');
    }
  }

}