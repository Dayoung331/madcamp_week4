import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BirthdayScreen extends StatefulWidget {
  final VoidCallback onBirthdayMessageSubmitted;

  BirthdayScreen({required this.onBirthdayMessageSubmitted});

  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  TextEditingController _textController = TextEditingController();
  bool _isTextFieldVisible = false;
  bool _isAnimationVisible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        _isAnimationVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveBirthdayMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final year = DateTime.now().year;
    await prefs.setString('birthday_message_$year', message);
    print('Birthday message saved for year $year: $message');
  }

  void _submitBirthdayMessage() {
    _saveBirthdayMessage(_textController.text);
    widget.onBirthdayMessageSubmitted(); // 생일 메시지 제출 후 콜백 호출
  }

  void _navigateToQuestionScreen() {
    widget.onBirthdayMessageSubmitted(); // 생일 메시지 작성하지 않고 넘어가는 경우도 콜백 호출
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 키보드를 숨깁니다.
        },
        child: Stack(
          children: [
            Center(
              child: _isAnimationVisible
                  ? Lottie.asset(
                'assets/present.json',
                width: 600,
                height: 400,
                fit: BoxFit.fill,
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '생일을 축하합니다!',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'NotoSerifKR',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '생일을 행복하게 보내고 계신가요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'NotoSerifKR',
                    ),
                  ),
                  Text(
                    '올해의 생일은 어떻게 보냈는지 작성해주세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'NotoSerifKR',
                    ),
                  ),
                  SizedBox(height: 50),
                  if (!_isTextFieldVisible)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isTextFieldVisible = true;
                        });
                      },
                      child: Text('작성하러 가기'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF252525),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSerifKR',
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  if (_isTextFieldVisible)
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              labelText: '생일 메시지 작성',
                              border: InputBorder.none,
                              labelStyle: TextStyle(fontFamily: 'NotoSerifKR'),
                            ),
                            style: TextStyle(fontFamily: 'NotoSerifKR'),
                            maxLines: 5,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitBirthdayMessage,
                          child: Text('제출'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF252525),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSerifKR',
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _navigateToQuestionScreen,
                    child: Text(
                      '나중에 작성하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSerifKR',
                        color: Colors.grey, // 글씨 색상 설정
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
