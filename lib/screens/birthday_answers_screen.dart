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
      body: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 16.0),
        child: ListView.builder(
          itemCount: birthdayAnswers.length,
          itemBuilder: (context, index) {
            String year = birthdayAnswers.keys.elementAt(index);
            String answer = birthdayAnswers.values.elementAt(index);
            return Column(
              children: [
                Center(
                  child: Text(
                    '$year년의 생일',
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
            );
          },
        ),
      ),
    );
  }
}
