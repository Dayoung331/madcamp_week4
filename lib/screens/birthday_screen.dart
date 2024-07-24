import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question_screen.dart';

class BirthdayScreen extends StatefulWidget {
  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  late ConfettiController _confettiController;
  TextEditingController _textController = TextEditingController();
  bool _isTextFieldVisible = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play(); // 화면이 열리면 색종이가 날리도록 설정
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveBirthdayMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final year = DateTime.now().year;
    await prefs.setString('birthday_message_$year', message);
    print('Birthday message saved for year $year: $message');
  }

  void _navigateToQuestionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuestionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '생일을 축하합니다!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '생일을 행복하게 보내고 계신가요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '올해의 생일은 어떻게 보냈는지 작성해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isTextFieldVisible = true;
                      _confettiController.play();
                    });
                  },
                  child: Text('작성하러 가기'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color(0xFFE5D0B5),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                      SizedBox(height: 20),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: '생일 메시지 작성',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _saveBirthdayMessage(_textController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('생일 메시지가 저장되었습니다!')),
                          );
                          setState(() {
                            _isTextFieldVisible = false;
                            _textController.clear();
                          });
                          _navigateToQuestionScreen(); // 답변 제출 후 QuestionScreen으로 이동
                        },
                        child: Text('제출'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Color(0xFFE5D0B5),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // 색종이가 아래로 날리도록 설정
              emissionFrequency: 0.05,
              numberOfParticles: 5,
              maxBlastForce: 5,
              minBlastForce: 1,
              gravity: 0.1,
              colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.purple], // 색종이 색상
            ),
          ),
        ],
      ),
    );
  }
}
