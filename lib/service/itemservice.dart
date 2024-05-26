import 'package:flutter_splim/dto/ItemDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';

class ItemService{
  Future<void> incrementItemCount(String itemName) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/items/increment/$itemName'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to increment item count');
    }
  }
}