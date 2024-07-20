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

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
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
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            _changeDate(-1); // 날짜를 하루 줄입니다.
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
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
                    Text(
                      _entries[index]['title']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AppleMyungjo',
                      ),
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
