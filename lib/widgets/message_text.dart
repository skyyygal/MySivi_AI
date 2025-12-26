import 'package:flutter/material.dart';

class MessageText extends StatelessWidget {
  final String message;
  final Function(String) onWordLongPress;
  final bool isSender;

  const MessageText({
    super.key,
    required this.message,
    required this.onWordLongPress,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    final words = message.split(' ');

    return Wrap(
      spacing: 0.5,
      runSpacing: 1,
      children: words.map((word) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

        return GestureDetector(
          onLongPress: () {
            if (cleanWord.isNotEmpty) {
              final displayWord =
                  cleanWord[0].toUpperCase() + cleanWord.substring(1);
              onWordLongPress(displayWord);
            }
          },
          child: Text(
            '$word ',
            style: TextStyle(
              fontSize: 16,
              color: isSender ? Colors.white : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}
