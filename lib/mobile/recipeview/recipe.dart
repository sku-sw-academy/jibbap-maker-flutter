import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'dart:convert';

class RecipePage extends StatefulWidget {
  final RecipeDTO recipe;

  RecipePage({required this.recipe});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  String _review = '후기';
  String key = "accessToken";
  final ImagePicker picker = ImagePicker();
  late UserDTO? user;
  int currentId = 0;
  List<CommentDTO> _comments = []; // 댓글을 저장할 리스트

  @override
  void initState() {
    super.initState();
    _review = widget.recipe.comment!;
    user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) currentId = user!.id;
    _fetchComments(); // 페이지가 초기화될 때 댓글을 불러옴
  }

  Future<void> _fetchComments() async {
    String apiUrl = '${Constants.baseUrl}/comments/${widget.recipe.id}';
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var responsebody = utf8.decode(response.bodyBytes);
      List<dynamic> commentJson = jsonDecode(responsebody);
      setState(() {
        _comments = commentJson.map((json) => CommentDTO.fromJson(json)).toList();
      });
    } else {
      // 오류 처리
    }
  }

  Future<String> checkRecipeExist() async {
    int? userId = currentId;
    int recipeId = widget.recipe.id;
    String apiUrl = '${Constants.baseUrl}/add/exist?userId=$userId&recipeId=$recipeId';
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '';
    }
  }

  Future<String> addSave() async {
    try {
      int? userId = currentId;
      int recipeId = widget.recipe.id;
      String apiUrl = '${Constants.baseUrl}/add/save?userId=$userId&recipeId=$recipeId';
      var response = await http.post(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title, style: TextStyle(fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
        actions: [
          if (widget.recipe.userDTO.id != currentId)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final storageService = Provider.of<SecureService>(context, listen: false);
                String? token = await storageService.readToken(key);
                if (token == null || token.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
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
                  if (widget.recipe.userDTO.id == currentId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('본인 레시피는 추가할 수 없습니다.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    String result = await checkRecipeExist();
                    if (result == "No") {
                      String message = await addSave();
                      if (message == "success")
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('성공'),
                            content: Text('저장되었습니다.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('확인'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('이미 추가되었습니다.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          _buildPhotoArea(),
          Divider(),
          Row(
            children: [
              SizedBox(width: 10),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[200],
                backgroundImage: widget.recipe.userDTO.profile != null &&
                    widget.recipe.userDTO.profile!.isNotEmpty
                    ? NetworkImage(
                    "${Constants.baseUrl}/api/auth/images/${widget.recipe.userDTO.profile}")
                    : null,
                child: widget.recipe.userDTO.profile != null &&
                    widget.recipe.userDTO.profile!.isNotEmpty
                    ? null
                    : Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "닉네임: " + widget.recipe.userDTO.nickname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "후기: " + _review,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.recipe.content,
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
                _comments.isNotEmpty ? _comments.first.content : "댓글이 없습니다",
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
      child: GestureDetector(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.blue[200],
            image: widget.recipe.image!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage('${Constants.baseUrl}/recipe/images/${widget.recipe.image}'),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: widget.recipe.image!.isEmpty
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
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    bool isCurrentUserComment = comment.userDTO.id == currentId; // 현재 사용자의 댓글인지 여부 확인

                    return ListTile(
                      title: Text(comment.content),
                      tileColor: Colors.white,
                      trailing: isCurrentUserComment
                          ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {

                        },
                      )
                          : null, // 다른 사용자의 댓글이면 삭제 버튼을 보여주지 않음
                    );
                  },
                ),

              ),
              Divider(),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Row(
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
                            builder: (context) => AlertDialog(
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
                            // 서버로 댓글 추가 요청
                            var response = await http.post(
                              Uri.parse('${Constants.baseUrl}/comments/send'),
                              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                              body: {
                                'userId': currentId.toString(),
                                'recipeId': widget.recipe.id.toString(),
                                'content': _commentController.text,
                              },
                            );
                            if (response.statusCode == 200) {
                              _fetchComments(); // 댓글 리스트 다시 불러오기
                              _commentController.clear(); // 입력 필드 비우기
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('댓글 추가에 실패했습니다.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class CommentDTO {
  final int id;
  final String content;
  bool updateFlag;
  UserDTO userDTO;
  RecipeDTO recipeDTO;

  CommentDTO({required this.id, required this.content, required this.updateFlag, required this.userDTO, required this.recipeDTO});

  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'],
      content: json['content'],
      userDTO: UserDTO.fromJson(json['userDTO']),
      recipeDTO: RecipeDTO.fromJson(json['recipeDTO']),
      updateFlag: json['updateFlag'],
    );
  }
}
