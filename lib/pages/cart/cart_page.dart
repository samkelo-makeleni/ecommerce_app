import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/services/cart_service.dart';
import 'package:ecommerce_app/widgets/primary_text.dart';
import 'package:ecommerce_app/widgets/secondary_text.dart';

class CartPage extends StatelessWidget {
  final bool showAppBar;

  const CartPage({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final items = cart.items;
    final body = cart.isEmpty
        ? const Center(child: Text('Your cart is empty'))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, idx) {
                    final item = items[idx];
                    final food = item.food;
                    return ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: Builder(builder: (ctx) {
                          final img = food.image;
                          final isNet =
                              RegExp(r'^(http|https)://', caseSensitive: false)
                                  .hasMatch(img);
                          if (isNet) {
                            return Image.network(img.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/food11.jpeg',
                                    fit: BoxFit.cover));
                          }
                          return Image.asset(img.trim(), fit: BoxFit.cover);
                        }),
                      ),
                      title: PrimaryText(text: food.name),
                      subtitle: SecondaryText(
                          text: food.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      trailing: SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => context
                                  .read<CartService>()
                                  .removeItem(food.id),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  context.read<CartService>().addFood(food),
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
                    PrimaryText(
                        text: 'Total: ${cart.totalPrice.toStringAsFixed(2)}'),
                    ElevatedButton(
                      onPressed: () => _startCheckout(context),
                      child: const Text('Checkout'),
                    )
                  ],
                ),
              )
            ],
          );

    if (!showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: cart.isEmpty ? null : () => _confirmClear(context),
          )
        ],
      ),
      body: body,
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
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

  Future<void> _startCheckout(BuildContext context) async {
    final cart = context.read<CartService>();
    final result = await showModalBottomSheet<_CheckoutDetails>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CheckoutSheet(total: cart.totalPrice),
    );

    if (result == null) return;
    if (!context.mounted) return;

    cart.clear();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order placed'),
        content: Text(
          'Thank you, ${result.name}. Your order will be delivered to '
          '${result.address}. Payment method: ${result.paymentMethod}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _CheckoutDetails {
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;

  const _CheckoutDetails({
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
  });
}

class _CheckoutSheet extends StatefulWidget {
  final double total;

  const _CheckoutSheet({required this.total});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _paymentMethod = 'Cash on delivery';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PrimaryText(text: 'Checkout', size: 24),
              const SizedBox(height: 6),
              SecondaryText(
                text: 'Order total: ${widget.total.toStringAsFixed(2)}',
                color: Colors.black54,
                size: 14,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.length < 9) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  prefixIcon: Icon(Icons.home_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Enter a delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment method',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Cash on delivery',
                    child: Text('Cash on delivery'),
                  ),
                  DropdownMenuItem(
                    value: 'Card on delivery',
                    child: Text('Card on delivery'),
                  ),
                  DropdownMenuItem(
                    value: 'EFT',
                    child: Text('EFT'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _paymentMethod = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Place order'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _CheckoutDetails(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
      ),
    );
  }
}
