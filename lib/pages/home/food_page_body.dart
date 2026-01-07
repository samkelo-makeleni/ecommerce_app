import 'package:dots_indicator/dots_indicator.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/widgets/icon_and_text_widget.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/scoped_models/food_scoped_model.dart';
import 'package:ecommerce_app/models/food.dart';
import 'package:ecommerce_app/services/cart_service.dart';

class FoodPageBody extends StatefulWidget {
  const FoodPageBody({Key? key}) : super(key: key);

  @override
  _FoodPageBodyState createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currentPageValue = 0.0;
  final double _scaleFactor = 0.8;
  final double _height = 220;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPageValue = pageController.page!;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load foods once the widget tree is built and providers are available
      try {
        context.read<FoodScopedModel>().loadFoods();
      } catch (_) {
        // ignore if provider not available during tests
      }
      // start auto sliding after first frame
      _startAutoSlide();
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      // ensure the PageController has an attached PageView before attempting to animate
      if (!pageController.hasClients) return;

      final foodModel = context.read<FoodScopedModel>();
      final pageCount = foodModel.items.isEmpty ? 5 : foodModel.items.length;

      // determine current page (fallback to 0)
      final double? page = pageController.page;
      int current = page != null ? page.round() : 0;
      // clamp current to valid range
      if (current < 0) current = 0;
      if (current >= pageCount) current = pageCount - 1;

      int next = current + 1;
      if (next >= pageCount) next = 0;

      // animate only when controller is attached
      if (pageController.hasClients) {
        try {
          await pageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        } catch (_) {
          // ignore animation errors
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Slider section (uses API-provided images when available)
        Builder(builder: (ctx) {
          final foodModel = context.watch<FoodScopedModel>();
          final sliderItems = foodModel.items;
          final count = sliderItems.isEmpty ? 5 : sliderItems.length;
          return Container(
            height: 300,
            child: PageView.builder(
              controller: pageController,
              itemCount: count,
              itemBuilder: (context, position) {
                final Food? f = (sliderItems.isNotEmpty && position < sliderItems.length) ? sliderItems[position] : null;
                return _buildPageItem(position, food: f);
              },
            ),
          );
        }),
        //Dots
        Builder(builder: (ctx) {
          // compute dots count (max 5) and ensure position < dotsCount to satisfy DotsIndicator
          final rawCount = context.watch<FoodScopedModel>().items.isEmpty ? 5 : context.watch<FoodScopedModel>().items.length;
          final dotsCount = rawCount > 5 ? 5 : rawCount;
          final double pos = _currentPageValue;
          // clamp position to be strictly less than dotsCount
          final double safePosition = pos < dotsCount ? pos : (dotsCount - 0.0001);
          return DotsIndicator(
            dotsCount: dotsCount,
            position: safePosition,
            decorator: DotsDecorator(
              //color: AppColors.greenColor,
              activeColor: AppColors.greenColor,
              //size: const Size.square(9.0),
              //activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          );
        }),
        //popular text
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: const PrimaryText(text: "Popular"),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 3),
                child: const PrimaryText(
                  text: ".",
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: const SecondaryText(
                    text: "Food pairing",
                  ),
                ),
              ),
            ],
          ),
        ),
        // List of food and images (from provider)
        Container(
          // allow the list to size itself inside the outer scroll view
          child: Builder(builder: (context) {
            final foodModel = context.watch<FoodScopedModel>();
            final cart = context.read<CartService>();
            final items = foodModel.items;
            if (foodModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (foodModel.error != null) {
              return Center(child: Text('Error: ${foodModel.error}'));
            }
            if (items.isEmpty) {
              return const Center(child: Text('No results'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
                itemBuilder: (context, index) {
                  final food = items[index];
                  return Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Row(
                      children: [
                        // image container (supports network URLs and local assets)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white38,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: RegExp(r'^(http|https)://', caseSensitive: false).hasMatch(food.image)
                                ? Image.network(
                                    food.image.trim(),
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      // fallback to bundled placeholder if network image fails
                                      return Image.asset(
                                        'assets/images/food11.jpeg',
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    food.image.trim(),
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            // let content determine height so lines can wrap without overflow
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PrimaryText(text: food.name),
                                  const SizedBox(height: 10),
                                  // limit description to avoid overflow inside the card
                                  SecondaryText(text: food.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const IconAndTexWidget(
                                        text: "Normal",
                                        icon: Icons.circle_sharp,
                                        iconColor: AppColors.yellowTextColor,
                                      ),
                                      IconAndTexWidget(
                                        text: "${food.price.toStringAsFixed(2)}",
                                        icon: Icons.attach_money,
                                        iconColor: AppColors.greenColor,
                                      ),
                                      ElevatedButton(
                                        onPressed: () => cart.addItem(food.id),
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
          }),
        )
      ],
    );
  }

  Widget _buildPageItem(int index, {Food? food}) {
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
      child: Stack(
        children: [
          // background image: API image when available, otherwise placeholder asset
          Container(
            height: 180,
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Builder(builder: (_) {
                final img = food?.image ?? 'assets/images/food11.jpeg';
                final isNet = RegExp(r'^(http|https)://', caseSensitive: false).hasMatch(img);
                if (isNet) {
                  return Image.network(
                    img.trim(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/food11.jpeg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 180,
                    ),
                  );
                }
                return Image.asset(
                  img.trim(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                );
              }),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
            ),
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
                  PrimaryText(text: food?.name ?? 'Featured'),
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
                          const SecondaryText(text: "4.5"),
                      const SizedBox(
                        width: 25,
                      ),
                          const SecondaryText(text: "22892"),
                      const SizedBox(
                        width: 25,
                      ),
                          const SecondaryText(text: "Comments"),
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
                    
                      IconAndTexWidget(
                        text: "2.2km",
                        icon: Icons.location_on,
                        iconColor: AppColors.greenColor,
                      ),
                      
                      IconAndTexWidget(
                        text: "30min",
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.yellowTextColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
