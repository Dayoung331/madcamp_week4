import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'past_answers_screen.dart';
import 'diary_screen.dart';

class CalendarScreen extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  CalendarScreen({required this.onDateSelected});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<String>> _events = {};
  Map<String, bool> _isAnswerSubmittedMap = {};
  Map<String, Map<String, String>> _answers = {}; // 날짜별 답변을 저장하는 맵
  Map<String, String> _questions = {}; // 날짜별 질문을 저장하는 맵
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadSubmittedStatus();
    _loadAnswers(); // 저장된 답변을 불러옵니다.
    _loadQuestions(); // 질문을 로드합니다.
    _printStoredData();
    _loadDiaryEntries();
    Intl.defaultLocale = 'ko_KR'; // 기본 로케일을 한국어로 설정
  }

  Future<void> _printStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? submittedStatusString = prefs.getString('submittedStatus');
    if (submittedStatusString != null) {
      // print("Stored Submitted Status: $submittedStatusString");
    } else {
      // print("No submitted status found in SharedPreferences.");
    }
  }

  Future<void> _loadSubmittedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? submittedStatusString = prefs.getString('submittedStatus');
    if (submittedStatusString != null) {
      Map<String, dynamic> decodedStatus = json.decode(submittedStatusString);
      setState(() {
        _isAnswerSubmittedMap = Map<String, bool>.from(decodedStatus);
        _populateEvents();
      });
    }
  }

  Future<void> _loadAnswers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? answersString = prefs.getString('answers');
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
    print("Answers loaded: $_answers");
  }

  Future<void> _loadQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? questionsString = prefs.getString('questions');
    if (questionsString != null) {
      Map<String, dynamic> decodedQuestions = json.decode(questionsString);
      setState(() {
        _questions = Map<String, String>.from(decodedQuestions);
      });
    }
  }

  Future<void> _loadDiaryEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    keys.forEach((key) {
      if (key.startsWith('diary_written_')) {
        String dateString = key.replaceFirst('diary_written_', '');
        try {
          DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
          date = DateTime.utc(date.year, date.month, date.day);
          setState(() {
            if (_events[date] == null) {
              _events[date] = [];
            }
            _events[date]!.add('Diary Entry');
          });
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    });
    print("Loaded Diary Entries: $_events");
  }

  void _populateEvents() {
    _events.clear();
    _isAnswerSubmittedMap.forEach((key, value) {
      if (value) {
        DateTime date = DateTime(DateTime.now().year, int.parse(key.substring(0, 2)), int.parse(key.substring(2, 4)));
        date = DateTime.utc(date.year, date.month, date.day);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add('Submitted');
      }
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _events[selectedDay] ?? [];
    });
    widget.onDateSelected(selectedDay);
  }

  void _navigateToDiary(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryScreen(initialDate: date),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      rowHeight: 70, // 행 높이 설정
      locale: 'ko_KR', // 달력 로케일을 한국어로 설정
      firstDay: DateTime(DateTime.now().year, 1, 1),
      lastDay: DateTime(DateTime.now().year, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: _onDaySelected,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.black, // 제목 색상 변경
          fontFamily: 'NotoSerifKR',
        ),
        headerPadding: EdgeInsets.symmetric(vertical: 8.0),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        leftChevronMargin: EdgeInsets.only(left: 20.0),
        rightChevronMargin: EdgeInsets.only(right: 20.0),
      ),
      daysOfWeekHeight: 30, // 요일 행의 높이를 설정합니다.
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        weekendTextStyle: TextStyle(
          color: Colors.black, // 주말 글씨체 변경
        ),
        holidayTextStyle: TextStyle(
          color: Colors.blue,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white,
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
        ),
        defaultTextStyle: TextStyle(
          color: Colors.black,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.rectangle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.rectangle,
        ),
        outsideDecoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
        ),
        cellMargin: EdgeInsets.all(6.0), // 각 셀의 여백을 조정하여 셀 크기 증가
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0), // 요일 아래 공백 조정
              child: Text(
                DateFormat.E('ko_KR').format(day)[0], // 요일의 첫 글자만 표시
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        defaultBuilder: (context, date, focusedDay) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.rectangle,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          );
        },
        outsideBuilder: (context, date, focusedDay) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.rectangle,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          );
        },
        selectedBuilder: (context, date, focusedDay) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black54,
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.rectangle,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          );
        },
        todayBuilder: (context, date, focusedDay) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.rectangle,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          );
        },
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            bool isTodayOrSelected = isSameDay(date, DateTime.now()) || isSameDay(date, _selectedDay);
            return Positioned(
              bottom: 4, // 아이콘 위치를 조정
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.map((event) {
                  return Container(
                    width: 18, // 이미지 너비 설정
                    height: 18, // 이미지 높이 설정
                    margin: EdgeInsets.symmetric(horizontal: 1.5),
                    child: Image.asset(
                      event == 'Submitted' ? 'assets/images/calendar_question.png' : 'assets/images/diary_icon.png', // 이미지 파일 경로 설정
                      color: isTodayOrSelected ? Colors.white : null, // 선택된 날짜 또는 오늘 날짜면 아이콘을 흰색으로 설정
                      fit: BoxFit.cover, // 이미지 비율에 맞게 조정
                    ),
                  );
                }).toList(),
              ),
            );
          }
          return SizedBox();
        },
      ),
      eventLoader: (day) {
        return _events[day] ?? [];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 70),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _buildCalendar(),
            ),
            ListView.builder(
              shrinkWrap: true, // ListView의 크기를 내용에 맞게 조절
              physics: NeverScrollableScrollPhysics(), // 별도의 스크롤 불가
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0), // 여백을 조금 더 줄임
                  child: ScheduleCard(
                    title: event,
                    color: Colors.black54,
                    date: _selectedDay ?? DateTime.now(), // 선택된 날짜를 전달
                    onTap: () {
                      if (event == 'Diary Entry') {
                        _navigateToDiary(_selectedDay ?? DateTime.now());
                      } else {
                        // dateKey를 생성
                        String dateKey = DateFormat('MMdd').format(_selectedDay ?? DateTime.now());
                        // 질문 가져오기
                        String question = _questions[dateKey] ?? "질문 없음";
                        // PastAnswersScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PastAnswersScreen(
                              dateKey: dateKey,
                              answers: _answers[dateKey] ?? {},
                              question: question,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String title;
  final Color color;
  final DateTime date;
  final Function onTap;

  ScheduleCard({required this.title, required this.color, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 날짜 형식을 "MM월 dd일"로 변환
    String formattedDate = DateFormat('MM월 dd일').format(date);
    String displayTitle;

    if (title == 'Submitted') {
      displayTitle = "$formattedDate의 답변 보기";
    } else if (title == 'Diary Entry') {
      displayTitle = "$formattedDate의 일기 보기";
    } else {
      displayTitle = title;
    }

    // 이미지 파일 경로 설정
    String imagePath;
    if (title == 'Submitted') {
      imagePath = 'assets/images/calendar_question.png';
    } else if (title == 'Diary Entry') {
      imagePath = 'assets/images/diary_icon.png';
    } else {
      imagePath = 'assets/images/default.png'; // 기본 이미지 파일 경로 (선택 사항)
    }

    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // 모서리를 둥글게 설정
          side: BorderSide(color: color, width: 2.0), // 테두리 색상과 두께 설정
        ),
        elevation: 5.0, // 그림자 설정
        color: Colors.white, // 카드 배경색을 흰색으로 설정
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 패딩 조정
          leading: Image.asset(
            imagePath,
            width: 40.0, // 이미지 너비 설정
            height: 40.0, // 이미지 높이 설정
            fit: BoxFit.cover, // 이미지 비율에 맞게 조정
          ), // title에 따라 다른 이미지를 표시
          title: Text(
            displayTitle,
            style: TextStyle(color: Colors.black, fontFamily: 'NotoSerifKR'), // 텍스트 스타일 변경
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: color), // 오른쪽에 아이콘 추가 및 색상 설정
        ),
      ),
    );
  }
}
