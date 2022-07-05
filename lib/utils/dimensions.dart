
import 'package:get/get.dart';
class Dimensions {
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double pageView = screenHeight/2.0;
//current screen size = 683.43/ container height  = 300
  static double pageViewContainer = screenHeight/2.28;
//current screen size 683.43/container height = 180
  static double pageViewTextContainer = screenHeight/3.79;

//between containers
  static double height10 = screenHeight/44.4;
  static double height20 = screenHeight/84.4;

  //font size

   static double font20 = screenHeight/42.4;

}