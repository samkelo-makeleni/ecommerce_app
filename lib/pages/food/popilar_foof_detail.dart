import 'package:flutter/material.dart';

class PopularFoodDetail extends StatelessWidget {
  const PopularFoodDetail({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0, right: 0,
            child: Container(
            width: double.maxFinite,
            height: 350,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/food11.jpeg"),
              )
            ),
          ),
          ),
        ],
      ),
      
    );
  }
}