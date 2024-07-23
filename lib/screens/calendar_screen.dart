import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CalendarScreen extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  CalendarScreen({required this.onDateSelected});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<String>> _events = {};
  Map<String, bool> _isAnswerSubmittedMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadSubmittedStatus();
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

  Future<void> _loadDiaryEntries() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/diaries'));

    if (response.statusCode == 200) {
      List<dynamic> decodedEntries = json.decode(response.body);
      decodedEntries.forEach((entry) {
        try {
          DateTime date = DateTime.parse(entry['date']);
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
      });
      print("Loaded Diary Entries: $_events");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '캘린더',
          style: TextStyle(fontFamily: 'AppleMyungjo'), // 글씨체 변경
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFE5D0B5), // 앱바 배경색 변경
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.0, // 이 값을 조정하여 달력의 높이를 조정할 수 있습니다.
            child: TableCalendar(
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
                  fontFamily: 'AppleMyungjo', // 글씨체 변경
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                  color: Colors.black, // 제목 색상 변경
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black), // 왼쪽 화살표 색상 변경
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black), // 오른쪽 화살표 색상 변경
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 평일 글씨체 변경
                  color: Colors.black,
                ),
                weekendStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 주말 글씨체 변경
                  color: Colors.red, // 일요일 글씨체 변경
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 주말 글씨체 변경
                  color: Colors.red, // 일요일 글씨체 변경
                ),
                holidayTextStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 공휴일 글씨체 변경
                  color: Colors.blue,
                ),
                selectedTextStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 선택된 날짜 글씨체 변경
                  color: Colors.white,
                ),
                todayTextStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 오늘 날짜 글씨체 변경
                  color: Colors.white,
                ),
                defaultTextStyle: TextStyle(
                  fontFamily: 'AppleMyungjo', // 기본 날짜 글씨체 변경
                  color: Colors.black,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFFE5D0B5),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                cellMargin: EdgeInsets.all(4.0), // 각 셀의 여백을 조정하여 셀 크기 증가
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        '일',
                        style: TextStyle(
                          fontFamily: 'AppleMyungjo',
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else if (day.weekday == DateTime.saturday) {
                    return Center(
                      child: Text(
                        '토',
                        style: TextStyle(
                          fontFamily: 'AppleMyungjo',
                          color: Colors.blue,
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        DateFormat.E('ko_KR').format(day),
                        style: TextStyle(
                          fontFamily: 'AppleMyungjo',
                          color: Colors.black,
                        ),
                      ),
                    );
                  }
                },
                defaultBuilder: (context, date, focusedDay) {
                  return Container(
                    margin: EdgeInsets.all(16.0), // 셀 내부의 여백을 늘려 셀 크기 증가
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontFamily: 'AppleMyungjo', // 날짜 글씨체 변경
                        fontSize: 16.0,
                        color: date.weekday == DateTime.saturday
                            ? Colors.blue
                            : (date.weekday == DateTime.sunday ? Colors.red : Colors.black),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, date, focusedDay) {
                  return Container(
                    margin: EdgeInsets.all(8.0), // 셀 내부의 여백을 늘려 셀 크기 증가
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFE5D0B5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontFamily: 'AppleMyungjo', // 선택된 날짜 글씨체 변경
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                todayBuilder: (context, date, focusedDay) {
                  return Container(
                    margin: EdgeInsets.all(8.0), // 셀 내부의 여백을 늘려 셀 크기 증가
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontFamily: 'AppleMyungjo', // 오늘 날짜 글씨체 변경
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.map((event) {
                          return Container(
                            width: 15, // 이미지 너비 설정
                            height: 15, // 이미지 높이 설정
                            margin: EdgeInsets.symmetric(horizontal: 1.5),
                            child: Image.asset(
                              event == 'Submitted' ? 'assets/images/calendar_diary.png' : 'assets/images/calendar_question_and_answer.png', // 이미지 파일 경로 설정
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
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                return ScheduleCard(
                  title: event,
                  color: event == 'Submitted' ? Colors.blue : Colors.green,
                  date: _selectedDay ?? DateTime.now(), // 선택된 날짜를 전달
                  onTap: () {
                    // 다른 화면으로 이동할 때 Navigator 사용
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
      imagePath = 'assets/images/calendar_question_and_answer.png';
    } else if (title == 'Diary Entry') {
      imagePath = 'assets/images/calendar_diary.png';
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
          leading: Image.asset(
            imagePath,
            width: 40.0, // 이미지 너비 설정
            height: 40.0, // 이미지 높이 설정
            fit: BoxFit.cover, // 이미지 비율에 맞게 조정
          ), // title에 따라 다른 이미지를 표시
          title: Text(
            displayTitle,
            style: TextStyle(color: Colors.black, fontFamily: 'AppleMyungjo', fontWeight: FontWeight.bold), // 텍스트 스타일 변경
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: color), // 오른쪽에 아이콘 추가 및 색상 설정
        ),
      ),
    );
  }
}


class EventDetailScreen extends StatelessWidget {
  final String event;

  EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Center(
        child: Text('Details for $event'),
      ),
    );
  }
}
