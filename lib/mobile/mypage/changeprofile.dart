import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChangeProfilePage extends StatefulWidget {
@override
_ChangeProfilePageState createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage>{
  XFile? _image;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource imageSource) async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile != null){
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필 수정"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30, width: double.infinity),
          _buildPhotoArea(),
          SizedBox(height: 20),
          _buildButton(),
          SizedBox(height: 20,),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {

    return _image != null
        ? CircleAvatar(
         radius: 70,
          backgroundImage: FileImage(File(_image!.path),),
        )
        : CircleAvatar(
            radius: 70,
            child: Icon(Icons.person),
        );
    }

  Widget _buildButton() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
            ),
          ),
          child: Icon(Icons.photo_camera),
        ),

        SizedBox(width: screenWidth / 30),

        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
            ),
          ),
          child: Icon(Icons.photo),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '닉네임을 입력하시오.',
              ),
            ),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              // 저장 버튼을 눌렀을 때의 처리
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text('저장'),
          ),
        ],
      ),
    );
  }


}