import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbite/controller/userID.dart';
import 'package:quickbite/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? userID;

  @override
  void initState() {
    super.initState();
    _getUserID();
  }

  Future<void> _getUserID() async {
    String? id = await getUserId();

    setState(() {
      userID = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: userID == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Order')
                  .where("UserID", isEqualTo: userID)
                  .snapshots(includeMetadataChanges: true),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No orders found"));
                }

                var orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index].data() as Map<String, dynamic>;
                    var items = order['items'] as List<dynamic>;

                    return Card(
                      // color: const Color.fromARGB(255, 160, 160, 160),
                      color: Color(0XFFB4B4B4).withOpacity(0.4),
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              tileColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              title: Text('Order Summary',
                                  style: AppWidget.font(context)),
                              subtitle: Text('Order ID: ${orders[index].id}',
                                  style: AppWidget.font(context)),
                              leading:
                                  Text('🛒', style: TextStyle(fontSize: 25)),
                            ),
                            SizedBox(height: 16),
                            ListTile(
                              title: Text('Items Ordered',
                                  style: AppWidget.font(context)),
                              leading:
                                  Text('📦', style: TextStyle(fontSize: 20)),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 35),
                              child: Container(
                                constraints: BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: items.length,
                                  itemBuilder: (context, itemIndex) {
                                    var item = items[itemIndex]
                                        as Map<String, dynamic>;
                                    return ListTile(
                                      title: Text(item['ItemCategory']),
                                      subtitle: Text(
                                          'Price: \$${item['TotalPrice']}'),
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Price: \$${order['TotalPrice']}'),
                                Text('Order Date: ${order['Date']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
