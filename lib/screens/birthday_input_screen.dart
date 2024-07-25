import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'birthday_screen.dart';

class BirthdayInputScreen extends StatefulWidget {
  final VoidCallback onBirthdayEntered;

  BirthdayInputScreen({required this.onBirthdayEntered});

  @override
  _BirthdayInputScreenState createState() => _BirthdayInputScreenState();
}

class _BirthdayInputScreenState extends State<BirthdayInputScreen> {
  DateTime _selectedDate = DateTime(2000, 1, 1); // 초기값 설정
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy. MM. dd').format(_selectedDate);
  }

  Future<void> _saveBirthday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('birthday', DateFormat('yyyy-MM-dd').format(_selectedDate));
    widget.onBirthdayEntered();
    _checkIfTodayIsBirthday();
  }

  void _checkIfTodayIsBirthday() {
    DateTime today = DateTime.now();
    if (_selectedDate.month == today.month && _selectedDate.day == today.day) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BirthdayScreen(onBirthdayMessageSubmitted: widget.onBirthdayEntered)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjusts the size based on content
            children: <Widget>[
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumYear: 1900,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      _dateController.text = DateFormat('yyyy. MM. dd').format(_selectedDate);
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/cake.png', // 케이크 이미지 경로
              height: 250,
            ),
            SizedBox(height: 20),
            Text(
              '당신의 생일은 언제인가요?',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'AppleMyungjo',
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: '생일',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveBirthday,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF252525),
                padding: EdgeInsets.symmetric(horizontal: 167, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '다음',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'AppleMyungjo',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
