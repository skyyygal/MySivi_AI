import 'package:flutter/material.dart';
import 'package:my_sivi_ai/core/constants.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.gradient, required this.text});

  final Gradient gradient;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),

      child: Center(
        child: Text(text, style: TextStyle(fontSize: 20, color: whiteColor)),
      ),
    );
  }
}
