import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickbite/widget/widget_support.dart';

class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> cartItem;
  final Function(String) onDelete;
  final VoidCallback onUpdate;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int quantity;
  late double totalPrice;
  late double netPrice;

  @override
  void initState() {
    super.initState();
    quantity = widget.cartItem['Quantity'];
    netPrice = widget.cartItem['NetPrice'];
    totalPrice = widget.cartItem['TotalPrice'];
  }

  Future<String> getItemName(String category, String itemId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(category)
          .doc(itemId)
          .get();
      return doc.exists && doc['Name'] != null ? doc['Name'] : "Unknown Item";
    } catch (e) {
      return "Error loading item";
    }
  }

  void updateQuantity(bool isIncrement) async {
    int newQuantity = isIncrement ? quantity + 1 : quantity - 1;
    if (newQuantity < 1 || newQuantity > 10) return;

    double newTotalPrice = netPrice * newQuantity;

    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(widget.cartItem['docId'])
          .update({'Quantity': newQuantity, 'TotalPrice': newTotalPrice});

      setState(() {
        quantity = newQuantity;
        totalPrice = newTotalPrice;
      });

      widget.onUpdate(); // Notify parent to update total or other data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update quantity")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getItemName(
          widget.cartItem['ItemCategory'], widget.cartItem['ItemID']),
      builder: (context, itemSnapshot) {
        String itemName = itemSnapshot.data ?? "Loading...";

        return Dismissible(
          key: Key(widget.cartItem['docId']),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            widget.onDelete(widget.cartItem['docId']);
          },
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete_forever_outlined,
                color: Colors.white, size: 30),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10,
                  spreadRadius: 3,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.cartItem['ImagePath'] ?? '',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemName,
                          style: AppWidget.semiBoldTextFieldStyle(context)),
                      const SizedBox(height: 5),
                      Text(
                        'Item price: ₹${netPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => updateQuantity(false),
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => updateQuantity(true),
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
