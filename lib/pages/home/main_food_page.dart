

import 'package:ecommerce_app/pages/home/food_page_body.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'package:flutter/material.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({ Key? key }) : super(key: key);

  @override
  _MainFoodPageState createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  @override
  Widget build(BuildContext context) {
    //Check current device height
    print("current hieght is " + MediaQuery.of(context).size.height.toString());
    return Scaffold(
      body: Column(
        children: [
          //showing the header
       Container(
        child: Container(
          margin: const EdgeInsets.only(top: 45, bottom: 15),
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Column(
                children:  [
                 PrimaryText(
                   text: "South Africa", 
                 color: AppColors.greenColor, size: 30 , ),
                 Row(
                   children: [
                   SecondaryText(
                     text: "Pretoria", color: Colors.black54,),
                    const Icon(Icons.arrow_drop_down_rounded),
                   ],
                 ),
                ],
              ),
              Center(
                child: Container(
                  width: 45,
                  height: 45,
                  child: const Icon(Icons.search, color: Colors.white,),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.greenColor ),
                ),
              )
            ],
          ),
        )
      ),
      //Showing the body
      const Expanded(
        child: SingleChildScrollView(
          child: FoodPageBody(),
        ),),
        ],),);
  }
}