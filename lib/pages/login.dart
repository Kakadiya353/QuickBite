import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbite/controller/login_controller.dart';
import 'package:quickbite/register.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (ctrl) {
      return Scaffold(
        body: Stack(
          children: [
            // Top gradient background
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFff5c30), Color(0xFFe74b1a)],
                ),
              ),
            ),

            // Bottom white container
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3,
              ),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 30.0),
                child: Column(
                  children: [
                    // Logo
                    ClipRRect(
                      child: Center(
                        child: Image.asset(
                          "images/logofast.png",
                          width: MediaQuery.of(context).size.width / 1.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),

                    // Welcome text and form
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Mobile number input
                        TextField(
                          controller: ctrl.loginNumberCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.phone_android),
                            labelText: 'Mobile Number',
                            hintText: 'Enter Your mobile number',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        ElevatedButton(
                          onPressed: () {
                            ctrl.loginWithPhone();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 8),

                        // Google sign-in button
                        GestureDetector(
                          onTap: () {
                            ctrl.loginWithGoogle();
                          },
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login, // Placeholder for Google icon
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register new account
                        TextButton(
                          onPressed: () {
                            Get.to(Register());
                          },
                          child: const Text('Register new account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
