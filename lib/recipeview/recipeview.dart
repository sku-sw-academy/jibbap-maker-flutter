import 'package:flutter/material.dart';

class RecipeView extends StatefulWidget {
  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  List<ItemModel> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe'),
      ),

      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].text),
            leading: Image.network(items[index].imageUrl),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            items.add(ItemModel(
              text: 'Item ${items.length + 1}',
              imageUrl: 'https://via.placeholder.com/150', // 예시 이미지 URL
            ));
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ItemModel {
  final String text;
  final String imageUrl;

  ItemModel({required this.text, required this.imageUrl});
}
