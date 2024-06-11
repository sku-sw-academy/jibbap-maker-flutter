import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/mobile/recipeview/recipe.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/constant.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  String searchText = '';
  List<RecipeDTO> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/recipe/share'));
    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      setState(() {
        recipes = body.map((item) => RecipeDTO.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  void handleSearchChange(String searchTerm) {
    setState(() {
      searchText = searchTerm;
    });
  }

  List<RecipeDTO> getFilteredRecipes(String searchTerm) {
    return recipes.where((recipe) => recipe.title.toLowerCase().contains(searchTerm.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<RecipeDTO> filteredRecipes = getFilteredRecipes(searchText);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Container(
          width: screenWidth * 0.7,
          child: TextField(
            onChanged: handleSearchChange,
            decoration: InputDecoration(
              hintText: "검색어를 입력하세요",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Scrollbar( // Scrollbar 추가
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 3.8,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              RecipeDTO recipe = filteredRecipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecipePage(recipe: recipe)),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            color: Colors.grey[300],
                            child: recipe.image != null && recipe.image!.isNotEmpty
                                ? Image.network('${Constants.baseUrl}/recipe/images/${recipe.image}')
                                : CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              radius: 50,
                                  child: Icon(Icons.food_bank, size: 50, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipe.title,
                          style: TextStyle(fontSize: 16.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
