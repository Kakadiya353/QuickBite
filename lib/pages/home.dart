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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            left: 10.0,
            top: 50.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello there",
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
                      margin: EdgeInsets.only(right: 20.0),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(3)),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Delicious Food",
                style: AppWidget.HeadLineTextFieldStyle(context),
              ),
              Text(
                "Discover and Get Great Food",
                style: AppWidget.LigthTextFieldStyle(context),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  margin: EdgeInsets.only(right: 20.0), child: showItem()),
              SizedBox(
                height: 30.0,
              ),
              // Ensure foodStream is not null before passing to StreamBuilder
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

                            // Navigate only after data is stored
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Details(selectedCategory)),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(25),
                              shadowColor: Colors.grey.shade100,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30.0),
                                          bottomRight: Radius.circular(30.0),
                                          topRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0)),
                                      child: CachedNetworkImage(
                                        imageUrl: data['ImagePath'],
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        height: 155.0,
                                        width: 155.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      data['Name'],
                                      style: AppWidget.semiBoldTextFieldStyle(
                                          context),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      _limitWords(data['Detail'], 12),
                                      style: AppWidget.LigthTextFieldStyle(
                                          context),
                                    ),
                                    const SizedBox(height: 5.0),
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
              SizedBox(
                height: 30.0,
              ),
              // Example for a static salad item.
              StreamBuilder(
                stream: filterStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  //Debug Logs for filtered category
                  print(
                      "Stream data for $selectedCategory: ${snapshot.data?.docs.length}");
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No food items available.'),
                    );
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
                                right: 10.0, left: 10.0, top: 15.0),
                            child: Material(
                              elevation: 5.0,
                              shadowColor: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 5.0,
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 5.0),
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
                                            Icon(Icons.error),
                                        height: 130.0,
                                        width: 130.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Text(
                                            data['Name'],
                                            style: AppWidget
                                                .semiBoldTextFieldStyle(
                                                    context),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Text(
                                            data['Detail'],
                                            style:
                                                AppWidget.LigthTextFieldStyle(
                                                    context),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: Text(
                                            "\$${data['Price'].toString()}",
                                            style: AppWidget
                                                .semiBoldTextFieldStyle(
                                                    context),
                                          ),
                                        )
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
                    fontSize: 16.0,
                    color: Colors.black,
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
