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

  void _populateEvents() {
    _events.clear();
    _isAnswerSubmittedMap.forEach((key, value) {
      if (value) {
        DateTime date = DateFormat('MMdd').parse(key);
        date = DateTime(DateTime.now().year, date.month, date.day);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add('Submitted');
      }
    });
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
          return _events[day] ?? [];
        },
      ),
    );
  }
}
