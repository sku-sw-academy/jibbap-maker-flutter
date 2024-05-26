import 'package:flutter_splim/dto/ItemDTO.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemService{
  Future<void> incrementItemCount(String itemName) async {
    final response = await http.post(
      Uri.parse('http://172.30.1.22:8080/items/increment/$itemName'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to increment item count');
    }
  }
}