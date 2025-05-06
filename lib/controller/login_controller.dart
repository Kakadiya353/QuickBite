import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:quickbite/pages/bottomnav.dart';
import 'package:quickbite/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user/user.dart';

class LoginController extends GetxController {
  final GetStorage box = GetStorage();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference userCollection;

  final TextEditingController registerNameCtrl = TextEditingController();
  final TextEditingController registerNumberCtrl = TextEditingController();
  final TextEditingController loginNumberCtrl = TextEditingController();

  final OtpFieldControllerV2 otpController = OtpFieldControllerV2();
  bool otpFieldShown = false;
  int? otpSend;
  int? otpEntered;
  User? loginUser;

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void onInit() {
    userCollection = firestore.collection('users');
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    Map<String, dynamic>? user = box.read('loginUser');
    if (user != null) {
      loginUser = User.fromJson(user);
      Get.offAll(() => BottomNav());
    } else {
      print('No user found in storage.');
    }
  }

  Future<User?> getCurrentUserDetails() async {
    try {
      Map<String, dynamic>? userData = box.read('loginUser');
      if (userData != null) {
        return User.fromJson(userData);
      }

      firebase_auth.User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        var querySnapshot = await userCollection
            .where('email', isEqualTo: firebaseUser.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = querySnapshot.docs.first;
          var userData = userDoc.data() as Map<String, dynamic>;
          return User.fromJson(userData);
        }
      }

      return null;
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
      return null;
    }
  }

  bool validateFields({required String name, required String number}) {
    if (name.isEmpty || number.isEmpty) {
      Get.snackbar('Error', 'Please fill the fields', colorText: Colors.red);
      return false;
    }
    return true;
  }

  Future<void> sendOtp() async {
    try {
      if (!validateFields(
          name: registerNameCtrl.text, number: registerNumberCtrl.text)) return;

      final random = Random();
      int otp = 1000 + random.nextInt(9000);
      String mobileNo = registerNumberCtrl.text;
      String url =
          'https://www.fast2sms.com/dev/bulkV2?authorization=F2bIC8NEGmY60fKAyPajgBrwq3RzvJTeOo7hHZdinuS5cQD1p9aR01L5739Kfesim4jwNPJVuypkqUvZ&route=otp&variables_values=$otp&flash=0&numbers=$mobileNo';

      Response response = await GetConnect().get(url);

      if (response.body != null &&
          response.body['message']?[0] == 'SMS sent successfully.') {
        otpFieldShown = true;
        otpSend = otp;
        Get.snackbar('Success', 'OTP sent successfully',
            colorText: Colors.green);
      } else {
        Get.snackbar('Error', 'OTP not sent', colorText: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
    } finally {
      update();
    }
  }

  void addUser() {
    try {
      if (otpSend == null || otpSend != otpEntered) {
        Get.snackbar('Error', 'OTP is incorrect', colorText: Colors.red);
        return;
      }

      if (!validateFields(
          name: registerNameCtrl.text, number: registerNumberCtrl.text)) return;

      DocumentReference doc = userCollection.doc();
      User user = User(
        id: doc.id,
        name: registerNameCtrl.text,
        number: int.parse(registerNumberCtrl.text),
      );

      doc.set(user.toJson());
      box.write('loginUser', user.toJson());

      Get.snackbar('Success', 'User added successfully',
          colorText: Colors.green);

      registerNumberCtrl.clear();
      registerNameCtrl.clear();
      otpController.clear();

      Get.offAll(() => BottomNav());
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
    }
  }

  Future<void> loginWithPhone() async {
    try {
      String phoneNo = loginNumberCtrl.text;
      if (phoneNo.isEmpty) {
        Get.snackbar('Error', 'Please enter your phone number',
            colorText: Colors.red);
        return;
      }

      var querySnapshot = await userCollection
          .where('number', isEqualTo: int.tryParse(phoneNo))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        var userData = userDoc.data() as Map<String, dynamic>;

        // Store the document ID in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('documentId', userDoc.id);

        // // Wait and then retrieve the document ID
        // String? documentId = prefs.getString('documentId');
        // if (documentId != null) {
        //   print("Document ID: $documentId"); // This should print in the console
        // } else {
        //   print("Document ID not found.");
        // }

        box.write('loginUser', userData);

        loginNumberCtrl.clear();
        Get.offAll(() => BottomNav());
        Get.snackbar('Success', 'Login Successful', colorText: Colors.green);
      } else {
        Get.snackbar('Error', 'User not found, please register',
            colorText: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar('Error', 'Google sign-in canceled', colorText: Colors.red);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        var querySnapshot = await userCollection
            .where('email', isEqualTo: firebaseUser.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          DocumentReference doc = userCollection.doc();
          User user = User(
            email: firebaseUser.email!,
            id: doc.id,
            name: firebaseUser.displayName ?? "Unnamed",
            number: null,
          );
          await doc.set(user.toJson());
        }

        box.write('loginUser', {
          'name': firebaseUser.displayName,
          'email': firebaseUser.email,
        });

        Get.offAll(() => BottomNav());

        Get.snackbar('Success', 'Google Sign-In Successful',
            colorText: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
    }
  }

  void logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      box.remove('loginUser');
      Get.offAll(() => Login());
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e', colorText: Colors.red);
    }
  }
}
