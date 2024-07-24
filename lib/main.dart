import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 로케일 초기화
import 'package:flutter_localizations/flutter_localizations.dart'; // Flutter 로컬라이제이션
import 'package:madcamp_week4/screens/birthday_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/question_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/birthday_input_screen.dart'; // 생일 입력 화면 추가

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
      locale: Locale('ko', 'KR'), // 기본 로케일을 한국어로 설정
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'), // 한국어 지원
      ],
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
  bool _isBirthdayEntered = false;

  @override
  void initState() {
    super.initState();
    _checkBirthdayEntered();
  }

  Future<void> _checkBirthdayEntered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBirthdayEntered = prefs.getBool('birthdayEntered') ?? false;
    });
  }

  void _onBirthdayEntered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('birthdayEntered', true);
    setState(() {
      _isBirthdayEntered = true;
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    //QuestionScreen(),
    BirthdayScreen(),
    DiaryScreen(),
    CalendarScreen(onDateSelected: (date) {
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
        child: _isBirthdayEntered
            ? _widgetOptions.elementAt(_selectedIndex)
            : BirthdayInputScreen(onBirthdayEntered: _onBirthdayEntered),
      ),
      bottomNavigationBar: _isBirthdayEntered
          ? BottomNavigationBar(
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
      )
          : null,
    );
  }
}
