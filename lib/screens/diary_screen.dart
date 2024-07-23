import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'entry_form.dart';
import 'entry_list.dart';

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
  final DateTime? initialDate;

  DiaryScreen({this.initialDate});

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
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    _loadSavedDiary();
  }

  Future<void> _loadSavedDiary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String? savedDiary = prefs.getString(formattedDate);

    if (savedDiary != null) {
      setState(() {
        _entries = List<Map<String, dynamic>>.from(json.decode(savedDiary));
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

    Map<String, dynamic> newEntry = {
      'title': _titleController.text,
      'content': _contentController.text,
      'date': formattedDate,
      'time': formattedTime,
    };

    setState(() {
      _entries.add(newEntry);
      _hasSavedData = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(formattedDate, json.encode(_entries));

    // 일기 작성 여부를 SharedPreferences에 저장
    String diaryWrittenKey = 'diary_written_$formattedDate';
    prefs.setBool(diaryWrittenKey, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장되었습니다.')),
    );

    _titleController.clear();
    _contentController.clear();
  }

  Future<void> _deleteEntry(int index) async {
    setState(() {
      _entries.removeAt(index);
      _hasSavedData = _entries.isNotEmpty;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    prefs.setString(formattedDate, json.encode(_entries));

    // 일기 삭제 시 일기가 남아있는지 확인
    if (_entries.isEmpty) {
      String diaryWrittenKey = 'diary_written_$formattedDate';
      prefs.remove(diaryWrittenKey);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('삭제되었습니다.')),
    );
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
        return EntryForm(
          titleController: _titleController,
          contentController: _contentController,
          onSave: () {
            _updateEntry(index);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _updateEntry(int index) async {
    setState(() {
      _entries[index]['title'] = _titleController.text;
      _entries[index]['content'] = _contentController.text;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    prefs.setString(formattedDate, json.encode(_entries));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('수정되었습니다.')),
    );

    _loadSavedDiary();
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
        title: Text(formattedDate, style: TextStyle(fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 130,
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
            ? EntryList(
          entries: _entries,
          onEdit: _showEditModalBottomSheet,
          onDelete: _showDeleteConfirmationDialog,
          selectedDate: _selectedDate,
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
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 8.0),
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
        onPressed: () {
          _saveDiary();
        },
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
            _titleController.clear();
            _contentController.clear();
          });
        },
        backgroundColor: Color(0xFFE5D0B5),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
