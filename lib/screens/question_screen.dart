import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'past_answers_screen.dart';
import 'birthday_answers_screen.dart';
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
  bool _isBirthday = false; // 생일인지 여부를 저장

  bool get _isAnswerSubmitted => _isAnswerSubmittedMap[DateFormat('MMdd').format(_currentDate)] ?? false;
  set _isAnswerSubmitted(bool value) => _isAnswerSubmittedMap[DateFormat('MMdd').format(_currentDate)] = value;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadAnswers(); // 저장된 답변을 불러옵니다.
    _checkBirthday(); // 생일인지 여부를 체크
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
    _checkBirthday(); // 날짜가 변경될 때마다 생일인지 여부를 체크
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
      print('Animation started');
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showAnimation = false;
        print('Animation ended');
      });
    });
  }

  void _showConfirmationDialog(String dateKey, String newAnswer) {
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
                  '기존 답변이 덮어씌워집니다. 계속하시겠습니까?',
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
                        '예',
                        style: TextStyle(
                          fontFamily: 'NotoSerifKR',
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _saveAnswer(dateKey, newAnswer);
                        _answerController.clear();
                        setState(() {
                          _isAnswerSubmitted = true;
                        });
                        _showSnackbar("답변이 저장되었습니다!"); // 안내문구 표시
                        _showRevealAnimation(); // 애니메이션 실행
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

  void _navigateToEditQuestionScreen(int dayOfYear, String question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(dayOfYear: dayOfYear, question: question),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _questions[dayOfYear - 1] = result;
      });
      _saveQuestions();
      _showSnackbar("질문이 수정되었습니다!");
    }
  }

  Future<void> _checkBirthday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? birthdayString = prefs.getString('birthday');
    if (birthdayString != null) {
      DateTime birthday = DateFormat('yyyy-MM-dd').parse(birthdayString);
      setState(() {
        _isBirthday = (birthday.month == _currentDate.month && birthday.day == _currentDate.day);
        print('Birthday check: $_isBirthday');
      });
    }
  }

  void _showBirthdayAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> birthdayAnswers = {};
    prefs.getKeys().forEach((key) {
      if (key.startsWith('birthday_message_')) {
        birthdayAnswers[key.replaceFirst('birthday_message_', '')] = prefs.getString(key)!;
      }
    });
    print('Birthday answers: $birthdayAnswers');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BirthdayAnswersScreen(
          birthdayAnswers: birthdayAnswers,
        ),
      ),
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
            Row(
              children: [
                Text(
                  DateFormat('yyyy. MM. dd').format(_currentDate),
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                if (_isBirthday)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 아이콘과 텍스트 사이의 간격 조정
                    child: IconButton(
                      icon: Icon(Icons.cake, color: Colors.pink),
                      onPressed: _showBirthdayAnswers,
                    ),
                  ),
              ],
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
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      _navigateToEditQuestionScreen(dayOfYear, question);
                    },
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
                      maxLines: 9,
                      style: TextStyle(fontFamily: 'NotoSerifKR'),
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
                      backgroundColor: _isAnswerSubmitted ? Color(0xFF252525) : Color(0xFF979797),
                      padding: EdgeInsets.symmetric(horizontal: 112, vertical: 10), // 버튼 크기 조정
                      minimumSize: Size(250, 50),
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
                            question: _questions[(dayOfYear - 1) % 366], // 해당 날짜의 질문 전달
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
                      backgroundColor: Color(0xFF979797),
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
              Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Lottie.asset(
                    'assets/Animation_send.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class EditQuestionScreen extends StatelessWidget {
  final int dayOfYear;
  final String question;
  final TextEditingController _controller;

  EditQuestionScreen({required this.dayOfYear, required this.question}) : _controller = TextEditingController(text: question);

  @override
  Widget build(BuildContext context) {
    FocusNode _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: // 왼쪽 패딩 추가
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: Text('취소', style: TextStyle(color: Colors.black, fontFamily: 'AppleMyungjo')),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop(_controller.text);
            },
            child: Text('완료', style: TextStyle(color: Colors.black, fontFamily: 'AppleMyungjo')),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  SizedBox(height: 230),
                  Text(
                    '원하는 질문으로 바꿔보세요',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'AppleMyungjo',
                    ),
                  ),
                  SizedBox(height: 50),
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    focusNode: _focusNode,
                    style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'AppleMyungjo'),
                    maxLines: null, // 여러 줄에 걸쳐서 텍스트를 표시할 수 있도록 설정
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '질문을 입력하세요',
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
