import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/mobile/mypage/customerCenter/question.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/detailpage.dart';

class InquiryPage extends StatefulWidget {
  @override
  _InquiryPageState createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  List<Map<String, dynamic>> inquiries = []; // FAQ 목록을 저장하는 리스트
  bool isLoading = true; // 로딩 상태를 저장하는 변수
  late UserDTO? user;
  final SecureService _secureService = SecureService();
  bool isEditing = false; // 편집 모드 여부를 저장하는 변수
  List<Map<String, dynamic>> selectedItems = []; // 선택된 항목들을 저장하는 리스트

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    _fetchInquiries();
  }

  Future<void> _fetchInquiries() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/question/all/${user?.id}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> inquiryList = json.decode(responseBody);
        setState(() {
          inquiries = inquiryList.map((inquiry) => inquiry as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load quesitons');
      }
    } catch (e) {
      print('Error fetching quesitons: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("문의내역을 불러오는데 실패했습니다."),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // 편집 모드 토글
  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      // 편집 모드가 비활성화되면 선택된 항목들 초기화
      if (!isEditing) selectedItems.clear();
    });
  }

  void _deleteSelectedInquiries() async {
    try {
      // 선택된 항목들의 ID 추출
      List<int> selectedIds = selectedItems.map<int>((item) => item['id'] as int).toList();

      // 서버에 삭제 요청 보내기
      for (int id in selectedIds) {
        final url = Uri.parse('${Constants.baseUrl}/question/$id');
        final response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          // 삭제에 성공하면 해당 항목을 inquiries 리스트에서도 삭제
          setState(() {
            inquiries.removeWhere((item) => item['id'] == id);
          });
          SnackBar(
            content: Text("삭제되었습니다."),
          );
        } else {
          throw Exception('Failed to delete inquiry with id: $id');
        }
      }

      setState(() {
        selectedItems.clear();
      });
    } catch (e) {
      print('Error deleting inquiries: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("선택된 항목 삭제에 실패했습니다."),
        ),
      );
    }
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 바깥을 눌러도 다이얼로그가 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('삭제하면 다시는 볼 수 없습니다.'),
                Text('정말 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _deleteSelectedInquiries(); // 선택된 항목 삭제 함수 호출
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 편집 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: _toggleEditing,
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.black, // 버튼의 텍스트 색상 설정
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // 버튼의 모서리를 둥글게 설정
                  ),
                ),
              ),
              child: Text(isEditing ? '완료' : '편집'),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : inquiries.isEmpty
              ? Center(child: Text('문의내역이 없습니다.'))
              : Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                  itemCount: inquiries.length,
                  itemBuilder: (context, index) {
                  var inquiry = inquiries[index];
                  return ListTile(
                  title: Text(inquiry['title']),
                  subtitle: Text(
                    inquiry['modifyDate']
                        .toString()
                        .substring(5, 10)
                        .replaceAll("-", "월") +
                        "일" ??
                        '',
                  ),
                  // 편집 모드일 때만 선택 가능하도록 함
                    onTap: !isEditing ? () {
                      // 편집 모드가 아닐 때 detailpage로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailPage(inquiry: inquiry)),
                      );
                    } : null,
                    // 편집 모드일 때 체크박스 표시
                    leading: isEditing
                        ? Checkbox(
                      value: selectedItems.contains(inquiry),
                      onChanged: (value) {
                        setState(() {
                          if (value != null && value) {
                            selectedItems.add(inquiry);
                          } else {
                            selectedItems.remove(inquiry);
                          }
                        });
                      },
                    )
                        : null,
                    trailing: Text(
                      inquiry["status"] ? '완료' : '대기중',
                      style: TextStyle(
                        color: inquiry["status"] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
              },
            ),
                ),
          ),
        ],
      ),
      floatingActionButton: isEditing
          ? FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        onPressed: _showDeleteDialog,
            child: Icon(Icons.delete),
          tooltip: '선택된 항목 삭제',
      )
          : FloatingActionButton(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuestionPage()),
          ).then((_) {
            // FAQ 작성 폼에서 돌아온 후 FAQ 목록을 다시 불러오기
            _fetchInquiries();
          });
        },
        child: Icon(Icons.question_answer),
        tooltip: '문의하기',
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat, // 버튼 위치를 화면의 오른쪽 하단으로 설정
    );
  }

}
