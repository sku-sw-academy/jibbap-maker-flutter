import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatefulWidget {

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  String _review = '후기';
  String key = "accessToken";
  CroppedFile? _croppedFile;
  final ImagePicker picker = ImagePicker();
  final List<String> _comments = [];

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("레시피"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.add),
            onPressed: () async {
              final storageService = Provider.of<SecureService>(context, listen: false);
              String? token = await storageService.readToken(key);
              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: Text('로그인 필요'),
                        content: Text('로그인이 필요합니다. 로그인하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                );
                return;
              } else {

              }
            },
          )
        ],
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          _buildPhotoArea(),
          Divider(),

          Row(
            children: [
              SizedBox(width: 10,),

              CircleAvatar(
                backgroundColor: Colors.cyan,
                radius: 50,
                child: Icon(Icons.person, color: Colors.grey, size: 30,),
              ),

              SizedBox(width: 15,),

              Column(
                children: [
                  Text("닉네임"),

                  SizedBox(height: 8),
                  Text(
                    _review, // 사용자의 후기를 텍스트로 표시
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            ],
          ),

          Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "내용",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Divider(),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              onTap: () {
                _showCommentBottomSheet(context);
              },
              title: Text(
                _comments.isNotEmpty ? _comments.first : "댓글이 없습니다",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return Center(
      child: GestureDetector( // 이미지 선택 기능 추가
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.blue[200],
            image: _croppedFile != null
                ? DecorationImage(
              image: FileImage(File(_croppedFile!.path)),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: _croppedFile == null
              ? Icon(Icons.food_bank, color: Colors.grey, size: 70)
              : null,
        ),
      ),
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "댓글",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: _comments.map((comment) =>
                        ListTile(
                          title: Text(comment),
                          tileColor: Colors.white,
                        )).toList(),
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "댓글을 입력하세요",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final storageService = Provider.of<SecureService>(context, listen: false);
                        String? token = await storageService.readToken(key);
                        if (token == null || token.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: Text('로그인 필요'),
                                  content: Text('로그인이 필요합니다. 로그인하시겠습니까?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginPage()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          );
                          return;
                        } else {
                          if (_commentController.text.isNotEmpty) {
                            setState(() {
                              _comments.add(_commentController.text);
                            });
                            _commentController.clear();
                          }
                        }
                      },
                      child: Icon(Icons.arrow_back_ios_sharp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
