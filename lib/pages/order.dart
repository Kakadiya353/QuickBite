import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbite/controller/userID.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 4,
      ),
      body: userID == null
          ? const Center(child: CircularProgressIndicator())
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No orders found",
                      style: textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                var orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index].data() as Map<String, dynamic>;
                    var items = order['items'] as List<dynamic>;

                    return Card(
                      color: colorScheme.surface,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shopping_cart,
                                    color: colorScheme.primary, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'Order Summary',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Order ID: ${orders[index].id}',
                              style: textTheme.bodySmall?.copyWith(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const Divider(height: 24, thickness: 1),
                            Text(
                              'Items Ordered:',
                              style: textTheme.bodyLarge?.copyWith(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, itemIndex) {
                                  var item =
                                      items[itemIndex] as Map<String, dynamic>;
                                  return ListTile(
                                    leading: Icon(Icons.check_circle,
                                        color: colorScheme.primary),
                                    title: Text(
                                      item['ItemCategory'],
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Price: \$${(item['TotalPrice'] as num).toStringAsFixed(2)}',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.attach_money,
                                        color: colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total: \$${(order['TotalPrice'] as num).toStringAsFixed(2)}',
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: colorScheme.primary, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Date: ${order['Date']}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
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
              },
            ),
    );
  }
}
