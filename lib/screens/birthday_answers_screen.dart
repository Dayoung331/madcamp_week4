import 'package:flutter/material.dart';

class BirthdayAnswersScreen extends StatelessWidget {
  final Map<String, String> birthdayAnswers;

  BirthdayAnswersScreen({required this.birthdayAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('생일 답변들'),
      ),
      body: ListView.builder(
        itemCount: birthdayAnswers.length,
        itemBuilder: (context, index) {
          String year = birthdayAnswers.keys.elementAt(index);
          String answer = birthdayAnswers.values.elementAt(index);
          return ListTile(
            title: Text('$year년의 답변'),
            subtitle: Text(answer),
            trailing: Icon(Icons.cake, color: Colors.pink),
          );
        },
      ),
    );
  }
}
