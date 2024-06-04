import 'package:flutter/material.dart';

class AIRecipePage extends StatefulWidget{

  @override
  _AIRecipePageState createState() => _AIRecipePageState();
}

class _AIRecipePageState extends State<AIRecipePage>{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("레시피"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Divider(),



          Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 첫 번째 버튼 클릭 시 실행할 동작
                },
                child: Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                  ),
                  side: BorderSide(color: Colors.black, width: 1),
                    minimumSize: Size(50, 50)
                  // 다른 스타일 속성들...
                ),
              ),

              SizedBox(width: 40,),

              ElevatedButton(
                onPressed: () {
                  // 두 번째 버튼 클릭 시 실행할 동작
                },
                child: Icon(Icons.refresh),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 네모 모양을 만들기 위해 모서리 반경을 0으로 설정
                  ),
                  side: BorderSide(color: Colors.black, width: 1),
                    minimumSize: Size(50, 50)
                  // 다른 스타일 속성들...
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}