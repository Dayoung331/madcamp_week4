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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('과거의 나 돌아보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: answers.length,
          itemBuilder: (context, index) {
            String year = answers.keys.elementAt(index);
            String answer = answers[year]!;
            return ListTile(
              title: Text('$year년의 답변'),
              subtitle: Text(answer),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _deleteAnswer(context, year);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
