import 'package:ecommerce_app/pages/home/main_food_page.dart';
import 'package:ecommerce_app/scoped_models/food_scoped_model.dart';
import 'package:ecommerce_app/services/api_service.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService? apiService;

  const MyApp({Key? key, this.apiService}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => apiService ?? ApiService()),
        ChangeNotifierProvider(
          create: (context) => FoodScopedModel(api: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (_) {
          final svc = CartService();
          return svc;
        }),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ecommerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainFoodPage(),
      ),
    );
  }
}
