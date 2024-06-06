import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_splim/mobile/mypage/recipe/modify.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class SharePage extends StatefulWidget {

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  String _review = '후기';
  XFile? _image;
  CroppedFile? _croppedFile;
  final ImagePicker picker = ImagePicker();

  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("레시피", style: TextStyle(fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          _buildPhotoArea(),
          Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "내용",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 3,
              enabled: false,
              decoration: InputDecoration(
                hintText: _review,
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
            ),
            ),
          ),

          Center(
            child: ElevatedButton(
              onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyPage()),);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                ),
                side: BorderSide(color: Colors.black, width: 1),
                fixedSize: Size(100, 50),
                // 다른 스타일 속성들...
              ),
              child: Text("수정하기"),
            ),
          ),
          SizedBox(height: 20),

        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return Center(
      child: GestureDetector(// 이미지 선택 기능 추가
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

}
