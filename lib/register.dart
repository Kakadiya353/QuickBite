import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbite/controller/login_controller.dart';
import 'package:quickbite/pages/login.dart';
import 'package:quickbite/widgets/otp_text_fields.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
                  colors: [
                    Color(0xFFff5c30),
                    Color(0xFFe74b1a),
                  ],
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
                    Center(
                      child: Image.asset(
                        "images/logofast.png",
                        width: MediaQuery.of(context).size.width / 1.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 100),

                    // Welcome text and form
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'Create Your Account !!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Name input
                        TextField(
                          keyboardType: TextInputType.text,
                          controller: ctrl.registerNameCtrl,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Your Name',
                            hintText: 'Enter Your Name',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Mobile number input
                        TextField(
                          keyboardType: TextInputType.phone,
                          controller: ctrl.registerNumberCtrl,
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

                        // OTP input
                        OtpTxtField(
                          otpController: ctrl.otpController,
                          visible: ctrl.otpFieldShown,
                          onComplete: (otp) {
                            ctrl.otpEntered = int.tryParse(otp ?? '0000');
                          },
                        ),
                        const SizedBox(height: 20),

                        // Register or Send OTP button
                        ElevatedButton(
                          onPressed: () {
                            if (ctrl.otpFieldShown) {
                              ctrl.addUser();
                            } else {
                              ctrl.sendOtp();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                          ),
                          child: Text(
                              ctrl.otpFieldShown ? 'Register' : 'Send OTP'),
                        ),
                        const SizedBox(height: 8),

                        // Navigate to Login page
                        TextButton(
                          onPressed: () {
                            Get.to(Login());
                          },
                          child: const Text('Login'),
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
