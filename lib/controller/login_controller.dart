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
      showCustomSnackBar(
        title: 'Error',
        message: e.toString(),
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return null;
    }
  }

  bool validateFields({required String name, required String number}) {
    if (name.isEmpty || number.isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please fill the fields',
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
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
        showCustomSnackBar(
          title: 'Success',
          message: 'OTP sent successfully',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        showCustomSnackBar(
          title: 'Error',
          message: 'OTP not sent',
          icon: Icons.error,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: e.toString(),
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    } finally {
      update();
    }
  }

  void addUser() {
    try {
      if (otpSend == null || otpSend != otpEntered) {
        showCustomSnackBar(
          title: 'Error',
          message: 'OTP is incorrect',
          icon: Icons.error,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
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

      showCustomSnackBar(
        title: 'Success',
        message: 'User added successfully',
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      registerNumberCtrl.clear();
      registerNameCtrl.clear();
      otpController.clear();

      Get.offAll(() => BottomNav());
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: e.toString(),
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> loginWithPhone() async {
    try {
      String phoneNo = loginNumberCtrl.text;
      if (phoneNo.isEmpty) {
        showCustomSnackBar(
          title: 'Error',
          message: 'Please enter your phone number',
          icon: Icons.error,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
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

        box.write('loginUser', userData);

        loginNumberCtrl.clear();
        Get.offAll(() => BottomNav());
        showCustomSnackBar(
          title: 'Success',
          message: 'Login Successful',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        showCustomSnackBar(
          title: 'Error',
          message: 'User not found, please register',
          icon: Icons.error,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: e.toString(),
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        showCustomSnackBar(
          title: 'Oops!',
          message: 'Google sign-in was canceled.',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          duration: Duration(seconds: 4),
        );
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
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('documentId', doc.id);
        } else {
          // If the user exists, log their document ID
          print(
              'User already exists with document ID: ${querySnapshot.docs.first.id}');

          // You can still store the existing document ID in SharedPreferences if you want
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('documentId', querySnapshot.docs.first.id);
        }
        box.write('loginUser', {
          'name': firebaseUser.displayName,
          'email': firebaseUser.email,
        });

        Get.offAll(() => BottomNav());

        showCustomSnackBar(
          title: 'Success',
          message: 'Google Sign-In Successful',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: e.toString(),
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  void logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      box.remove('loginUser');
      Get.offAll(() => Login());
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Logout failed: $e',
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  void showCustomSnackBar({
    required String title,
    required String message,
    IconData? icon,
    Color backgroundColor = Colors.redAccent,
    Color textColor = Colors.white,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      overlayBlur: 1.5,
      overlayColor: Colors.black.withOpacity(0.2),
    );
  }
}
