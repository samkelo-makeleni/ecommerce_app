import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/scoped_models/food_scoped_model.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final foodModel = context.read<FoodScopedModel>();
    final items = cart.items; // Map<String,int>

    double total = 0.0;
    final entries = items.entries.toList();
    for (final e in entries) {
      final f = foodModel.getById(e.key);
      if (f != null) total += f.price * e.value;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: items.isEmpty ? null : () => _confirmClear(context),
          )
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (ctx, idx) {
                      final id = entries[idx].key;
                      final qty = entries[idx].value;
                      final f = foodModel.getById(id);
                      return ListTile(
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: Builder(builder: (ctx) {
                            final img = f?.image ?? 'assets/images/food11.jpeg';
                            final isNet = RegExp(r'^(http|https)://', caseSensitive: false).hasMatch(img);
                            if (isNet) {
                              return Image.network(img.trim(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/food11.jpeg', fit: BoxFit.cover));
                            }
                            return Image.asset(img.trim(), fit: BoxFit.cover);
                          }),
                        ),
                        title: PrimaryText(text: f?.name ?? id),
                        subtitle: SecondaryText(text: f != null ? f.description : '' , maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => context.read<CartService>().removeItem(id),
                              ),
                              Text('$qty'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => context.read<CartService>().addItem(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PrimaryText(text: 'Total: ${total.toStringAsFixed(2)}'),
                      ElevatedButton(
                        onPressed: () {
                          // placeholder checkout action
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Checkout'),
                              content: const Text('Checkout is not implemented in this demo.'),
                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Ok'))],
                            ),
                          );
                        },
                        child: const Text('Checkout'),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CartService>().clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
