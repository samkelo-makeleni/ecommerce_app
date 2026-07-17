import 'package:flutter/material.dart';

class SecondaryText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final double height;
  final int? maxLines;
  final TextOverflow overflow;

  const SecondaryText({
    Key? key,
    this.height = 1.2,
    this.color = const Color(0xFF89DAD2),
    required this.text,
    this.size = 12,
    this.maxLines,
    this.overflow = TextOverflow.visible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: size,
        height: height,
      ),
    );
  }
}
