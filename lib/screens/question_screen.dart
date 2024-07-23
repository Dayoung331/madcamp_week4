import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'past_answers_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  DateTime _currentDate = DateTime.now();
  List<String> _questions = [];
  Map<String, Map<String, String>> _answers = {}; // 날짜별 답변을 저장하는 맵
  Map<String, bool> _isAnswerSubmittedMap = {}; // 날짜별 답변 제출 상태를 저장하는 맵
  TextEditingController _answerController = TextEditingController();
  bool _showAnimation = false;

  bool get _isAnswerSubmitted => _isAnswerSubmittedMap[DateFormat('MMdd').format(_currentDate)] ?? false;
  set _isAnswerSubmitted(bool value) => _isAnswerSubmittedMap[DateFormat('MMdd').format(_currentDate)] = value;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadAnswers(); // 저장된 답변을 불러옵니다.
  }

  Future<void> _loadQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? questionsString = prefs.getString('questions');
    if (questionsString != null) {
      setState(() {
        _questions = List<String>.from(json.decode(questionsString));
      });
    } else {
      final String response = await rootBundle.loadString('assets/questions.json');
      final data = await json.decode(response);
      setState(() {
        _questions = List<String>.from(data['questions']);
      });
      await prefs.setString('questions', json.encode(_questions));
    }
  }

  Future<void> _saveQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('questions', json.encode(_questions));
  }

  Future<void> _loadAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? answersString = prefs.getString('answers');
    String? submittedStatusString = prefs.getString('submittedStatus');
    if (answersString != null) {
      Map<String, dynamic> decodedAnswers = json.decode(answersString);
      Map<String, Map<String, String>> loadedAnswers = {};
      decodedAnswers.forEach((key, value) {
        loadedAnswers[key] = Map<String, String>.from(value);
      });
      setState(() {
        _answers = loadedAnswers;
      });
    }
    if (submittedStatusString != null) {
      Map<String, dynamic> decodedStatus = json.decode(submittedStatusString);
      setState(() {
        _isAnswerSubmittedMap = Map<String, bool>.from(decodedStatus);
      });
    }
    print("Answers loaded: $_answers");
    print("Submitted status loaded: $_isAnswerSubmittedMap");
  }

  Future<void> _saveAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedAnswers = json.encode(_answers);
    await prefs.setString('answers', encodedAnswers);
    String encodedStatus = json.encode(_isAnswerSubmittedMap);
    await prefs.setString('submittedStatus', encodedStatus);
    print("Answers saved: $encodedAnswers");
    print("Submitted status saved: $encodedStatus");
  }

  void _saveAnswer(String date, String answer) {
    String year = DateFormat('yyyy').format(DateTime.now());
    setState(() {
      if (!_answers.containsKey(date)) {
        _answers[date] = {};
      }
      _answers[date]![year] = answer;
      _isAnswerSubmitted = true; // 날짜별 상태 업데이트
    });
    _saveAnswers();
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
  }

  void _submitAnswer() {
    FocusScope.of(context).unfocus(); // 키보드를 숨김
    String answer = _answerController.text;
    if (answer.isNotEmpty) {
      String dateKey = DateFormat('MMdd').format(_currentDate);
      if (_answers.containsKey(dateKey) && _answers[dateKey]!.containsKey(DateFormat('yyyy').format(DateTime.now()))) {
        _showConfirmationDialog(dateKey, answer);
      } else {
        _saveAnswer(dateKey, answer);
        _answerController.clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _isAnswerSubmitted = true;
        });
        print("Answer submitted: $answer for date: $dateKey");
        _showSnackbar("답변이 제출되었습니다!");
        _showRevealAnimation();
      }
    }
  }

  void _showRevealAnimation() {
    setState(() {
      _showAnimation = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showAnimation = false;
      });
    });
  }

  void _showConfirmationDialog(String dateKey, String newAnswer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('답변을 다시 제출하시겠습니까?'),
          content: Text('기존 답변이 덮어씌워집니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('아니요'),
            ),
            TextButton(
              onPressed: () {
                _saveAnswer(dateKey, newAnswer);
                _answerController.clear();
                setState(() {
                  _isAnswerSubmitted = true;
                });
                Navigator.of(context).pop();
                print("Answer resubmitted: $newAnswer for date: $dateKey");
                _showSnackbar("답변이 제출되었습니다!"); // Snackbar 표시
                _showRevealAnimation(); // 애니메이션 실행
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFFE5D0B5)),
            SizedBox(width: 8.0),
            Text(message),
          ],
        ),
        backgroundColor: Colors.grey[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _updateSubmittedStatus(String dateKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? submittedStatusString = prefs.getString('submittedStatus');
    if (submittedStatusString != null) {
      Map<String, dynamic> decodedStatus = json.decode(submittedStatusString);
      setState(() {
        _isAnswerSubmittedMap = Map<String, bool>.from(decodedStatus);
      });
    }
  }

  void _showEditQuestionDialog(int dayOfYear) {
    TextEditingController questionController = TextEditingController(text: _questions[dayOfYear - 1]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('질문 수정'),
          content: TextField(
            controller: questionController,
            decoration: InputDecoration(
              hintText: '질문을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _questions[dayOfYear - 1] = questionController.text;
                });
                _saveQuestions();
                Navigator.of(context).pop();
                _showSnackbar("질문이 수정되었습니다!");
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    int dayOfYear = int.parse(DateFormat('D').format(_currentDate));
    String question = _questions[(dayOfYear - 1) % 366];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              padding: const EdgeInsets.only(left: 15.0),
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                _changeDate(-1);
              },
            ),
            Text(
              DateFormat('yyyy. MM. dd').format(_currentDate),
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            IconButton(
              padding: const EdgeInsets.only(right: 15.0),
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _changeDate(1);
              },
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditQuestionDialog(dayOfYear);
            },
          ),
        ],
        elevation: 0,
        toolbarHeight: 120, // AppBar height 설정
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 텍스트 필드 이외의 영역을 클릭하면 키보드를 닫음
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Transform.rotate(
                        angle: 180 * 3.1415927 / 180,
                        child: Icon(Icons.format_quote, size: 30, color: Colors.black),
                      ),
                    )
                  ),
                  Container(
                    width: 250,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Text(
                      '$question',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'NotoSerifKR',
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.format_quote, size: 30, color: Colors.black),
                    )
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 320,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _answerController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '답변',
                        hintStyle: TextStyle(
                          fontFamily: 'NotoSerifKR',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _isAnswerSubmitted ? Colors.green : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10), // 버튼 크기 조정
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: 10),
                        Text(
                          '답변 제출',
                          style: TextStyle(
                            fontFamily: 'NotoSerifKR',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String dateKey = DateFormat('MMdd').format(_currentDate);
                      bool shouldUpdate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PastAnswersScreen(
                            dateKey: dateKey,
                            answers: _answers[dateKey] ?? {},
                          ),
                        ),
                      );
                      if (shouldUpdate == true) {
                        await _loadAnswers(); // 삭제 후 상태를 다시 로드
                        await _updateSubmittedStatus(dateKey);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      minimumSize: Size(250, 50), // 버튼의 최소 크기 설정
                    ),
                    child: Text(
                      '과거의 나 돌아보기',
                      style: TextStyle(
                        fontFamily: 'NotoSerifKR',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showAnimation)
              Center(
                child: Lottie.asset(
                  'assets/Animation_send.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
