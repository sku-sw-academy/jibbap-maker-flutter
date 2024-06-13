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
import 'package:flutter_splim/mobile/recipeview/editCommentPage.dart';

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
                _comments.isNotEmpty ? "댓글: ${_comments.length}" : "댓글이 없습니다",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle:
              _comments.isNotEmpty ? Row(children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue[200],
                  backgroundImage: _comments.first.userDTO != null &&
                      _comments.first.userDTO.profile != null &&
                      _comments.first.userDTO.profile!.isNotEmpty
                      ? NetworkImage(
                      "${Constants.baseUrl}/api/auth/images/${_comments.first.userDTO.profile}")
                      : null, // 빈 값을 사용하여 배경 이미지가 없음을 나타냄
                  child: _comments.first.userDTO != null &&
                      _comments.first.userDTO.profile != null &&
                      _comments.first.userDTO.profile!.isNotEmpty
                      ? null // 프로필 이미지가 있는 경우에는 아이콘을 표시하지 않음
                      : Icon(Icons.person, size: 15, color: Colors.grey,), // 프로필 이미지가 없는 경우에 아이콘을 표시
                ),
                SizedBox(width: 10,),
                Text(_comments.first.content)
              ],
              ) : Text(""),

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

  String formatRelativeTime(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
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
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(
                  '댓글',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    bool isCurrentUserComment = comment.userDTO.id == currentId;
                    bool isRecipeOwner = widget.recipe.userDTO.id == currentId;

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.blue[200],
                        backgroundImage: comment.userDTO != null &&
                            comment.userDTO.profile != null &&
                            comment.userDTO.profile!.isNotEmpty
                            ? NetworkImage(
                            "${Constants.baseUrl}/api/auth/images/${comment.userDTO.profile}")
                            : null, // 빈 값을 사용하여 배경 이미지가 없음을 나타냄
                        child: comment.userDTO != null &&
                            comment.userDTO.profile != null &&
                            comment.userDTO.profile!.isNotEmpty
                            ? null // 프로필 이미지가 있는 경우에는 아이콘을 표시하지 않음
                            : Icon(Icons.person, size: 15, color: Colors.grey,), // 프로필 이미지가 없는 경우에 아이콘을 표시
                      ),
                      title: Row(
                        children: [
                          if(widget.recipe.userDTO.id != comment.userDTO.id)
                            Text(comment.userDTO.nickname, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),

                          if(widget.recipe.userDTO.id == comment.userDTO.id)
                            Container(
                              width : comment.userDTO.nickname.length * 15,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child:
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(comment.userDTO.nickname,
                                      style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,),
                                    Icon(Icons.check_circle, size: 12, color: Colors.green),
                                  ]
                              ),
                            ),
                          Text("·", style: TextStyle(fontSize: 30, color: Colors.grey),),
                          Text(formatRelativeTime(comment.modifyDate), style: TextStyle(fontSize: 13, color: Colors.grey)),

                          if (comment.updateFlag.toString() == "true")
                            Text("(수정됨)", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      subtitle: Text(comment.content),
                      tileColor: Colors.white,
                      trailing: isRecipeOwner && isCurrentUserComment
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextButton(onPressed:(){
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (context) => EditCommentPage(
                                commentId: comment.id,
                                currentContent: comment.content,
                              ),
                            ),
                            ).then((value) {
                            // Handle callback or update logic if needed
                              _fetchComments();
                            });
                            },
                              child: Text("수정", style: TextStyle(color: Colors.green, ),)
                          ),

                          TextButton(onPressed:(){
                            _deleteComment(comment.id);
                            setState(() {
                            _fetchComments();
                            Navigator.pop(context);
                          });
                          },
                              child: Text("삭제", style: TextStyle(color: Colors.red),)
                          ),

                        ],
                      )
                          : isRecipeOwner
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(onPressed:(){
                            _deleteComment(comment.id);
                            setState(() {
                              _fetchComments();
                              Navigator.pop(context);
                            });
                          },
                              child: Text("삭제", style: TextStyle(color: Colors.red),)
                          ),
                        ],
                      )
                          : isCurrentUserComment
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(onPressed:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCommentPage(
                                  commentId: comment.id,
                                  currentContent: comment.content,
                                ),
                              ),
                            ).then((value) {
                              // Handle callback or update logic if needed
                              _fetchComments();
                            });
                          },
                              child: Text("수정", style: TextStyle(color: Colors.green),)
                          ),

                          TextButton(onPressed:(){
                            _deleteComment(comment.id);
                            setState(() {
                              _fetchComments();
                              Navigator.pop(context);
                            });
                          },
                              child: Text("삭제", style: TextStyle(color: Colors.red),)
                          ),
                        ],
                      )
                          : null,
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
                              Navigator.pop(context);
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

  void _deleteComment(int commentId) async {
    try {
      var response = await http.delete(
        Uri.parse('${Constants.baseUrl}/comments/delete?id=$commentId'),
      );
      if (response.statusCode == 200) {
        // 댓글 삭제 성공 시
        _fetchComments(); // 댓글 리스트 다시 불러오기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글이 삭제되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // 댓글 삭제 실패 시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글 삭제에 실패했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 오류 발생 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}

class CommentDTO {
  final int id;
  final String content;
  bool updateFlag;
  UserDTO userDTO;
  RecipeDTO recipeDTO;
  final DateTime modifyDate;

  CommentDTO({required this.id, required this.content, required this.updateFlag, required this.userDTO, required this.recipeDTO, required this.modifyDate,});

  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'],
      content: json['content'],
      userDTO: UserDTO.fromJson(json['userDTO']),
      recipeDTO: RecipeDTO.fromJson(json['recipeDTO']),
      updateFlag: json['updateFlag'],
      modifyDate: DateTime.parse(json['modifyDate']),
    );
  }
}
