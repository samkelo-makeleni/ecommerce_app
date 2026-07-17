class Dimensions {
  // Use these methods with BuildContext to compute responsive sizes
  static double getScreenHeight(double height) => height;
  static double getScreenWidth(double width) => width;

  // Responsive dimension helpers (call with screen dimensions)
  static double getPageView(double screenHeight) => screenHeight / 2.0;
  static double getPageViewContainer(double screenHeight) =>
      screenHeight / 2.28;
  static double getPageViewTextContainer(double screenHeight) =>
      screenHeight / 3.79;
  static double getHeight10(double screenHeight) => screenHeight / 44.4;
  static double getHeight20(double screenHeight) => screenHeight / 84.4;
  static double getFont20(double screenHeight) => screenHeight / 42.4;
}
