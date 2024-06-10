import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_splim/mobile/mypage/recipe/share.dart';
import 'package:flutter_splim/dto/RecipeDTO.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/constant.dart'; // Constants.baseUrl을 위한 import

class ModifyPage extends StatefulWidget {
  final RecipeDTO recipeDTO;

  ModifyPage({required this.recipeDTO});

  @override
  _ModifyPageState createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  String _review = "";
  late TextEditingController _textEditingController;
  XFile? _image;
  CroppedFile? _croppedFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.recipeDTO.comment ?? "");
  }

  Future<void> getImage(ImageSource imageSource) async {
    try {
      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
        cropImage();
      }
    } catch (e) {
      print(e); // 에러 처리
    }
  }

  Future<void> cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기/회전하기',
            toolbarColor: Colors.grey[100],
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '이미지 자르기/회전하기',
            aspectRatioLockEnabled: true,
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: CroppieBoundary(width: 520, height: 520),
            viewPort: CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<String> uploadImageAndComment(File imageFile, String comment, int recipeId) async {
    var uri = Uri.parse('${Constants.baseUrl}/recipe/upload'); // 서버 URL 수정 필요
    var request = http.MultipartRequest('POST', uri)
      ..fields['id'] = recipeId.toString()
      ..fields['comment'] = comment
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      String image = await response.stream.bytesToString();
      return image;
    } else {
      throw Exception('Failed to upload image and comment');
    }
  }

  Future<String> uploadComment(String comment, int recipeId) async {
    var uri = Uri.parse('${Constants.baseUrl}/recipe/review'); // 서버 URL 수정 필요
    var request = http.MultipartRequest('POST', uri)
      ..fields['id'] = recipeId.toString()
      ..fields['comment'] = comment;

    var response = await request.send();
    if (response.statusCode == 200) {
      String image = await response.stream.bytesToString();
      return image;
    } else {
      throw Exception('Failed to upload image and comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(widget.recipeDTO.title, style: TextStyle(fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          _buildPhotoArea(),
          SizedBox(height: 15),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.recipeDTO.content,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '후기를 작성해주세요...',
                border: OutlineInputBorder(),
              ),
              controller: _textEditingController,
              onChanged: (value) {
                setState(() {
                  _review = value;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if ((_croppedFile != null || (widget.recipeDTO.image != null && widget.recipeDTO.image!.isNotEmpty)) && _review.isNotEmpty) {
                  try {
                    if(_croppedFile != null){
                      String imageName = await uploadImageAndComment(
                        File(_croppedFile!.path),
                        _review,
                        widget.recipeDTO.id,
                      );
                      setState(() {
                        widget.recipeDTO.image = imageName;
                        widget.recipeDTO.comment = _review;
                      });
                    }else{
                      String ok = await uploadComment(_review, widget.recipeDTO.id);
                      if(ok == "ok"){
                        setState(() {
                          widget.recipeDTO.comment = _review;
                        });
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('공유되었습니다.')),
                    );
                    if(!widget.recipeDTO.status){
                      widget.recipeDTO.status = true;
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SharePage(recipeDTO: widget.recipeDTO)),
                      );
                    }else{
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SharePage(recipeDTO: widget.recipeDTO)),
                      );
                    }

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('업로드에 실패했습니다.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이미지와 후기를 모두 작성하세요.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.black, width: 1),
                fixedSize: Size(100, 50),
              ),
              child: Text("공유하기"),
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
        onTap: () {
          showSheet(context);
        },
        child: Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.cyan,
                image: _croppedFile != null
                    ? DecorationImage(
                  image: FileImage(File(_croppedFile!.path)),
                  fit: BoxFit.cover,
                )
                    : widget.recipeDTO.image != null && widget.recipeDTO.image!.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage('${Constants.baseUrl}/recipe/images/${widget.recipeDTO.image}'),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: (_croppedFile == null && (widget.recipeDTO.image == null || widget.recipeDTO.image!.isEmpty))
                  ? Icon(Icons.food_bank, color: Colors.grey, size: 70)
                  : null,
            ),
            Positioned(
              right: 5,
              bottom: 9,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5.0,
          title: Text('레시피 사진'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.camera);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 찍기'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(Icons.photo),
                title: Text('갤러리에서 선택'),
              ),
            ),
          ],
        );
      },
    );
  }
}
