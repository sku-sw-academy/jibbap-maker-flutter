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

  Future<void> cropImage() async{
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path, // 사용할 이미지 경로
        compressFormat: ImageCompressFormat.jpg, // 저장할 이미지 확장자(jpg/png)
        compressQuality: 100, // 저장할 이미지의 퀄리티
        uiSettings: [
          // 안드로이드 UI 설정
          AndroidUiSettings(
              toolbarTitle: '이미지 자르기/회전하기', // 타이틀바 제목
              toolbarColor: Colors.blue, // 타이틀바 배경색
              toolbarWidgetColor: Colors.white, // 타이틀바 단추색
              initAspectRatio:
              CropAspectRatioPreset.original, // 이미지 크로퍼 시작 시 원하는 가로 세로 비율
              lockAspectRatio: false), // 고정 값으로 자르기 (기본값 : 사용안함)
          // iOS UI 설정
          IOSUiSettings(
            title: '이미지 자르기/회전하기', // 보기 컨트롤러의 맨 위에 나타나는 제목
          ),
          // Web UI 설정
          WebUiSettings(
            context: context, // 현재 빌드 컨텍스트
            presentStyle: CropperPresentStyle.dialog, // 대화 상자 스타일
            boundary: // 크로퍼의 외부 컨테이너 (기본값 : 폭 500, 높이 500)
            const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: // 이미지가 보이는 부분 (기본값 : 폭 400, 높이 400, 유형 사각형)
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true, // 디지털 카메라 이미지 파일 확장자 사용
            enableZoom: true, // 확대/축소 기능 활성화 (기본값 : false)
            showZoomer: true, // 확대/축소 슬라이더 표시/숨김 (기본값 : true)
          ),
        ],
      );

      if (croppedFile != null) {
        // 자르거나 회전한 이미지를 앱에 출력하기 위해 앱의 상태 변경
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("레시피"),
        centerTitle: true,
        backgroundColor: Colors.limeAccent,
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
              maxLines: 5,
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
