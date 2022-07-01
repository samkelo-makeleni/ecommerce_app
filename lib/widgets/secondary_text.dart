import 'package:flutter/material.dart';

class SecondaryText extends StatelessWidget {
   Color ?  color;
  final String text;
  double size;
  double height;
  

 SecondaryText({ Key? key , 
 this.height= 1.2, 
 this.color = const Color(0xFF89dad20),
 required this.text,

 this.size=12,
 }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      
      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: size,
        height: height,
      ),
    );
  }
}