import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 로케일 초기화
import 'package:madcamp_week4/screens/question_screen.dart';
import 'package:madcamp_week4/screens/diary_screen.dart';
import 'package:madcamp_week4/screens/calendar_screen.dart';

void main() {
  initializeDateFormatting('ko_KR', null).then((_) { // 로케일 초기화
    runApp(MyApp());
  });
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

  static List<Widget> _widgetOptions = <Widget>[
    QuestionScreen(),
    DiaryScreen(), // 임의의 초기 날짜로 초기화
    CalendarScreen(onDateSelected: (date) {
      // 날짜 선택 시 실행될 함수
      print('Selected date: $date');
    }),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
