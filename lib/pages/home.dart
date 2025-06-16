import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickbite/controller/database.dart';
import 'package:quickbite/pages/details.dart';
import 'package:quickbite/widget/widget_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = "Ice-cream";
  Stream<QuerySnapshot>? foodStream;
  Stream<QuerySnapshot>? filterStream;
  var categoryList = "Ice-cream";

  void updateCategory(String category) {
    Stream<QuerySnapshot> newStream;
    Stream<QuerySnapshot> newFilterStream;

    if (category == "Ice-cream") {
      newStream = Database().getIceCreamDetails();
      newFilterStream = Database().getFilteredOfIceCreamDetails();
    } else if (category == "Pizza") {
      newStream = Database().getPizzaDetails();
      newFilterStream = Database().getFilteredOfPizzaDetails();
    } else if (category == "Salad") {
      newStream = Database().getSaladDetails();
      newFilterStream = Database().getFilteredOfSaladDetails();
    } else if (category == "Burger") {
      newStream = Database().getBurgerDetails();
      newFilterStream = Database().getFilteredOfBurgerDetails();
    } else {
      newStream =
          FirebaseFirestore.instance.collection("Ice-cream").snapshots();
      newFilterStream =
          FirebaseFirestore.instance.collection("Ice-cream").snapshots();
    }

    setState(() {
      categoryList = category;
      selectedCategory = category;
      foodStream = newStream;
      filterStream = newFilterStream;
    });
  }

  @override
  void initState() {
    super.initState();
    updateCategory(selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
              left: screenWidth * 0.03, top: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello, there",
                    style: AppWidget.boldTextFieldStyle(context),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return CartScreen();
                          }));
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: screenWidth * 0.05),
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Delicious Food",
                style: AppWidget.HeadLineTextFieldStyle(context),
              ),
              Text(
                "Discover and Get Great Food",
                style: AppWidget.LigthTextFieldStyle(context),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                margin: EdgeInsets.only(right: screenWidth * 0.05),
                child: showItem(),
              ),
              SizedBox(height: screenHeight * 0.05),
              StreamBuilder<QuerySnapshot>(
                stream: foodStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No food items available."));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () async {
                            await detailsget(
                              data['ImagePath'],
                              data['Name'],
                              data['Detail'],
                              (data['Price'] as num).toDouble(),
                              doc.id,
                              selectedCategory,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Details(selectedCategory)),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(screenWidth * 0.03),
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(25),
                              shadowColor: Colors.grey.shade100,
                              color: theme.cardColor,
                              child: Container(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      // Rounded corners for a cleaner look
                                      child: CachedNetworkImage(
                                        imageUrl: data['ImagePath'],
                                        placeholder: (context, url) =>
                                            Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.error,
                                              color: theme.colorScheme.error,
                                            ),
                                        height: screenHeight * 0.15,
                                        // Adjust the height to be more proportionate
                                        width: screenWidth * 0.3,
                                        // Adjust the width for a balanced look
                                        fit: BoxFit
                                            .cover, // Maintain aspect ratio while covering the container
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      data['Name'],
                                      style: AppWidget.semiBoldTextFieldStyle(
                                          context),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      _limitWords(data['Detail'], 12),
                                      style: AppWidget.LigthTextFieldStyle(
                                          context),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      "\$${data['Price'].toString()}",
                                      style: AppWidget.shortTextFieldStyle(
                                          context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.05),
              StreamBuilder(
                stream: filterStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No food items available.'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () async {
                            await detailsget(
                                data['ImagePath'],
                                data['Name'],
                                data['Detail'],
                                (data['Price'] as num).toDouble(),
                                doc.id,
                                selectedCategory);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return Details(selectedCategory);
                                }));
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                right: screenWidth * 0.03,
                                left: screenWidth * 0.03,
                                top: screenHeight * 0.02),
                            child: Material(
                              elevation: 5.0,
                              shadowColor: Colors.grey.shade100,
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(80),
                                      child: CachedNetworkImage(
                                        imageUrl: data['ImagePath'] ?? '',
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error,
                                                color: theme.colorScheme.error),
                                        height: screenHeight * 0.17,
                                        width: screenWidth * 0.4,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.05),
                                    Column(
                                      children: [
                                        Container(
                                          width: screenWidth * 0.4,
                                          child: Text(
                                            data['Name'],
                                            style: AppWidget
                                                .semiBoldTextFieldStyle(
                                                context),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.02),
                                        Container(
                                          width: screenWidth * 0.4,
                                          child: Text(
                                            data['Detail'],
                                            style:
                                            AppWidget.LigthTextFieldStyle(
                                                context),
                                          ),
                                        ),
                                        Container(
                                          width: screenWidth * 0.4,
                                          child: Text(
                                            "\$${data['Price'].toString()}",
                                            style: AppWidget
                                                .semiBoldTextFieldStyle(
                                                context),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              Center(
                child: Text(
                  "© QuickBite",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    color: theme.textTheme.bodySmall!.color,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            updateCategory("Ice-cream");
          },
          child: categoryButton("images/ice-cream.png", "Ice-cream"),
        ),
        GestureDetector(
          onTap: () {
            updateCategory("Pizza");
          },
          child: categoryButton("images/pizza.png", "Pizza"),
        ),
        GestureDetector(
          onTap: () {
            updateCategory("Salad");
          },
          child: categoryButton("images/salad.png", "Salad"),
        ),
        GestureDetector(
          onTap: () {
            updateCategory("Burger");
          },
          child: categoryButton("images/burger.png", "Burger"),
        ),
      ],
    );
  }

  Widget categoryButton(String image, String category) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
            color: selectedCategory == category ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(10),
        child: Image.asset(
          image,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          color: selectedCategory == category ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  String _limitWords(String text, int wordLimit) {
    List<String> words = text.split(''); // Split the text into words
    return words.length > wordLimit
        ? words.take(wordLimit).join(' ') +
        '...' // Limit to 20 words and add ellipsis
        : text; // If less than 20 words, return the text as is
  }

  Future<void> detailsget(String ImagePath, String name, String detail,
      double price, String id, String category) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString('ID', id);
    await sp.setString('Name', name);
    await sp.setString('ImagePath', ImagePath);
    await sp.setString('Detail', detail);
    await sp.setDouble('Price', price);
    await sp.setString('Category', category);

    print(
        "✅ Data Stored: $name, $detail, $price, $id, $category,$ImagePath"); // Debug log
  }
}
