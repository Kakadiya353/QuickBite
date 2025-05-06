import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quickbite/admin/home_admin.dart';

class AdminLogin extends StatefulWidget {
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController usernameController=new TextEditingController();
  TextEditingController userPasswordController=new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFededeb),
      body: Container(
        child: Stack(
          children: [
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
              padding: EdgeInsets.only(top: 45.0, left: 20.0, right: 20.0),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 53, 51, 51), Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(
                          MediaQuery.of(context).size.width, 110.0))),
            ),
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30.0, top: 60.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Text(
                      "Let's start with\nAdmin!",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 20.0, top: 5.0, bottom: 5.0),
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 160, 160, 147)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: TextFormField(
                                  controller: usernameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please enter username';
                                    }
                                  },
                                  decoration:
                                      InputDecoration(border: InputBorder.none,
                                          hintText: "username",
                                          hintStyle: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 160, 160, 147))),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 20.0, top: 5.0, bottom: 5.0),
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 160, 160, 147)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: TextFormField(
                                  controller: userPasswordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please enter password';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "password",
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 160, 160, 147))),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.0,),
                            GestureDetector(
                              onTap: (){
                                LoginAdmin();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                margin: EdgeInsets.symmetric(horizontal: 20.0),
                                  width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color:Colors.black,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight:  FontWeight.bold
                                  ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  LoginAdmin(){
    FirebaseFirestore.instance.collection("Admin").get().then((snapshot){

      snapshot.docs.forEach((result){

        if(result.data()['id']!=usernameController.text.trim())
        {
          Get.snackbar('Error', 'your id is not correct', colorText: Colors.red);

        }
        else if(result.data()['password']!=userPasswordController.text.trim())
        {
          Get.snackbar('Error', 'your password is not correct', colorText: Colors.red);

        }
        else
          {
            Route route=MaterialPageRoute(builder: (context) => HomeAdmin(),);
            Navigator.pushReplacement(context, route);
          }
      });
    });
  }
}
