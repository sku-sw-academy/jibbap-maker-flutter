import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_splim/mobile/mypage/recipe/share.dart';

class ModifyPage extends StatefulWidget {

  @override
  _ModifyPageState createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  String _review = '';
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
          SizedBox(height: 15,),
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
              decoration: InputDecoration(
                hintText: '후기를 작성해주세요...',
                border: OutlineInputBorder(),
              ),
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
              onPressed: () {
                if (_image != null && _review.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('공유되었습니다.'),
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SharePage()),
                  );
                } else {
                  // 이미지 또는 후기가 없을 때 토스트 출력
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이미지와 후기를 모두 작성하세요.'),
                    ),
                  );
                }
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
      child: GestureDetector(// 이미지 선택 기능 추가
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
                    : null,
              ),
              child: _croppedFile == null
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
          title: Text('레시피 사진'),
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
