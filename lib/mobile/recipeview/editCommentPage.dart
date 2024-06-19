import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'dart:convert';

class EditCommentPage extends StatefulWidget {
  final int commentId;
  final String currentContent;

  EditCommentPage({required this.commentId, required this.currentContent});

  @override
  _EditCommentPageState createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.currentContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수정'),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '수정하세요...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              maxLength: 20,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Implement logic to update comment via API
                _updateComment(widget.commentId, _contentController.text);
              },
              child: Text('수정하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20), // 버튼의 세로(padding) 길이를 조정합니다.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 버튼의 모서리를 조정하여 네모로 만듭니다.
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey, width: 1),
                minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기를 조정합니다. double.infinity로 설정하면 가로폭을 꽉 채우도록 만듭니다.
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _updateComment(int commentId, String newContent) async {
    try {
      String apiUrl = '${Constants.baseUrl}/comments/update';
      var uri = Uri.parse('$apiUrl?id=$commentId&content=$newContent'); // Include commentId and content as query parameters

      if (newContent == widget.currentContent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('내용을 변경하여야 합니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (newContent.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('내용을 적어주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      var response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('수정하였습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); // Navigate back to previous screen after update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update comment'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating comment: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
