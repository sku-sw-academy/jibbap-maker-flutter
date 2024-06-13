import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // If you need to decode JSON responses

class OtherRecipePage extends StatefulWidget {
  final RecipeDTO recipeDTO;

  OtherRecipePage({required this.recipeDTO});

  @override
  _OtherRecipePageState createState() => _OtherRecipePageState();
}

class _OtherRecipePageState extends State<OtherRecipePage> {
  final ImagePicker picker = ImagePicker();

  void initState() {

  }

  Future<void> updateRecipeShareStatus(int id) async {
    final url = Uri.parse('${Constants.baseUrl}/recipe/status/$id'); // Adjust the URL as per your backend endpoint
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successfully updated
      print('Recipe status updated successfully.');
    } else {
      // Handle error
      print('Failed to update recipe status.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(widget.recipeDTO.title, style: TextStyle(fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          _buildPhotoArea(),
          Divider(),

          Row(
            children: [
              SizedBox(width: 10),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[200],
                backgroundImage: widget.recipeDTO.userDTO.profile != null &&
                    widget.recipeDTO.userDTO.profile!.isNotEmpty
                    ? NetworkImage(
                    "${Constants.baseUrl}/api/auth/images/${widget.recipeDTO.userDTO.profile}")
                    : null,
                child: widget.recipeDTO.userDTO.profile != null &&
                    widget.recipeDTO.userDTO.profile!.isNotEmpty
                    ? null
                    : Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "닉네임: " + widget.recipeDTO.userDTO.nickname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                ],
              )
            ],
          ),
          Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.recipeDTO.content,
              style: TextStyle(fontSize: 16.0),
            ),
          ),

          Divider(),

          SizedBox(height: 20),

        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return Center(
      child: GestureDetector(
        // 이미지 선택 기능 추가
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.blue[200],
            image: widget.recipeDTO.image!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage('${Constants.baseUrl}/recipe/images/${widget.recipeDTO.image}'),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: widget.recipeDTO.image!.isEmpty
              ? Icon(Icons.food_bank, color: Colors.grey, size: 70)
              : null,
        ),
      ),
    );
  }

}
