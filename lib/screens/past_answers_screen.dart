import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PastAnswersScreen extends StatefulWidget {
  final String dateKey;
  final Map<String, String> answers;
  final String question; // 해당 날짜의 질문

  PastAnswersScreen({required this.dateKey, required this.answers, required this.question});

  @override
  _PastAnswersScreenState createState() => _PastAnswersScreenState();
}

class _PastAnswersScreenState extends State<PastAnswersScreen> {
  Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    answers = Map<String, String>.from(widget.answers);
  }

  Future<void> _deleteAnswer(BuildContext context, String year) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? answersString = prefs.getString('answers');
    if (answersString != null) {
      Map<String, dynamic> decodedAnswers = json.decode(answersString);
      if (decodedAnswers.containsKey(widget.dateKey)) {
        Map<String, String> dateAnswers = Map<String, String>.from(decodedAnswers[widget.dateKey]);
        dateAnswers.remove(year);
        if (dateAnswers.isEmpty) {
          decodedAnswers.remove(widget.dateKey);
        } else {
          decodedAnswers[widget.dateKey] = dateAnswers;
        }
        await prefs.setString('answers', json.encode(decodedAnswers));

        // 업데이트된 상태를 저장
        Map<String, dynamic> submittedStatus = json.decode(prefs.getString('submittedStatus') ?? '{}');
        if (dateAnswers.isEmpty) {
          submittedStatus.remove(widget.dateKey);
        }
        await prefs.setString('submittedStatus', json.encode(submittedStatus));
      }
    }

    // 현재 화면을 다시 그리도록 업데이트
    Navigator.of(context).pop(true);
  }

  void _showBottomSheet(BuildContext context, String year, String answer) {
    TextEditingController contentController = TextEditingController(text: answer);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('답변 수정하기'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditBottomSheet(context, year, contentController);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('답변 삭제하기'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog(context, year);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBottomSheet(BuildContext context, String year, TextEditingController contentController) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('답변 수정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'NotoSerifKR')),
              SizedBox(height: 20),
              Text(
                '"${widget.question}"', // 해당 날짜의 질문을 표시
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'NotoSerifKR',
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black, // 검은색 테두리
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      hintText: '내용을 입력하세요',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'NotoSerifKR',
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'NotoSerifKR',
                      color: Colors.black87,
                    ),
                    maxLines: 5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String newContent = contentController.text;

                  // 글 수정 로직 추가
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? answersString = prefs.getString('answers');
                  if (answersString != null) {
                    Map<String, dynamic> decodedAnswers = json.decode(answersString);
                    if (decodedAnswers.containsKey(widget.dateKey)) {
                      Map<String, String> dateAnswers = Map<String, String>.from(decodedAnswers[widget.dateKey]);
                      dateAnswers[year] = newContent;
                      decodedAnswers[widget.dateKey] = dateAnswers;
                      await prefs.setString('answers', json.encode(decodedAnswers));
                    }
                  }

                  // 스낵바 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('저장되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // 저장 후 화면 갱신을 위해 true 반환
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  '저장 완료',
                  style: TextStyle(
                    fontFamily: 'NotoSerifKR',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF252525),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          _loadUpdatedAnswers(); // 수정된 답변을 로드하여 화면 갱신
        });
      }
    });
  }

  Future<void> _loadUpdatedAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? answersString = prefs.getString('answers');
    if (answersString != null) {
      Map<String, dynamic> decodedAnswers = json.decode(answersString);
      if (decodedAnswers.containsKey(widget.dateKey)) {
        setState(() {
          answers = Map<String, String>.from(decodedAnswers[widget.dateKey]);
        });
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String year) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white, // 배경색을 흰색으로 설정
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white, // 배경색을 흰색으로 설정
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.black,
                  size: 40,
                ),
                SizedBox(height: 20),
                Text(
                  '답변을 삭제하시겠습니까?',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSerifKR',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'NotoSerifKR',
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(width: 10), // 버튼 간격 조정
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '삭제',
                        style: TextStyle(
                          fontFamily: 'NotoSerifKR',
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteAnswer(context, year);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('과거의 나 돌아보기', style: TextStyle(fontSize: 20, fontFamily: 'NotoSerifKR')),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          padding: const EdgeInsets.only(left: 35.0),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        toolbarHeight: 120,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 16.0),
        child: ListView.builder(
          itemCount: answers.length,
          itemBuilder: (context, index) {
            String year = answers.keys.elementAt(index);
            String answer = answers[year]!;
            return GestureDetector(
              onLongPress: () {
                _showBottomSheet(context, year, answer);
              },
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '$year년의 나',
                      style: TextStyle(
                        fontFamily: 'NotoSerifKR',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    padding: EdgeInsets.all(16.0),
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minWidth: 300,
                      minHeight: 100,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Text(
                          answer,
                          style: TextStyle(
                            fontFamily: 'NotoSerifKR',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
