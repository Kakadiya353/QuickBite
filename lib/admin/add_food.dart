import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbite/admin/home_admin.dart';
import 'package:quickbite/controller/database.dart';

class AddFood extends StatefulWidget {
  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> categories = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? selectedCategory;

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController imagePathController =
      TextEditingController(); // Changed from ImageUrl

  uploadItem() async {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        detailController.text.isNotEmpty &&
        imagePathController.text.isNotEmpty &&
        selectedCategory != null) {
      Map<String, dynamic> foodItem = {
        "Name": nameController.text,
        "Price": double.parse(priceController.text), // Storing as String
        "Detail": detailController.text,
        "ImagePath": imagePathController.text,
      };

      // Store in Firestore under the category-based collection
      bool success = await Database().addItem(selectedCategory!, foodItem);

      if (success) {
        Get.snackbar('Success', 'Food item has been added successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Failed to add food item',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'Please fill all fields',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Food Item"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeAdmin()));
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Item Name"),
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(border: OutlineInputBorder())),
              SizedBox(height: 20),
              Text("Item Price"),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              Text("Item Detail"),
              TextField(
                  controller: detailController,
                  maxLines: 4,
                  decoration: InputDecoration(border: OutlineInputBorder())),
              SizedBox(height: 20),
              Text("Image Path"),
              TextField(
                  controller: imagePathController,
                  decoration: InputDecoration(border: OutlineInputBorder())),
              SizedBox(height: 20),
              Text("Item Category"),
              DropdownButton<String>(
                isExpanded: true,
                items: categories
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                hint: Text("Select Category"),
                value: selectedCategory,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: uploadItem,
                  child: Text("Add Item"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
