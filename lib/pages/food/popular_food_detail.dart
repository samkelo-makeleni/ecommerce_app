import 'package:ecommerce_app/models/food.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/widgets/icon_and_text_widget.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopularFoodDetail extends StatelessWidget {
  final Food food;

  const PopularFoodDetail({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.greenColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(food.name),
              background: _FoodImage(image: food.image),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(text: food.name, size: 26),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconAndTexWidget(
                        text: food.category ?? 'Meal',
                        icon: Icons.circle_sharp,
                        iconColor: AppColors.yellowTextColor,
                      ),
                      IconAndTexWidget(
                        text: food.area ?? 'Kitchen',
                        icon: Icons.location_on,
                        iconColor: AppColors.greenColor,
                      ),
                      IconAndTexWidget(
                        text: food.price.toStringAsFixed(2),
                        icon: Icons.attach_money,
                        iconColor: AppColors.greenColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (food.tags != null && food.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: food.tags!
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: AppColors.lightGreyColorV2,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 20),
                  const PrimaryText(text: 'Description'),
                  const SizedBox(height: 10),
                  SecondaryText(
                    text: food.description.isEmpty
                        ? 'No description available.'
                        : food.description,
                    color: Colors.black54,
                    size: 14,
                    height: 1.45,
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => context.read<CartService>().addFood(food),
            icon: const Icon(Icons.add_shopping_cart),
            label: Text('Add to cart - ${food.price.toStringAsFixed(2)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodImage extends StatelessWidget {
  final String image;

  const _FoodImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final trimmed = image.trim();
    final isNetwork =
        RegExp(r'^(http|https)://', caseSensitive: false).hasMatch(trimmed);

    if (isNetwork) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetFallback(),
      );
    }

    return Image.asset(trimmed, fit: BoxFit.cover);
  }

  Widget _assetFallback() => Image.asset(
        'assets/images/food11.jpeg',
        fit: BoxFit.cover,
      );
}
