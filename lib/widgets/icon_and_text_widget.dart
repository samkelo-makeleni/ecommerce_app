
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'package:flutter/material.dart';

class IconAndTexWidget extends StatelessWidget {

  final String text;
  final IconData icon;

  final Color iconColor;

  const IconAndTexWidget({ Key? key, 
  required this.text,
  required this.icon, 
  required this.iconColor ,
  
   }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor,),
        const SizedBox(width: 5,),
        SecondaryText(text:text,)
      ],
      
    );
  }
}