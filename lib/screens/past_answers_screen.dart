import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PastAnswersScreen extends StatelessWidget {
  final String dateKey;
  final Map<String, String> answers;

  PastAnswersScreen({required this.dateKey, required this.answers});

  Future<void> _deleteAnswer(BuildContext context, String year) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? answersString = prefs.getString('answers');
    if (answersString != null) {
      Map<String, dynamic> decodedAnswers = json.decode(answersString);
      if (decodedAnswers.containsKey(dateKey)) {
        Map<String, String> dateAnswers = Map<String, String>.from(decodedAnswers[dateKey]);
        dateAnswers.remove(year);
        if (dateAnswers.isEmpty) {
          decodedAnswers.remove(dateKey);
        } else {
          decodedAnswers[dateKey] = dateAnswers;
        }
        await prefs.setString('answers', json.encode(decodedAnswers));

        // 업데이트된 상태를 저장
        Map<String, dynamic> submittedStatus = json.decode(prefs.getString('submittedStatus') ?? '{}');
        if (dateAnswers.isEmpty) {
          submittedStatus.remove(dateKey);
        }
        await prefs.setString('submittedStatus', json.encode(submittedStatus));
      }
    }

    // 현재 화면을 다시 그리도록 업데이트
    Navigator.of(context).pop(true);
  }

  void _showBottomSheet(BuildContext context, String year) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('글 수정하기'),
                onTap: () {
                  Navigator.of(context).pop();
                  // 글 수정 로직을 여기에 추가하세요.
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('글 삭제하기'),
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
        title: Text('과거의 나 돌아보기', style: TextStyle(fontSize: 20, fontFamily: 'AppleMyungjo')),
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
                _showBottomSheet(context, year);
              },
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '$year년의 나',
                      style: TextStyle(
                        fontFamily: 'AppleMyungjo',
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
                            fontFamily: 'AppleMyungjo',
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
