import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<Map<String, dynamic>> _entries = [];
  bool _hasSavedData = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDiary();
  }

  Future<void> _loadSavedDiary() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/diaries/$formattedDate'));

    if (response.statusCode == 200) {
      setState(() {
        _entries = List<Map<String, dynamic>>.from(json.decode(response.body));
        _hasSavedData = _entries.isNotEmpty;
      });
    } else {
      setState(() {
        _entries = [];
        _hasSavedData = false;
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목 또는 내용을 입력해주세요')),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String formattedTime = DateFormat('a hh:mm').format(DateTime.now());

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/diaries'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': _titleController.text,
        'content': _contentController.text,
        'date': formattedDate,
        'time': formattedTime,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장되었습니다.')),
      );
      _loadSavedDiary();
      _titleController.clear();
      _contentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장에 실패했습니다.')),
      );
    }
  }

  Future<void> _deleteEntry(int index) async {
    String id = _entries[index]['_id'];

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/diaries/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _entries.removeAt(index);
        _hasSavedData = _entries.isNotEmpty;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제에 실패했습니다.')),
      );
    }
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEntry(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditModalBottomSheet(int index) {
    _titleController.text = _entries[index]['title'];
    _contentController.text = _entries[index]['content'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '일기 수정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AppleMyungjo',
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '제목',
                      hintStyle: TextStyle(
                        color: Colors.brown,
                        fontSize: 20,
                        fontFamily: 'AppleMyungjo',
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AppleMyungjo',
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: '내용을 입력하세요.',
                      hintStyle: TextStyle(
                        color: Colors.brown,
                        fontSize: 18,
                        fontFamily: 'AppleMyungjo',
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'AppleMyungjo',
                      color: Colors.brown,
                    ),
                    maxLines: 5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateEntry(index);
                  Navigator.of(context).pop();
                },
                child: Text('저장 완료', style: TextStyle(fontFamily: 'AppleMyungjo', color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE5D0B5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }


  Future<void> _updateEntry(int index) async {
    String id = _entries[index]['_id'];

    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/diaries/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': _titleController.text,
        'content': _contentController.text,
        'date': _entries[index]['date'],
        'time': _entries[index]['time'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정되었습니다.')),
      );
      _loadSavedDiary();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정에 실패했습니다.')),
      );
    }
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
    String formattedDate = DateFormat('yyyy. MM. dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(formattedDate),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: const EdgeInsets.only(left: 35.0),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            _changeDate(-1);
          },
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 35.0),
            icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () {
              _changeDate(1);
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
                          _entries[index]['title'],
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
                                _showEditModalBottomSheet(index);
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
                              onPressed: () => _showDeleteConfirmationDialog(index),
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
                      '${DateFormat('yyyy년 M월 d일').format(_selectedDate)} ${_entries[index]['time']}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'AppleMyungjo',
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      _entries[index]['content'],
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
