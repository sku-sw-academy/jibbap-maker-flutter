import 'package:flutter/material.dart';

class SelectedPage extends StatelessWidget {
  final String suggestion;

  SelectedPage({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$suggestion'),
      ),
      body: Center(
        child: Text('$suggestion'),
      ),
    );
  }
}