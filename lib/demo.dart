// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:quickbite/controller/database.dart';
// import 'package:quickbite/widget/widget_support.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Wallet extends StatefulWidget {
//   const Wallet({super.key});

//   @override
//   State<Wallet> createState() => _WalletState();
// }

// class _WalletState extends State<Wallet> {
//   late double availableAmount;

//   Stream<QuerySnapshot>? getTransaction;

//   late Razorpay _razorpay;
//   TextEditingController amountController = TextEditingController();
//   int walletBalance = 100; // Initial wallet balance

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     availableAmount = 0.0; // Initialize with 0

//     getUserID().then((_) {
//       fetchWalletBalance();
//       listenToWalletChanges(
//           userID); // Fetch wallet balance after getting userID
//       getTransDetails(userID);
//     });
//   }

//   void getTransDetails(String userID) {
//     setState(() {
//       getTransaction = Database().getTransaction(userID);
//     });
//   }

//   void listenToWalletChanges(String userID) {
//     FirebaseFirestore.instance
//         .collection('Wallet')
//         .where("UserID", isEqualTo: userID) // Match by UserID field
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         var data = snapshot.docs.first.data() as Map<String, dynamic>;
//         double newBalance = (data["Amount"] ?? 0.0).toDouble();
//         setState(() {
//           availableAmount = newBalance; // Update balance in real-time
//         });
//       }
//     });
//   }

//   Future<void> fetchWalletBalance() async {
//     if (userID.isNotEmpty) {
//       try {
//         double balance = await Database().getAvailableAmount(userID);
//         setState(() {
//           availableAmount = balance; // Update UI
//         });
//       } catch (e) {
//         print("Error fetching wallet balance: $e");
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   var userID = "";

//   //String amount,String userid,String data,bool status
//   Future<void> getUserID() async {
//     final SharedPreferences sp = await SharedPreferences.getInstance();
//     userID = sp.getString("documentId") ?? "";
//   }

//   uploaddata(String userid, bool status, String date, String amount) async {
//     try {
//       DocumentSnapshot? walletRecord =
//           await Database().getUserWalletRecord(userid);

//       double newAmount = double.parse(amount);
//       bool isFirstTransaction = walletRecord == null;

//       if (!isFirstTransaction) {
//         double oldAmount = walletRecord["Amount"];
//         newAmount += oldAmount;
//       }

//       Map<String, dynamic> params = {
//         "Amount": newAmount,
//         "Date": date,
//         "Status": true,
//         "History": isFirstTransaction, // true if first transaction, else false
//         "UserID": userid,
//       };

//       bool success;
//       if (isFirstTransaction) {
//         // If first transaction, create a new record
//         success = await Database().addwallet(params);
//       } else {
//         // If record exists, update the amount in Firestore
//         success = await Database().updateWallet(userid, params);
//       }

//       if (success) {
//         setState(() {
//           availableAmount = newAmount; // Update UI balance
//         });
//         Get.snackbar(
//           'Success',
//           'The wallet has been updated successfully!',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           duration: Duration(seconds: 3),
//         );
//       } else {
//         Get.snackbar(
//           'Error',
//           'Oops! Something went wrong. Please try again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           duration: Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       print("Error while adding data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         margin: EdgeInsets.only(top: 60.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Material(
//               elevation: 2.0,
//               child: Container(
//                 padding: EdgeInsets.only(bottom: 10.0),
//                 child: Center(
//                   child: Text(
//                     "Wallet",
//                     style: AppWidget.HeadLineTextFieldStyle(),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 30.0),
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
//               child: Row(
//                 children: [
//                   Image.asset(
//                     "images/wallet.png",
//                     height: 60,
//                     width: 60,
//                     fit: BoxFit.cover,
//                   ),
//                   SizedBox(width: 40.0),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Your Wallet",
//                           style: AppWidget.LigthTextFieldStyle()),
//                       SizedBox(height: 5.0),
//                       Text("\$${availableAmount}",
//                           style: AppWidget.boldTextFieldStyle()),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(height: 20.0),
//             Padding(
//               padding: const EdgeInsets.only(left: 20.0),
//               child:
//                   Text("Add money", style: AppWidget.semiBoldTextFieldStyle()),
//             ),
//             SizedBox(height: 10.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 for (var amount in [100, 500, 1000, 2000])
//                   GestureDetector(
//                     onTap: () {
//                       int currentAmount =
//                           int.tryParse(amountController.text) ?? 0;
//                       amountController.text =
//                           (currentAmount + amount).toString();
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Color(0xFFE9E2E2)),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Text("\$$amount",
//                           style: AppWidget.semiBoldTextFieldStyle()),
//                     ),
//                   ),
//               ],
//             ),
//             SizedBox(height: 20.0),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: TextField(
//                 controller: amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Enter custom amount",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.0),
//             GestureDetector(
//               onTap: () => openCheckout(amountController.text),
//               child: Container(
//                 margin: EdgeInsets.symmetric(horizontal: 20.0),
//                 padding: EdgeInsets.symmetric(vertical: 12.0),
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: Color(0xFF008080),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Add Money",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.0,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Divider(
//               height: 40.0,
//               thickness: 3.0,
//             ),
//             StreamBuilder<QuerySnapshot>(
//                 stream: getTransaction,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text("No Transaction found!"));
//                   }
//                   return Expanded(
//                     child: ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> trans = snapshot.data!.docs[index]
//                             .data() as Map<String, dynamic>;

//                         return Card(
//                           elevation: 5.0,
//                           margin: EdgeInsets.symmetric(
//                               vertical: 8.0, horizontal: 10.0),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.all(15.0),
//                             title: Text(
//                               "₹${trans['Amount']}",
//                               style: AppWidget.inAmountFieldStyle(),
//                             ),
//                             subtitle: Text(
//                               trans['Date'],
//                               style: AppWidget.inAmountFieldStyle(),
//                             ),
//                             trailing: Icon(
//                               trans['Status'] == true
//                                   ? Icons.arrow_downward_outlined
//                                   : Icons.arrow_upward_outlined,
//                               color: trans['Status'] == true
//                                   ? Colors.green
//                                   : Colors.red,
//                               size: 30.0,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 }),
//           ],
//         ),
//       ),
//     );
//   }

//   void openCheckout(String amount) {
//     if (amount.isEmpty) return;

//     var options = {
//       'key': 'rzp_test_Wi5A0c5jiLFuJ4', // Replace with your Razorpay API key
//       'amount':
//           (int.parse(amount) * 100), // Convert to the smallest currency unit
//       'name': 'QuickBite',
//       'description': 'Add Money to Wallet',
//       'prefill': {'contact': '1234567890', 'email': 'test@quickbite.com'},
//       'external': {
//         'wallets': ['paytm']
//       }
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     int addedAmount = int.tryParse(amountController.text) ?? 0;
//     String formattedDate =
//         DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//     await getUserID();
//     setState(() {
//       walletBalance += addedAmount;

//       amountController.clear();
//     });
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Row(
//           children: const [
//             Icon(Icons.check_circle, color: Colors.green),
//             SizedBox(width: 10),
//             Text("Payment Successful"),
//           ],
//         ),
//       ),
//     );
//     if (userID.isNotEmpty) {
//       // Ensure userID is valid before storing data
//       await uploaddata(userID, true, formattedDate, addedAmount.toString());
//       getTransDetails(userID);
//     } else {
//       debugPrint("UserID is empty, data not uploaded");
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text("Payment Failed: ${response.message}"),
//       ),
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text("External Wallet: ${response.walletName}"),
//       ),
//     );
//   }
// }
