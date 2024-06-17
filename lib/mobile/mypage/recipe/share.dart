import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // If you need to decode JSON responses

class SharePage extends StatefulWidget {
  final RecipeDTO recipeDTO;

  SharePage({required this.recipeDTO});

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.recipeDTO.content,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 1,
              enabled: false,
              decoration: InputDecoration(
                hintText: widget.recipeDTO.comment,
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
            ),
            ),
          ),
           Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyPage(recipeDTO: widget.recipeDTO)),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                      ),
                      side: BorderSide(color: Colors.black, width: 1),
                      fixedSize: Size(100, 50),
                      // 다른 스타일 속성들...
                    ),
                    child: Text("수정하기"),
                  ),

                  SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: () async {
                      await updateRecipeShareStatus(widget.recipeDTO.id);
                      widget.recipeDTO.status = false;
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyPage(recipeDTO: widget.recipeDTO)),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                      ),
                      side: BorderSide(color: Colors.black, width: 1),
                      fixedSize: Size(100, 50),
                      // 다른 스타일 속성들...
                    ),
                    child: Text("비공개"),
                  ),
                ]

          ),

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
