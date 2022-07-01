import 'dart:ffi';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/widgets/icon_and_text_widget.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'package:flutter/material.dart';

class FoodPageBody extends StatefulWidget {
  const FoodPageBody({Key? key}) : super(key: key);

  @override
  _FoodPageBodyState createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currentPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = 220;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          child: PageView.builder(
              controller: pageController,
              itemCount: 5,
              itemBuilder: (context, position) {
                return _buildPageItem(
                  position,
                );
              }),
        ),
        //Dots
        DotsIndicator(
          dotsCount: 5,
          position: _currentPageValue,
          decorator: DotsDecorator(
            //color: AppColors.greenColor,
            activeColor: AppColors.greenColor,
            size: const Size.square(9.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildPageItem(int index) {
    Matrix4 matrix = Matrix4.identity();
    //this is true for the current index
    if (index == _currentPageValue.floor()) {
      var currScale = 1 - (_currentPageValue - index) * (1 - _scaleFactor);
      //Slide tranformation
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(
        1,
        currScale,
        1,
      )..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currentPageValue.floor() + 1) {
      //first index
      var currScale =
          _scaleFactor + (_currentPageValue - index + 1) * (1 - _scaleFactor);
      //Slide tranformation
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(
        1,
        currScale,
        1,
      );
      matrix = Matrix4.diagonal3Values(
        1,
        currScale,
        1,
      )..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currentPageValue.floor() - 1) {
      //first index
      var currScale = 1 - (_currentPageValue - index) * (1 - _scaleFactor);
      // //Slide tranformation
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(
        1,
        currScale,
        1,
      );
      matrix = Matrix4.diagonal3Values(
        1,
        currScale,
        1,
      )..setTranslationRaw(0, currTrans, 0);
    } else {
      //third slide
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(
        1,
        currScale,
        1,
      )..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 0);
    }

    return Transform(
      transform: matrix,
      child: Stack(children: [
        Container(
          height: 180,
          margin: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: index.isEven
                  ? const Color(0xFF69c5df)
                  : const Color(0xFF9294cc),
              image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/food11.jpeg"))),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 120,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFe8e8e8),
                    blurRadius: 5.0,
                    offset: Offset(0, 5),
                  )
                ]),
            child: Container(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(text: "Chinese Side"),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Wrap(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            color: AppColors.greenColor,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SecondaryText(text: "4.5"),
                      const SizedBox(
                        width: 25,
                      ),
                      SecondaryText(text: "22892"),
                      const SizedBox(
                        width: 25,
                      ),
                      SecondaryText(text: "Comments"),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      IconAndTexWidget(
                        text: "Normal",
                        icon: Icons.circle_sharp,
                        iconColor: AppColors.yellowTextColor,
                      ),
                      // SizedBox(
                      //   width: 25,
                      // ),
                      IconAndTexWidget(
                        text: "2.2km",
                        icon: Icons.location_on,
                        iconColor: AppColors.greenColor,
                      ),
                      // SizedBox(
                      //   width: 25,
                      // ),
                      IconAndTexWidget(
                        text: "30min",
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.yellowTextColor,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
