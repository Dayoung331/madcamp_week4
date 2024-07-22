import 'package:flutter/material.dart';
import 'package:madcamp_week4/screens/question_screen.dart';
import 'package:madcamp_week4/screens/diary_screen.dart';
import 'package:madcamp_week4/screens/calendar_screen.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  static List<Widget> _widgetOptions = <Widget>[
    QuestionScreen(),
    DiaryScreen(selectedDay: DateTime.now()), // 임의의 초기 날짜로 초기화
    // CalendarScreen() 호출 시 onDateSelected 전달 필요
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDateSelected(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _widgetOptions[1] = DiaryScreen(selectedDay: selectedDate);
      _widgetOptions[0] = QuestionScreen(); // 선택된 날짜에 따라 다른 QuestionScreen 내용 업데이트 가능
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 2
            ? CalendarScreen(onDateSelected: _onDateSelected)
            : _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/question.png'),
              color: _selectedIndex == 0 ? Color(0xFF776B5D) : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/diary.png'),
              color: _selectedIndex == 1 ? Color(0xFF776B5D) : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/calendar.png'),
              color: _selectedIndex == 2 ? Color(0xFF776B5D) : Colors.grey,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF776B5D),
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
      ),
    );
  }
}
