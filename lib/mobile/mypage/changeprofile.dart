import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/service/userservice.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';

class ChangeProfilePage extends StatefulWidget {

  @override
  _ChangeProfilePageState createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage>{
  XFile? _image;
  CroppedFile? _croppedFile;
  final ImagePicker picker = ImagePicker();
  TextEditingController _nickNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SecureService _secureService = SecureService();
  late UserDTO? user;
  late UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    _nickNameController.text = user?.nickname ?? '';
  }

  Future<void> getImage(ImageSource imageSource) async{
    try{
      final XFile? pickedFile = await picker.pickImage(source: imageSource);
      if(pickedFile != null){
        _image = XFile(pickedFile.path);
        cropImage();
      }
    }catch(e){

    }
  }

  Future<void> cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기/회전하기',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
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
            boundary: CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: CroppieViewPort(
              width: 480,
              height: 480,
              type: 'circle',
            ),
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
        uploadImage(user!.id, _croppedFile!);
      }
    }
  }

  Future uploadImage(int userId, CroppedFile imageFile) async {
    var url = Uri.parse('${Constants.baseUrl}/api/auth/upload');
    var request = http.MultipartRequest('POST', url);
    request.fields['userId'] = userId.toString(); // 사용자 ID 추가
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      String image = await response.stream.bytesToString();
      print('Image: $image');
      setState(() {
        user!.profile = image; // 서버에서 받은 이미지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 이미지가 변경되었습니다.')),
        );
      });
    } else {
      print('Failed to upload image');
    }
  }

  Future<void> resetProfileImage(int userId) async {
    var url = Uri.parse('${Constants.baseUrl}/api/auth/reset-profile');
    var response = await http.post(url, body: {'userId': userId.toString()});
    if (response.statusCode == 200 && response.body == "Ok") {
      print('Profile reset successfully');
      setState(() {
        user!.profile = null; // 프로필 이미지 URL을 빈 값으로 설정
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지가 기본 이미지로 변경되었습니다.')),
      );
    } else {
      print('Failed to reset profile image');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 이미지 변경 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("프로필 수정"),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30, width: double.infinity),
          _buildPhotoArea(),
          SizedBox(height: 20),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return GestureDetector(
      onTap: () {
        showSheet(context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue[200],
            backgroundImage: user != null && user!.profile != null && user!.profile!.isNotEmpty
                ? NetworkImage("${Constants.baseUrl}/api/auth/images/${user!.profile!}")
                : null, // 빈 값을 사용하여 배경 이미지가 없음을 나타냄
            child: user != null && user!.profile != null && user!.profile!.isNotEmpty
                ? null // 프로필 이미지가 있는 경우에는 아이콘을 표시하지 않음
                : Icon(Icons.person, size: 80, color: Colors.grey,), // 프로필 이미지가 없는 경우에 아이콘을 표시
          ),
          Positioned(
            right: 5,
            bottom: 9,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 그림자 색상
                    spreadRadius: 2, // 그림자의 확산 범위
                    blurRadius: 5, // 그림자의 흐림 정도
                    offset: Offset(0, 3), // 그림자의 위치 조절
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
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),

      child: Form(
          key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
              controller: _nickNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '닉네임',
              ),
                maxLength: 20,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '닉네임을 입력해주세요';
                } else if (_nickNameController.text.length > 20) {
                  return '20자 이하로 해주세요.';
                }
                return null;
              },
                onFieldSubmitted: (_) async {
                  if (_formKey.currentState!.validate() && _nickNameController.text != user!.nickname) {

                    String result = await userService.changeNickName(user!.id, _nickNameController.text);
                    if (result != "error") {
                      setState(() {
                        user!.nickname = result;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('닉네임 변경 성공')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('닉네임 변경 실패')),
                      );
                    }
                  }else if(_nickNameController.text == user!.nickname){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('닉네임이 같습니다.')),
                    );
                  }
                },
            ),
            SizedBox(height: 12),

            ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && _nickNameController.text != user!.nickname) {

                String result = await userService.changeNickName(user!.id, _nickNameController.text);
                if (result != "error") {
                  setState(() {
                    user!.nickname = result;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('닉네임 변경 성공')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('닉네임 변경 실패')),
                  );
                }
              }else if(_nickNameController.text == user!.nickname){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('닉네임이 같습니다.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: BorderSide(color: Colors.grey, width: 1),
              minimumSize: Size(double.infinity, 50),
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
              child: Text('저장'),
              ),
            ],
          ),
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
            borderRadius: BorderRadius.circular(10), // 경계선을 둥글게 만듦
          ),
          elevation: 5.0,
          title: Text('프로필 사진 변경'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.camera); // 카메라 열기
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 찍기'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.gallery); // 갤러리에서 이미지 선택
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: ListTile(
                leading: Icon(Icons.photo),
                title: Text('갤러리에서 선택'),
              ),
            ),
            if (user != null && user!.profile != null && user!.profile!.isNotEmpty)
              SimpleDialogOption(
                onPressed: () {
                  resetProfileImage(user!.id); // 기본 이미지로 변경
                  Navigator.pop(context); // 다이얼로그 닫기
                },
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('기본 이미지로 변경'),
                ),
              ),
          ],
        );
      },
    );
  }

}