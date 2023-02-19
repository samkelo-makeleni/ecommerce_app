
import 'package:ecommerce_app/pages/home/main_food_page.dart';
import 'package:flutter/material.dart';

import 'pages/food/popilar_foof_detail.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: const MainFoodPage(),
      //MainFoodPage(),
    );
  }
}

