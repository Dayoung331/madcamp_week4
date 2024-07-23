import 'package:flutter/material.dart';

class EntryForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onSave;

  EntryForm({
    required this.titleController,
    required this.contentController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
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
                controller: titleController,
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
                controller: contentController,
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
            onPressed: onSave,
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
  }
}
