import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:flutter_splim/mobile/login/signout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/dto/UserDTO.dart';

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
  final List<String> _comments = [];
  late UserDTO? user;
  int? currentId;

  void initState() {
    super.initState();
    _review = widget.recipe.comment!;
    user = Provider.of<UserProvider>(context, listen: false).user;
    if(user != null)
      currentId = user!.id;
    print(currentId);
  }

  Future<String> checkRecipeExist() async {
    // 사용자 ID와 레시피 ID 설정
    int? userId = currentId;
    int recipeId = widget.recipe.id;
    // API 엔드포인트 설정
    String apiUrl = '${Constants.baseUrl}/add/exist?userId=$userId&recipeId=$recipeId';
    // GET 요청 보내기
    var response = await http.get(Uri.parse(apiUrl));
    // 서버로부터의 응답 확인
    if (response.statusCode == 200) {
      // 서버로부터의 응답을 문자열로 반환
      return response.body;
    } else {
      // 오류가 발생한 경우 빈 문자열 반환
      return '';
    }
  }

  Future<String> addSave() async {
    try {
      // 사용자 ID와 레시피 ID 설정
      int? userId = currentId;
      int recipeId = widget.recipe.id;
      // API 엔드포인트 설정
      String apiUrl = '${Constants.baseUrl}/add/save?userId=$userId&recipeId=$recipeId';
      // POST 요청 보내기
      var response = await http.post(Uri.parse(apiUrl));
      // 서버로부터의 응답 확인
      if (response.statusCode == 200) {
        // 서버로부터의 응답을 문자열로 반환
        return response.body;
      } else {
        // 실패한 경우 빈 문자열 반환
        return '';
      }
    } catch (e) {
      // 오류 발생 시 빈 문자열 반환
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title, style: TextStyle(fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
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
                if(widget.recipe.userDTO.id == currentId){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('본인 레시피는 추가할 수 없습니다.'),
                      duration: Duration(seconds: 2), // Snackbar 표시 시간 설정
                    ),
                  );
                }else{
                  String result = await checkRecipeExist();
                  // 이미 추가된 경우
                  if (result == "No") {
                    // Snackbar를 통해 이미 추가되었다는 메시지를 표시
                    String message = await addSave();
                    if(message == "success")
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('추가되었습니다.'),
                          duration: Duration(seconds: 2), // Snackbar 표시 시간 설정
                        ),
                      );
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이미 추가되었습니다.'),
                        duration: Duration(seconds: 2), // Snackbar 표시 시간 설정
                      ),
                    );
                  }
                }
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
                radius: 50,
                backgroundColor: Colors.blue[200],
                backgroundImage:
                    widget.recipe.userDTO.profile != null &&
                        widget.recipe.userDTO.profile!.isNotEmpty
                    ? NetworkImage(
                    "${Constants.baseUrl}/api/auth/images/${widget.recipe.userDTO.profile}")
                    : null, // 빈 값을 사용하여 배경 이미지가 없음을 나타냄
                child:
                    widget.recipe.userDTO.profile != null &&
                    widget.recipe.userDTO.profile!.isNotEmpty
                    ? null // 프로필 이미지가 있는 경우에는 아이콘을 표시하지 않음
                    : Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                ), // 프로필 이미지가 없는 경우에 아이콘을 표시
              ),

              SizedBox(width: 15,),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("닉네임: " + widget.recipe.userDTO.nickname, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  SizedBox(height: 8),
                  Text(
                    "후기: " + _review, // 사용자의 후기를 텍스트로 표시
                    style: TextStyle(fontSize: 16, ),
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
      child: GestureDetector(
        // 이미지 선택 기능 추가
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
