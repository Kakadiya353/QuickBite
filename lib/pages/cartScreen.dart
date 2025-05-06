import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickbite/controller/database.dart';
import 'package:quickbite/controller/userID.dart';
import 'package:quickbite/pages/bottomnav.dart';
import 'package:intl/intl.dart';
import 'package:quickbite/widget/widget_support.dart';
import '../controller/getCartItems.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  late Future<List<Map<String, dynamic>>> cartItems;
  double? totalPrice;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    cartItems = getCartItems();
  }

  Future<String> getItemName(String category, String itemId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(category)
          .doc(itemId)
          .get();
      if (doc.exists) {
        return doc['Name'];
      } else {
        return "Unknown Item";
      }
    } catch (e) {
      return "Error";
    }
  }

  void updateQuantity(String docId, int currentQuantity, double netPrice,
      bool isIncrement) async {
    int newQuantity = isIncrement ? currentQuantity + 1 : currentQuantity - 1;

    if (newQuantity < 1 || newQuantity > 10) return;

    double newTotalPrice = netPrice * newQuantity;

    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(docId)
          .update({'Quantity': newQuantity, 'TotalPrice': newTotalPrice});

      setState(() {
        cartItems = getCartItems();
      });
    } catch (e) {
      print("Error updating quantity: $e");
    }
  }

  void _showOrderDialog(BuildContext context, String userId) async {
    print("Opening Order Dialog..."); // Debugging
    final db = Database();

    double totalPrice = await db.calculateTotalPrice(userId);
    DocumentSnapshot? walletRecord = await db.getUserWalletRecord(userId);

    if (totalPrice == 0.0) {
      _showSnackBar(context, "Your cart is empty!");
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
      _showSnackBar(context, "Insufficient balance. Redirecting to Wallet...");

      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNav()),
          );
        }
      });
      return;
    }

    if (!context.mounted) return;

    print("Displaying confirmation dialog...");

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
                      style: TextStyle(fontSize: 15.0)),
                  Text('₹${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold))
                ],
              ),
              const SizedBox(height: 8),
              Text("Total Price: ₹${totalPrice.toStringAsFixed(2)}"),
              const SizedBox(height: 12),
              const Text("Are you sure you want to place this order?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await db.moveCartToOrder(userId, totalPrice);
                await db.updateTotalPrice(userId, totalPrice);
                await db.addTransaction(transactionData);
                if (context.mounted) {
                  _showSnackBar(context, "Order placed successfully!",
                      isSuccess: true);
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          print("Proceed to Checkout button clicked!"); // Debugging

          String? userID = await getUserId();
          if (userID != null && userID.isNotEmpty) {
            _showOrderDialog(context, userID);
          } else {
            print("Error: User ID is null or empty");
          }
        },
        icon: Icon(Icons.shopping_cart_checkout, size: 24, color: Colors.white),
        label: Text("Proceed to Checkout", style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your cart is Empty'));
          }

          List<Map<String, dynamic>> cartList = snapshot.data!;

          return ListView.builder(
            itemCount: cartList.length,
            itemBuilder: (context, index) {
              var cartItem = cartList[index];
              return Padding(
                padding:
                    const EdgeInsets.only(top: 15.0, right: 10.0, left: 10.0),
                child: FutureBuilder<String>(
                  future:
                      getItemName(cartItem['ItemCategory'], cartItem['ItemID']),
                  builder: (context, itemSnapshot) {
                    String itemName =
                        itemSnapshot.data ?? "Loading..."; // Default text

                    return Container(
                      height: MediaQuery.of(context).size.height / 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            spreadRadius: 3,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: cartItem['ImagePath'] ?? '',
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              height: 80.0,
                              width: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  itemName, // Display item name instead of ID
                                  style:
                                      AppWidget.semiBoldTextFieldStyle(context),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Item net price: \$${cartItem['NetPrice']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${cartItem['TotalPrice'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      updateQuantity(
                                          cartItem['docId'],
                                          cartItem['Quantity'],
                                          cartItem['NetPrice'],
                                          false);
                                    },
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Colors.red),
                                  ),
                                  Text(
                                    '${cartItem['Quantity']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      updateQuantity(
                                          cartItem['docId'],
                                          cartItem['Quantity'],
                                          cartItem['NetPrice'],
                                          true);
                                    },
                                    icon: Icon(Icons.add_circle_outline,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
