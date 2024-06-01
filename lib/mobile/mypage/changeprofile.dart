import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/dto/UserDTO.dart';

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

  @override
  void initState() {
    super.initState();
    // 사용자 정보에서 닉네임 설정
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    UserDTO? user = Provider.of<UserProvider>(context).user;
    _nickNameController.text = user?.nickname ?? '';

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
    UserDTO? user = Provider.of<UserProvider>(context).user;

    return GestureDetector(
      onTap: () {
        showSheet(context);
      },
      child: Stack(
        children: [
          _image != null
              ? CircleAvatar(
              radius: 70,
              backgroundImage: FileImage(File(_croppedFile!.path)),
          )
              : user?.profile != ""
              ? CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(user!.profile),
          )
              : CircleAvatar(
                radius: 70,
                backgroundColor: Colors.blue[200],
                child: Icon(Icons.person, color: Colors.grey, size: 70),
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
                labelText: '닉네임을 입력하시오.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '닉네임을 입력해주세요';
                } else if (_nickNameController.text.length > 10) {
                  return '10자 이하로 해주세요.';
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // 비밀번호 변경 로직 추가
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('닉네임 변경'),
                    content: Text('닉네임이 성공적으로 변경되었습니다.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 다이얼로그 닫기
                          Navigator.pop(context); // 이전 화면으로 돌아가기
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
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
          // 배경색상을 변경
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 경계선을 둥글게 만듦
            // 경계선 색상 및 두께 설정
          ),
          elevation: 5.0,
          title: Text('프로필 사진 변경'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.camera); // 카메라 열기
                Navigator.pop(context); // BottomSheet 닫기
              },
              child: ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 찍기'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                getImage(ImageSource.gallery); // 갤러리에서 이미지 선택
                Navigator.pop(context); // BottomSheet 닫기
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


// Widget _buildButton() {
//   double screenWidth = MediaQuery.of(context).size.width;
//
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       ElevatedButton(
//         onPressed: () {
//           getImage(ImageSource.camera); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
//         },
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.zero, // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
//           ),
//         ),
//         child: Icon(Icons.photo_camera),
//       ),
//
//       SizedBox(width: screenWidth / 30),
//
//       ElevatedButton(
//         onPressed: () {
//           getImage(ImageSource.gallery); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
//         },
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.zero, // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
//           ),
//         ),
//         child: Icon(Icons.photo),
//       ),
//     ],
//   );
// }