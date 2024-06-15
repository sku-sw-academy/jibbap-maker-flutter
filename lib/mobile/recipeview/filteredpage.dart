import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/mobile/recipeview/recipe.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/dto/RecipeAndComment.dart';

class FilteredRecipePage extends StatefulWidget {
  final List<RecipeAndComment> filteredRecipes;
  final String searchTerm;

  FilteredRecipePage({required this.filteredRecipes, required this.searchTerm});

  @override
  _FilteredRecipePageState createState() => _FilteredRecipePageState();
}

class _FilteredRecipePageState extends State<FilteredRecipePage> {
  String sortOption = 'latest'; // Default sort option

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("검색 결과"),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4.15,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: widget.filteredRecipes.length,
          itemBuilder: (context, index) {
            RecipeAndComment recipe = widget.filteredRecipes[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipePage(recipe: recipe)),
                );
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
                          children: _highlightText(recipe.title, widget.searchTerm),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Text("댓글 : ${recipe.count}", textAlign: TextAlign.center,),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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

  void handleSortChange(String option) {
    setState(() {
      sortOption = option;
      widget.filteredRecipes.sort((a, b) {
        if (sortOption == 'latest') {
          return b.modifyDate.compareTo(a.modifyDate);
        } else {
          return b.count.compareTo(a.count);
        }
      });
    });
  }
}
