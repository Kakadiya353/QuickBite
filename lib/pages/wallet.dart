import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickbite/pages/cart.dart';
import 'package:quickbite/widget/widget_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Details extends StatefulWidget {
  final String selectedCategory;

  const Details(this.selectedCategory, {super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int quantity = 1;
  var foodID = "";
  var foodName = "";
  var foodDetail = "";
  double price = 0.0;
  var imagepath = "";
  late String category;
  var foodImage = "";
  double totalprice = 0.0;
  var ID;
  String? userID;

  Future<void> getStoredData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    setState(() {
      foodID = sp.getString('ID') ?? 'NO DATA FOUND';
      foodName = sp.getString('Name') ?? 'NO DATA FOUND';
      foodDetail = sp.getString('Detail') ?? 'NO DATA FOUND';
      price = sp.getDouble('Price') ?? 0.0;
      ID = sp.getString('ID') ?? 'Item ID not found';
      userID = sp.getString('documentId');
      imagepath = sp.getString('ImagePath') ?? 'not found';
    });
  }

  @override
  void initState() {
    super.initState();
    category = widget.selectedCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getStoredData();
    });
    totalprice = price * quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin:
              EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0, bottom: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  getStoredData();
                },
                child: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Ensures the container is circular
                  color: Colors.black38, // Optional background color
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imagepath.isNotEmpty
                        ? imagepath
                        : "https://via.placeholder.com/150",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category == '' ? 'Ice-cream' : category,
                        style: AppWidget.semiBoldTextFieldStyle(context),
                      ),
                      SizedBox(width: 5.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          foodName,
                          style: AppWidget.boldTextFieldStyle(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (quantity > 1) {
                          quantity--;
                          totalprice = quantity * price;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(quantity.toString(),
                      style: AppWidget.semiBoldTextFieldStyle(context)),
                  SizedBox(width: 20.0),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (quantity < 10) {
                          quantity++;
                          totalprice = quantity * price;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                foodDetail,
                style: AppWidget.LigthTextFieldStyle(context),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Text('Net Price : \$${price.toStringAsFixed(2)}'),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Price",
                            style: AppWidget.semiBoldTextFieldStyle(context)),
                        Text(
                          '\$${(totalprice == 0.0 ? price : totalprice).toStringAsFixed(2)}',
                          style: AppWidget.boldTextFieldStyle(context),
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                              onTap: () async {
                                await addData();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CartScreen()),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.all(
                                    5.0), // adjust the value as needed
                                child: Text(
                                  "Add to cart",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: 18.0,
                                  ),
                                ),
                              )),
                          SizedBox(width: 30.0),
                          Icon(Icons.shopping_cart_outlined,
                              color: Colors.white),
                          SizedBox(width: 10.0),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Future<void> addData() async {
    if (totalprice == 0.0) {
      totalprice = price;
    }
    await FirebaseFirestore.instance.collection('Cart').add({
      'ImagePath': imagepath,
      'ItemCategory': category.isNotEmpty ? category : 'Ice-cream',
      'ItemID': ID,
      'NetPrice': price,
      'Quantity': quantity,
      'TotalPrice': totalprice,
      'UserID': userID
    }).then((docRef) {
      print("Document added with ID: ${docRef.id}");
    }).catchError((error) {
      print("Error adding document: $error");
    });
  }
}
