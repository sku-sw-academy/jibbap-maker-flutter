import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/recipeview/recipe.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  String searchText = '';
  List<String> recipes = ['Recipe 1', 'Recipe 2', 'Recipe 3', 'Recipe 4', 'Delicious Recipe', 'Tasty Recipe'];

  void handleSearchChange(String searchTerm) {
    setState(() {
      searchText = searchTerm;
    });
  }

  List<String> getFilteredSuggestions(String searchTerm) {
    return recipes.where((recipe) => recipe.toLowerCase().contains(searchTerm.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<String> filteredRecipes = getFilteredSuggestions(searchText);

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
              String recipe = filteredRecipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecipePage()),
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
                            child: Icon(Icons.food_bank, size: 50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipe,
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
