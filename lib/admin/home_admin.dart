import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quickbite/admin/FoodListScreen.dart';
import 'package:quickbite/admin/add_food.dart';
import 'package:quickbite/admin/admin_login.dart';
import 'package:quickbite/pages/login.dart';

class HomeAdmin extends StatefulWidget {
  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home Admin",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                GetStorage box = GetStorage();
                box.erase();
                Get.offAll(AdminLogin());
              },
              icon: Icon(
                Icons.logout,
                color: Colors.blueGrey,
              ))
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddFood(),));
                  },
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Image.asset(
                                "images/food.jpg",
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              'Add food items',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFood(),));
                  },
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Image.asset(
                                "images/food.jpg",
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              'Manage food items',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
