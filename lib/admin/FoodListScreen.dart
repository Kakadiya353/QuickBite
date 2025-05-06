import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbite/controller/database.dart';

class ShowFood extends StatefulWidget {
  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  final Database db = Database();
  final List<String> categories = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Food Items"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: categories.map((category) {
            return StreamBuilder<QuerySnapshot>(
              stream: db.getItems(category), // Fetching category-wise
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("No items in $category"),
                  );
                }

                final foodItems = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        category,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        var food = foodItems[index];
                        var foodData = food.data() as Map<String, dynamic>;

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            leading: SizedBox(
                              width: 50, // Set a fixed width
                              height: 50, // Set a fixed height
                              child: Image.network(
                                foodData['ImagePath'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "images/food.jpg",
                                    // Ensure this image exists in your assets folder
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            title: Text(foodData['Name'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("₹${foodData['Price']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditDialog(
                                        context, category, food.id, foodData);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteDialog(
                                        context, category, food.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 🔹 Edit Dialog
  void _showEditDialog(BuildContext context, String category, String foodId,
      Map<String, dynamic> foodData) {
    TextEditingController nameController =
        TextEditingController(text: foodData['Name']);
    TextEditingController priceController =
        TextEditingController(text: foodData['Price'].toString());
    TextEditingController detailController =
        TextEditingController(text: foodData['Detail']);
    TextEditingController imagePathController =
        TextEditingController(text: foodData['ImagePath']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Food Item"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Item Name")),
                TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: "Item Price"),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: detailController,
                    decoration: InputDecoration(labelText: "Item Detail")),
                TextField(
                    controller: imagePathController,
                    decoration: InputDecoration(labelText: "Image URL")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    detailController.text.isNotEmpty &&
                    imagePathController.text.isNotEmpty) {
                  Map<String, dynamic> updatedData = {
                    "Name": nameController.text,
                    "Price": double.tryParse(priceController.text) ?? 0.0,
                    "Detail": detailController.text,
                    "ImagePath": imagePathController.text,
                  };

                  bool success =
                      await db.updateItem(category, foodId, updatedData);
                  if (success) {
                    Get.snackbar("Success", "Item updated",
                        backgroundColor: Colors.green, colorText: Colors.white);
                  } else {
                    Get.snackbar("Error", "Update failed",
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Delete Confirmation Dialog
  void _showDeleteDialog(BuildContext context, String category, String foodId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Confirmation"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await db.deleteItem(category, foodId);
                if (success) {
                  Get.snackbar("Success", "Item deleted",
                      backgroundColor: Colors.green, colorText: Colors.white);
                } else {
                  Get.snackbar("Error", "Delete failed",
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
                Navigator.pop(context);
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
