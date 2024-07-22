import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  CalendarScreen({required this.onDateSelected});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List> _events = {};
  Map<String, bool> _isAnswerSubmittedMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadSubmittedStatus();
    _printStoredData(); // 저장된 데이터를 출력합니다.
    _loadDiaryEntries(); // 다이어리 엔트리 로드
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
    // 디버깅 메시지 추가
    // print("Loaded Submitted Status: $_isAnswerSubmittedMap");
  }

  Future<void> _loadDiaryEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    keys.forEach((key) {
      if (key.startsWith('diary_written_')) {
        String dateString = key.replaceFirst('diary_written_', '');
        try {
          DateTime date = DateFormat('yyyy.MM.dd').parse(dateString);
          date = DateTime.utc(date.year, date.month, date.day);  // UTC로 변환하여 시간 설정
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
        // print("Event added for date: $date");
      }
    });
    // print("Events populated: $_events");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
        centerTitle: true,
      ),
      body: TableCalendar(
        firstDay: DateTime(DateTime.now().year, 1, 1),
        lastDay: DateTime(DateTime.now().year, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDateSelected(selectedDay);
        },
        headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            )
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.map((event) {
                    return Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event == 'Submitted' ? Colors.blue : Colors.green,
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
    );
  }
}
