import 'package:ecommerce_app/main.dart';
import 'package:ecommerce_app/models/food.dart';
import 'package:ecommerce_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends ApiService {
  @override
  Future<List<Food>> fetchFoods({String query = ''}) async => const [
        Food(
          id: '1',
          name: 'Test Meal',
          description: 'A reliable meal for tests.',
          price: 9.99,
          image: 'assets/images/food11.jpeg',
          category: 'Test',
          area: 'Kitchen',
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows food home page and cart badge after adding an item',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiService: _FakeApiService()));
    await tester.pump();

    expect(find.text('South Africa'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Test Meal'), findsWidgets);

    await tester.ensureVisible(find.text('Add').first);
    await tester.tap(find.text('Add').first);
    await tester.pump();

    expect(find.text('1'), findsNWidgets(2));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Your Cart'), findsNothing);
    expect(find.text('Checkout'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Full name'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), '0821234567');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '123 Test Street, Pretoria',
    );

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(find.text('Order placed'), findsOneWidget);
    expect(find.textContaining('Thank you, Test User'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
