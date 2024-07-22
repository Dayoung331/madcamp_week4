import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

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
  }

  Future<void> _printStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? submittedStatusString = prefs.getString('submittedStatus');
    if (submittedStatusString != null) {
      print("Stored Submitted Status: $submittedStatusString");
    } else {
      print("No submitted status found in SharedPreferences.");
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
    print("Loaded Submitted Status: $_isAnswerSubmittedMap");
  }

  void _populateEvents() {
    _events.clear();
    _isAnswerSubmittedMap.forEach((key, value) {
      if (value) {
        // 현재 연도를 포함하여 날짜 문자열을 생성하고 로컬 시간으로 변환 후 UTC로 변환
        DateTime date = DateTime(DateTime.now().year, int.parse(key.substring(0, 2)), int.parse(key.substring(2, 4)));
        date = DateTime.utc(date.year, date.month, date.day);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add('Submitted');
        // 디버깅 메시지 추가
        print("Event added for date: $date");
      }
    });
    // 디버깅 메시지 추가
    print("Events populated: $_events");
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
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              print("Marker builder for date: $date with events: $events"); // 디버깅 메시지 추가
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              );
            }
            return SizedBox();
          },
        ),
        eventLoader: (day) {
          // 디버깅 메시지 추가
          print("Events for $day: ${_events[day]}");
          return _events[day] ?? [];
        },
      ),
    );
  }
}
