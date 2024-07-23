import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryList extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final DateTime selectedDate;

  EntryList({
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
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
                      entries[index]['title'],
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
                            onEdit(index);
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
                          onPressed: () => onDelete(index),
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
                  '${DateFormat('yyyy년 M월 d일').format(selectedDate)} ${entries[index]['time']}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'AppleMyungjo',
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  entries[index]['content'],
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
    );
  }
}
