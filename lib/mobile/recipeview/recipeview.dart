import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/mobile/recipeview/recipe.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/dto/RecipeAndComment.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  String searchText = '';
  String sortOption = 'latest'; // Default sort option
  Future<List<RecipeAndComment>>? recipeList;

  @override
  void initState() {
    super.initState();
    recipeList = fetchRecipes();
  }

  Future<List<RecipeAndComment>> fetchRecipes() async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/recipe/share'));
    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> body = jsonDecode(responsebody);
      return body.map((item) => RecipeAndComment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  void handleSearchChange(String searchTerm) {
    setState(() {
      searchText = searchTerm;
    });
  }

  void handleSortChange(String option) {
    setState(() {
      sortOption = option;
    });
  }

  List<RecipeAndComment> getFilteredRecipes(List<RecipeAndComment> recipes, String searchTerm) {
    List<RecipeAndComment> filteredRecipes = recipes.where((recipe) => recipe.title.toLowerCase().contains(searchTerm.toLowerCase())).toList();

    if (sortOption == 'comments') {
      filteredRecipes.sort((a, b) => b.count.compareTo(a.count));
    } else {
      filteredRecipes.sort((a, b) => b.modifyDate.compareTo(a.modifyDate));
    }

    return filteredRecipes;
  }

  List<TextSpan> _highlightText(String text, String searchTerm) {
    if (searchTerm.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    int start = 0;
    int index = text.toLowerCase().indexOf(searchTerm.toLowerCase(), start);

    while (index >= 0) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + searchTerm.length),
        style: TextStyle(color: Colors.red),
      ));
      start = index + searchTerm.length;
      index = text.toLowerCase().indexOf(searchTerm.toLowerCase(), start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("공유페이지"),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: handleSortChange,
            itemBuilder: (BuildContext context) {
              return {'latest', 'comments'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice == 'latest' ? '최신순' : '댓글 수'),
                );
              }).toList();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // Adjust the height as needed
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // Adjust the width as needed
            // Add some margin if needed
            child: TextField(
              onChanged: handleSearchChange,
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
                border: OutlineInputBorder( // Here you can change the border
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0), // Optional, to make rounded borders
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: FutureBuilder<List<RecipeAndComment>>(
          future: recipeList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load recipes'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('레시피 목록이 없습니다.'));
            } else {
              List<RecipeAndComment> filteredRecipes = getFilteredRecipes(snapshot.data!, searchText);
              return Scrollbar(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4.15,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    RecipeAndComment recipe = filteredRecipes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecipePage(recipe: recipe)),
                        ).then((value) => setState(() {
                          recipeList = fetchRecipes();
                        }));
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Adjust the value as needed
                        ),
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
                              padding: const EdgeInsets.all(6.0),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: recipe.title.length > 14 ? 10.0 : 15.0,
                                      color: Colors.black, fontWeight: FontWeight.bold),
                                  children: _highlightText(recipe.title, searchText),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(2.5),
                              child:Text("댓글 : ${recipe.count}", textAlign: TextAlign.center,),

                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
