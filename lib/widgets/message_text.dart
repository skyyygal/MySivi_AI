import 'package:flutter/material.dart';

class MessageText extends StatelessWidget {
  final String message;
  final Function(String) onWordLongPress;

  const MessageText({
    super.key,
    required this.message,
    required this.onWordLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final words = message.split(' ');

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: words.map((word) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

        return GestureDetector(
          onLongPress: () {
            if (cleanWord.isNotEmpty) {
              onWordLongPress(cleanWord);
            }
          },
          child: Text('$word ', style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
    );
  }
}
