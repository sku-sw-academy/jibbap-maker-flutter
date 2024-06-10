import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/dto/RegisterDTO.dart';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'package:flutter_splim/mobile/mypage/recipe/share.dart';

class RecipeListPage extends StatefulWidget {
  final int userId;

  RecipeListPage({required this.userId});

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<RecipeDTO>> recipeList;
  bool isEditing = false;
  List<int> selectedIds = [];

  @override
  void initState() {
    super.initState();
    recipeList = fetchRecipeList(widget.userId);
  }

  Future<List<RecipeDTO>> fetchRecipeList(int userId) async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/recipe/list/$userId'));

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List jsonResponse = json.decode(responseBody);
        return jsonResponse.map((data) => RecipeDTO.fromJson(data)).toList();
      } else {
        print('Error: ${response.reasonPhrase}');
        throw Exception('Failed to load recipe list');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to load recipe list');
    }
  }

  Future<void> deleteRecipes(List<int> recipeIds) async {
    try {
      for (int id in recipeIds) {
        final response = await http.put(
          Uri.parse('${Constants.baseUrl}/recipe/deleteAt/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          print('Recipe with ID $id deleted successfully');
        } else {
          print('Failed to delete recipe with ID $id: ${response.reasonPhrase}');
        }
      }
      setState(() {
        recipeList = fetchRecipeList(widget.userId);
        selectedIds.clear();
      });
    } catch (e) {
      print('Error deleting recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 목록'),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
        actions: [
          // 편집 버튼
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) selectedIds.clear();
              });
            },
            child: Text(
              isEditing ? '완료' : '편집',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<RecipeDTO>>(
        future: recipeList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('레시피 목록이 없습니다.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                RecipeDTO recipeDTO = snapshot.data![index];
                return ListTile(
                  title: Text(recipeDTO.title),
                  trailing: Text(recipeDTO.modifyDate.toString().substring(5,10).replaceAll("-", "/")),
                  onTap: (){
                    if(!isEditing){
                      if(recipeDTO.status){
                        if(recipeDTO.userDTO.id == widget.userId){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SharePage(recipeDTO: recipeDTO))).then((value) => setState(() {
                            recipeList = fetchRecipeList(widget.userId);
                          }));
                        }else{

                        }
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyPage(recipeDTO: recipeDTO,))).then((value) => setState(() {
                          recipeList = fetchRecipeList(widget.userId);
                        }));
                      }
                    }
                  },
                  leading: isEditing
                      ? Checkbox(
                    value: selectedIds.contains(recipeDTO.id),
                    onChanged: (value) {
                      setState(() {
                        if (value != null && value) {
                          if(recipeDTO.userDTO.id == widget.userId){
                            selectedIds.add(recipeDTO.id);
                          }
                        } else {
                          selectedIds.remove(recipeDTO.id);
                        }
                      });
                    },
                  )
                      : null,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: isEditing
          ? FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            onPressed: () {
            deleteRecipes(selectedIds);
            },
            child: Icon(Icons.delete),
      ) : null, // Only show FAB when editing
    );
  }
}

