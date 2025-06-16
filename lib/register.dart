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
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GetBuilder<LoginController>(builder: (ctrl) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                children: [
                  // Top gradient background with logo
                  Container(
                    width: screenWidth,
                    height: screenHeight * 0.35,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFff5c30), Color(0xFFe74b1a)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        "images/logofast.png",
                        width: screenWidth * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Register title
                  Text(
                    'Create Your Account !!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Name input
                        TextField(
                          controller: ctrl.registerNameCtrl,
                          keyboardType: TextInputType.text,
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.person,
                                color: theme.colorScheme.primary),
                            labelText: 'Your Name',
                            labelStyle:
                                TextStyle(color: theme.colorScheme.primary),
                            hintText: 'Enter Your Name',
                            hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Mobile number input
                        TextField(
                          controller: ctrl.registerNumberCtrl,
                          keyboardType: TextInputType.phone,
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.phone_android,
                                color: theme.colorScheme.primary),
                            labelText: 'Mobile Number',
                            labelStyle:
                                TextStyle(color: theme.colorScheme.primary),
                            hintText: 'Enter Your Mobile Number',
                            hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6)),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (ctrl.otpFieldShown) {
                                ctrl.addUser();
                              } else {
                                ctrl.sendOtp();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                                ctrl.otpFieldShown ? 'Register' : 'Send OTP'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Navigate to Login page
                        TextButton(
                          onPressed: () {
                            Get.to(Login());
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
