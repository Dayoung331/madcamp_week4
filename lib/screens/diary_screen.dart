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
      _showCustomSnackbar('제목 또는 내용을 입력해주세요');
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

    _showCustomSnackbar('저장되었습니다.');

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

    _showCustomSnackbar('삭제되었습니다.');
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white, // 배경색을 흰색으로 설정
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white, // 배경색을 흰색으로 설정
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.black,
                  size: 40,
                ),
                SizedBox(height: 20),
                Text(
                  '일기를 삭제하시겠습니까?',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSerifKR',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'NotoSerifKR',
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(width: 10), // 버튼 간격 조정
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '삭제',
                        style: TextStyle(
                          fontFamily: 'NotoSerifKR',
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteEntry(index);
                      },
                    ),
                  ),
                ],
              ),
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

    _showCustomSnackbar('수정되었습니다.');

    _loadSavedDiary();
  }

  void _changeDate(int days) {
    setState(() {
      DateTime newDate = _selectedDate.add(Duration(days: days));
      if (newDate.isAfter(DateTime.now())) {
        _showCustomSnackbar('오늘 이후의 날짜로는 이동할 수 없습니다.');
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

  void _showCustomSnackbar(String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFFE5D0B5)),
          SizedBox(width: 8.0),
          Text(message),
        ],
      ),
      backgroundColor: Colors.grey[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        toolbarHeight: 120,
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
                    fontFamily: 'NotoSerifKR',
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSerifKR',
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
                      fontFamily: 'NotoSerifKR',
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'NotoSerifKR',
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
            fontFamily: 'NotoSerifKR',
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
