import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiaryScreen(),
    );
  }
}

class DiaryScreen extends StatefulWidget {
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, String>> _entries = [];
  bool _hasSavedData = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDiary();
  }

  Future<void> _loadSavedDiary() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy.MM.dd').format(_selectedDate);

    setState(() {
      _entries.clear();
      _hasSavedData = false;
    });

    int index = 0;
    while (true) {
      String? title = prefs.getString('diary_title_${formattedDate}_$index');
      String? content = prefs.getString('diary_content_${formattedDate}_$index');
      String? time = prefs.getString('diary_time_${formattedDate}_$index');

      if (title == null || content == null || time == null) {
        break;
      }

      setState(() {
        _entries.add({'title': title, 'content': content, 'time': time});
        _hasSavedData = true;
      });

      index++;
    }
  }

  Future<void> _saveDiary() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목 또는 내용을 입력해주세요')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy.MM.dd').format(_selectedDate);
    String formattedTime = DateFormat('a hh:mm').format(DateTime.now()); // 시간 형식 수정
    int index = _entries.length;

    await prefs.setString('diary_title_${formattedDate}_$index', _titleController.text);
    await prefs.setString('diary_content_${formattedDate}_$index', _contentController.text);
    await prefs.setString('diary_time_${formattedDate}_$index', formattedTime);

    // 날짜 저장
    await prefs.setBool('diary_written_${formattedDate}', true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장되었습니다.')),
    );

    setState(() {
      _entries.add({
        'title': _titleController.text,
        'content': _contentController.text,
        'time': formattedTime,
      });
      _titleController.clear();
      _contentController.clear();
      _hasSavedData = true;
    });
  }

  Future<void> _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy.MM.dd').format(_selectedDate);

    await prefs.remove('diary_title_${formattedDate}_$index');
    await prefs.remove('diary_content_${formattedDate}_$index');
    await prefs.remove('diary_time_${formattedDate}_$index');

    setState(() {
      _entries.removeAt(index);
      _hasSavedData = _entries.isNotEmpty;
    });
  }

  void _changeDate(int days) {
    setState(() {
      DateTime newDate = _selectedDate.add(Duration(days: days));
      if (newDate.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오늘 이후의 날짜로는 이동할 수 없습니다.')),
        );
        return;
      }
      _selectedDate = newDate;
      _titleController.clear();
      _contentController.clear();
      _entries.clear();
      _hasSavedData = false;
      _loadSavedDiary();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy. MM. dd').format(_selectedDate); // 날짜 형식 수정

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(formattedDate),
        centerTitle: true,
        elevation: 0, // AppBar의 그림자 제거
        scrolledUnderElevation: 0, // 스크롤 시 그림자 제거
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 35.0),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            _changeDate(-1); // 날짜를 하루 줄입니다.
          },
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 35.0),
            icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () {
              _changeDate(1); // 날짜를 하루 늘립니다.
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _hasSavedData
            ? ListView.builder(
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _entries[index]['title']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'AppleMyungjo',
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // 수정 기능 구현
                              },
                              child: Text(
                                '수정',
                                style: TextStyle(
                                  fontFamily: 'AppleMyungjo',
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _deleteEntry(index),
                              child: Text(
                                '삭제',
                                style: TextStyle(
                                  fontFamily: 'AppleMyungjo',
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '${DateFormat('yyyy년 M월 d일').format(_selectedDate)} ${_entries[index]['time']!}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'AppleMyungjo',
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      _entries[index]['content']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'AppleMyungjo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '제목',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontFamily: 'AppleMyungjo',
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AppleMyungjo',
                ),
              ),
            ),
            Divider(color: Colors.grey, thickness: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요.',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontFamily: 'AppleMyungjo',
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'AppleMyungjo',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_hasSavedData
          ? FloatingActionButton.extended(
        onPressed: _saveDiary,
        backgroundColor: Color(0xFFE5D0B5),
        label: Text(
          '작성 완료',
          style: TextStyle(
            fontFamily: 'AppleMyungjo',
            color: Colors.black,
          ),
        ),
      )
          : FloatingActionButton(
        onPressed: () {
          setState(() {
            _hasSavedData = false;
          });
        },
        backgroundColor: Color(0xFFE5D0B5),
        child: Icon(Icons.add),
      ),
    );
  }
}
