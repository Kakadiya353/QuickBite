import 'dart:math' as math; // Alias dart:math as "math"

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickbite/controller/CartItemWidget.dart';
import 'package:quickbite/controller/database.dart';
import 'package:quickbite/controller/userID.dart';
import 'package:quickbite/pages/bottomnav.dart';

import '../controller/getCartItems.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final CollectionReference _addresses =
      FirebaseFirestore.instance.collection('Addresses');
  String _newAddress = "";

  final CollectionReference _carts =
      FirebaseFirestore.instance.collection('Cart');
  late Future<List<Map<String, dynamic>>> cartItems;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    _refreshCartItems();
  }

  void _refreshCartItems() {
    if (!mounted) return;
    setState(() {
      cartItems = getCartItems();
    });
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

  void updateQuantity(String docId, int currentQuantity, double netPrice,
      bool isIncrement) async {
    int newQuantity = isIncrement ? currentQuantity + 1 : currentQuantity - 1;
    if (newQuantity < 1 || newQuantity > 10) return;

    double newTotalPrice = netPrice * newQuantity;

    try {
      await _carts
          .doc(docId)
          .update({'Quantity': newQuantity, 'TotalPrice': newTotalPrice});
      _refreshCartItems();
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to update quantity.");
      }
    }
  }

  Future<void> _deleteCartItem(String docId) async {
    try {
      await _carts.doc(docId).delete();
      _refreshCartItems();
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to delete item.");
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showOrderDialog(String userId) async {
    final db = Database();
    double totalPrice = await db.calculateTotalPrice(userId);
    DocumentSnapshot? walletRecord = await db.getUserWalletRecord(userId);

    if (!mounted) return;

    if (totalPrice == 0.0) {
      _showSnackBar("Your cart is empty!");
      return;
    }

    double walletBalance = walletRecord?["Amount"] ?? 0.0;

    Map<String, dynamic> transactionData = {
      "Amount": totalPrice,
      "Date": formattedDate,
      "Status": false,
      "UserID": userId,
    };

    if (walletBalance < totalPrice) {
      _showSnackBar("Insufficient balance. Redirecting to Wallet...");
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNav()),
          );
        }
      });
      return;
    }

    if (!mounted) return;

    // Fetch existing address if available
    DocumentSnapshot? addressRecord = await _addresses.doc(userId).get();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Order"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Current Balance: ",
                      style: TextStyle(fontSize: 15)),
                  Text('₹${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text("Total Price: ₹${totalPrice.toStringAsFixed(2)}"),
              const SizedBox(height: 12),
              const Text("Are you sure you want to place this order?"),
              const SizedBox(height: 12),
              // Show address input if no address is stored yet
              TextField(
                decoration: InputDecoration(
                  labelText: addressRecord != null && addressRecord.exists
                      ? "Current Address"
                      : "Enter Address",
                  hintText: addressRecord != null && addressRecord.exists
                      ? addressRecord['Address']
                      : "Enter your delivery address",
                ),
                onChanged: (address) {
                  // Update the address as the user types
                  setState(() {
                    _newAddress = address;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // List of different messages
                List<String> messages = [
                  'Hungry?😚 Buy some delicious food!',
                  'Craving something tasty? Order now!',
                  'Feeling hungry? Enjoy some delicious meals!',
                  'Get your favorite food now and satisfy your hunger!',
                  'Treat yourself to a yummy meal today!',
                  'Order now and indulge in delicious food!'
                ];

                // Randomly select a message from the list
                final random = math.Random(); // Correct use of math.Random
                int randomIndex =
                    random.nextInt(messages.length); // Correct method call
                String randomMessage =
                    messages[randomIndex]; // Get the random message

                // Show the selected message using your notification method
                notification('Hungry?😚', randomMessage);
                print(
                    "-----------------------------Random index: $randomIndex");
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isProcessingOrder
                  ? null
                  : () async {
                      if (!mounted) return;
                      setState(() {
                        isProcessingOrder = true;
                      });
                      Navigator.of(dialogContext).pop();

                      // Update or add address for the user
                      if (_newAddress.isNotEmpty) {
                        // Add or update address in Firestore
                        try {
                          await _addresses.doc(userId).set({
                            'Address': _newAddress,
                            'UserID': userId,
                            'UpdatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                        } catch (e) {
                          _showSnackBar("Failed to update address.");
                        }
                      }

                      // Proceed with order
                      try {
                        await db.moveCartToOrder(userId, totalPrice);
                        await db.updateTotalPrice(userId, totalPrice);
                        await db.addTransaction(transactionData);
                        _refreshCartItems();

                        _showSnackBar("Order placed successfully!",
                            isSuccess: true);
                        notification('Yuppi!!🤤', 'order has been placed');
                      } catch (e) {
                        _showSnackBar("Order failed.");
                        notification(
                            'Sorry!!😫😓', 'order can\'t be processed');
                      } finally {
                        if (mounted) {
                          setState(() {
                            isProcessingOrder = false;
                          });
                        }
                      }
                    },
              child: isProcessingOrder
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      floatingActionButton: ElevatedButton.icon(
        onPressed: isProcessingOrder
            ? null
            : () async {
                String? userID = await getUserId();
                if (userID != null && userID.isNotEmpty) {
                  _showOrderDialog(userID);
                } else {
                  _showSnackBar("User ID not found.");
                }
              },
        icon: const Icon(Icons.shopping_cart_checkout,
            size: 24, color: Colors.white),
        label:
            const Text("Proceed to Checkout", style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          List<Map<String, dynamic>> cartList = snapshot.data!;

          return ListView.builder(
            itemCount: cartList.length,
            itemBuilder: (context, index) {
              var cartItem = cartList[index];
              return CartItemWidget(
                cartItem: cartItem,
                onDelete: (docId) {
                  _deleteCartItem(docId);
                },
                onUpdate: () {
                  _refreshCartItems(); // optional if you want to recalculate total price
                },
              );
            },
          );
        },
      ),
    );
  }

  void notification(String s, String t) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'Basic_channel_v2',
        title: s,
        body: t,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
