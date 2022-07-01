import 'package:flutter/material.dart';

class AppColors {
  
  static const Color appVerticalLineGreen =  Color(0xff4EA800);
  static const Color secondaryText = Color.fromARGB(255, 0, 131, 194);
  static const Color pinkColor =  Color(0xffd91d66);
  static const Color greenColor = Color.fromRGBO(78, 168, 0, 1);
  static const Color whiteColor =  Color(0xffffffff);
  static const Color lightGreyColorV2 =
      Color.fromRGBO(244, 244, 244, 1);
  static const Color yellowTextColor =  Color(0xffF1B434);
  static const Color telkomRedColor = Color.fromRGBO(213, 0, 50, 1);
  static Color formColor = HexColor("#0083C2");
  static Color headerColor = HexColor("#0083C2");
}
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
