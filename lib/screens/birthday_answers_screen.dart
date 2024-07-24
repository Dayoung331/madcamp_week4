import 'package:flutter/material.dart';

class BirthdayAnswersScreen extends StatelessWidget {
  final Map<String, String> birthdayAnswers;

  BirthdayAnswersScreen({required this.birthdayAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '생일 답변들',
          style: TextStyle(fontSize: 20, fontFamily: 'NotoSerifKR', color: Colors.black),
        ),
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
      body: ListView.builder(
        itemCount: birthdayAnswers.length,
        itemBuilder: (context, index) {
          String year = birthdayAnswers.keys.elementAt(index);
          String answer = birthdayAnswers.values.elementAt(index);
          return ListTile(
            title: Text(
              '$year년의 답변',
              style: TextStyle(fontFamily: 'NotoSerifKR', fontSize: 16, color: Colors.black),
            ),
            subtitle: Text(
              answer,
              style: TextStyle(fontFamily: 'NotoSerifKR', fontSize: 14, color: Colors.black87),
            ),
            trailing: Icon(Icons.cake, color: Colors.pink),
          );
        },
      ),
    );
  }
}

