

import 'package:ecommerce_app/pages/home/food_page_body.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/pages/cart/cart_page.dart';
import 'package:ecommerce_app/scoped_models/food_scoped_model.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({ Key? key }) : super(key: key);

  @override
  _MainFoodPageState createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //showing the header
       Container(
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
             Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Center(
                   child: GestureDetector(
                     onTap: () async {
                   // show simple input dialog for search
                   final query = await showDialog<String?>(
                     context: context,
                     builder: (ctx) {
                       String q = '';
                       return AlertDialog(
                         title: const Text('Search meals'),
                         content: TextField(
                           decoration: const InputDecoration(hintText: 'Enter meal name'),
                           onChanged: (v) => q = v,
                         ),
                         actions: [
                           TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                           TextButton(onPressed: () => Navigator.of(ctx).pop(q), child: const Text('Search')),
                         ],
                       );
                     },
                   );
                   if (query != null) {
                     try {
                       // trigger search via provider
                       final model = context.read<FoodScopedModel>();
                       await model.loadFoods(query: query);
                     } catch (_) {}
                   }
                 },
                     child: Container(
                       width: 45,
                       height: 45,
                       child: const Icon(Icons.search, color: Colors.white),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(15),
                         color: AppColors.greenColor,
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 // cart icon with badge
                 Consumer<CartService>(builder: (ctx, cart, _) {
                   return GestureDetector(
                     onTap: () {
                       Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage()));
                     },
                     child: Stack(
                       clipBehavior: Clip.none,
                       children: [
                         Container(
                           width: 45,
                           height: 45,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(15),
                             color: AppColors.greenColor,
                           ),
                           child: const Icon(Icons.shopping_cart, color: Colors.white),
                         ),
                         if (cart.totalItems > 0)
                           Positioned(
                             right: -6,
                             top: -6,
                             child: Container(
                               padding: const EdgeInsets.all(4),
                               decoration: const BoxDecoration(
                                 color: Colors.red,
                                 shape: BoxShape.circle,
                               ),
                               child: Text(
                                 cart.totalItems.toString(),
                                 style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                               ),
                             ),
                           ),
                       ],
                     ),
                   );
                 })
               ],
             )
           ],
         ),
       ),
      //Showing the body
      const Expanded(
        child: SingleChildScrollView(
          child: FoodPageBody(),
        ),),
        ],),);
  }
}