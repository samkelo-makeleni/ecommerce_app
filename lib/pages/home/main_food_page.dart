import 'package:ecommerce_app/pages/home/food_page_body.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/pages/cart/cart_page.dart';
import 'package:ecommerce_app/scoped_models/food_scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({Key? key}) : super(key: key);

  @override
  _MainFoodPageState createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  static const _locationPrefsKey = 'selected_location';
  static const _locations = [
    _SouthAfricanLocation(city: 'Pretoria', province: 'Gauteng'),
    _SouthAfricanLocation(city: 'Johannesburg', province: 'Gauteng'),
    _SouthAfricanLocation(city: 'Cape Town', province: 'Western Cape'),
    _SouthAfricanLocation(city: 'Durban', province: 'KwaZulu-Natal'),
    _SouthAfricanLocation(city: 'Bloemfontein', province: 'Free State'),
    _SouthAfricanLocation(city: 'Gqeberha', province: 'Eastern Cape'),
    _SouthAfricanLocation(city: 'East London', province: 'Eastern Cape'),
    _SouthAfricanLocation(city: 'Kimberley', province: 'Northern Cape'),
    _SouthAfricanLocation(city: 'Polokwane', province: 'Limpopo'),
    _SouthAfricanLocation(city: 'Mbombela', province: 'Mpumalanga'),
    _SouthAfricanLocation(city: 'Mahikeng', province: 'North West'),
    _SouthAfricanLocation(city: 'Pietermaritzburg', province: 'KwaZulu-Natal'),
  ];

  int _selectedIndex = 0;
  String _selectedLocation = 'Pretoria';

  @override
  void initState() {
    super.initState();
    _loadSelectedLocation();
  }

  Future<void> _loadSelectedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final location = prefs.getString(_locationPrefsKey);
      if (!mounted || location == null) return;
      setState(() {
        _selectedLocation = location;
      });
    } catch (e) {
      debugPrint('Unable to load selected location: $e');
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _selectLocation() async {
    final selected = await showModalBottomSheet<_SouthAfricanLocation>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _LocationPickerSheet(
          locations: _locations,
          selectedLocation: _selectedLocation,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      _selectedLocation = selected.city;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationPrefsKey, selected.city);
    } catch (e) {
      debugPrint('Unable to save selected location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(
            selectedLocation: _selectedLocation,
            onLocationTap: _selectLocation,
            onCartTap: () => _selectTab(1),
          ),
          const CartPage(showAppBar: false),
          const _PlaceholderTab(
            icon: Icons.favorite_border,
            title: 'Favorites',
            message: 'Saved meals will appear here.',
          ),
          const _PlaceholderTab(
            icon: Icons.person_outline,
            title: 'Profile',
            message: 'Profile details will appear here.',
          ),
        ],
      ),
      bottomNavigationBar: Consumer<CartService>(
        builder: (context, cart, _) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _selectTab,
            selectedItemColor: AppColors.greenColor,
            unselectedItemColor: Colors.black45,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _CartNavIcon(count: cart.totalItems),
                activeIcon: _CartNavIcon(
                  count: cart.totalItems,
                  isActive: true,
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String selectedLocation;
  final VoidCallback onLocationTap;
  final VoidCallback onCartTap;

  const _HomeTab({
    required this.selectedLocation,
    required this.onLocationTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //showing the header
        Container(
          margin: const EdgeInsets.only(top: 45, bottom: 15),
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onLocationTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PrimaryText(
                        text: "South Africa",
                        color: AppColors.greenColor,
                        size: 30,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SecondaryText(
                            text: selectedLocation,
                            color: Colors.black54,
                          ),
                          const Icon(Icons.arrow_drop_down_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final query = await showDialog<String?>(
                          context: context,
                          builder: (ctx) {
                            String q = '';
                            return AlertDialog(
                              title: const Text('Search meals'),
                              content: TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Enter meal name'),
                                onChanged: (v) => q = v,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(q),
                                    child: const Text('Search')),
                              ],
                            );
                          },
                        );
                        if (query != null) {
                          try {
                            final model = context.read<FoodScopedModel>();
                            await model.loadFoods(query: query);
                          } catch (e) {
                            debugPrint('Unable to search meals: $e');
                          }
                        }
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.greenColor,
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<CartService>(builder: (ctx, cart, _) {
                    return GestureDetector(
                      onTap: onCartTap,
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
                            child: const Icon(Icons.shopping_cart,
                                color: Colors.white),
                          ),
                          if (cart.totalItems > 0)
                            _Badge(
                              count: cart.totalItems,
                              right: -6,
                              top: -6,
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
        const Expanded(
          child: SingleChildScrollView(
            child: FoodPageBody(),
          ),
        ),
      ],
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  final int count;
  final bool isActive;

  const _CartNavIcon({
    required this.count,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (count > 0) _Badge(count: count, right: -10, top: -8),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final double right;
  final double top;

  const _Badge({
    required this.count,
    required this.right,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      top: top,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SouthAfricanLocation {
  final String city;
  final String province;

  const _SouthAfricanLocation({
    required this.city,
    required this.province,
  });
}

class _LocationPickerSheet extends StatelessWidget {
  final List<_SouthAfricanLocation> locations;
  final String selectedLocation;

  const _LocationPickerSheet({
    required this.locations,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: PrimaryText(
                text: 'Choose Location',
                size: 22,
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: locations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final location = locations[index];
                final isSelected = location.city == selectedLocation;

                return ListTile(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: isSelected ? AppColors.greenColor : Colors.black45,
                  ),
                  title: Text(location.city),
                  subtitle: Text(location.province),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.greenColor)
                      : null,
                  onTap: () => Navigator.of(context).pop(location),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.greenColor),
            const SizedBox(height: 12),
            PrimaryText(text: title, size: 24),
            const SizedBox(height: 8),
            SecondaryText(
              text: message,
              color: Colors.black54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
