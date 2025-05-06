import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickbite/pages/bottomnav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cartScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? userID; // Nullable userID

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  Future<void> getUserID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      userID = sp.getString('documentId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return userID == null
        ? Center(
            child:
                CircularProgressIndicator()) // Show loading until userID is fetched
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Cart')
                .where('UserID',
                    isEqualTo:
                        userID) // Directly use document ID for efficiency
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return EmptyCartScreen();
              }
              return MyCartScreen();
            },
          );
  }
}

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => BottomNav()),
              (route) => false, // Removes all previous routes
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Your cart looks empty 😔',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Looks like you haven\'t added anything yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => BottomNav()),
                  (route) => false, // Removes all previous routes
                );
              },
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              label: Text("Continue Shopping"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                // Changed to blue for better visibility
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
