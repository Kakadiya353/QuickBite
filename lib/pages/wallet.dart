import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quickbite/controller/database.dart';
import 'package:quickbite/controller/userID.dart';
import 'package:quickbite/widget/widget_support.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final TextEditingController amountController = TextEditingController();
  final Database _database = Database();
  late Razorpay _razorpay;
  double availableAmount = 0.0;
  Stream<QuerySnapshot>? transactionStream;
  String userID = "";

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadUserData();
  }

  Future<void> loadUserData() async {
    userID = (await getUserId())!;
    if (userID.isNotEmpty) {
      fetchWalletBalance();
      getTransactionHistory();
    }
  }

  Future<void> fetchWalletBalance() async {
    double balance = await _database.getAvailableAmount(userID);
    setState(() => availableAmount = balance);
  }

  void getTransactionHistory() {
    setState(() {
      transactionStream = _database.getTransaction(userID);
    });
  }

  void openCheckout(String amount) {
    if (amount.isEmpty) return;
    var options = {
      'key': 'rzp_test_Wi5A0c5jiLFuJ4',
      'amount': int.parse(amount) * 100,
      'name': 'QuickBite',
      'description': 'Add Money to Wallet',
      'prefill': {'contact': '1234567890', 'email': 'test@quickbite.com'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addMoneyToWallet(String userID, int amount) async {
    if (userID.isEmpty || amount <= 0) {
      Get.snackbar('Error', 'Invalid amount!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot? walletRecord =
          await _database.getUserWalletRecord(userID);
      double newAmount = amount.toDouble();

      if (walletRecord != null && walletRecord.exists) {
        double oldAmount = walletRecord["Amount"];
        newAmount += oldAmount;
      }

      Map<String, dynamic> walletData = {
        "Amount": newAmount,
        "Date": formattedDate,
        "UserID": userID,
      };

      bool success = walletRecord != null && walletRecord.exists
          ? await _database.updateWallet(userID, walletData)
          : await _database.addWallet(walletData);

      if (success) {
        Map<String, dynamic> transactionData = {
          "Amount": amount,
          "Date": formattedDate,
          "Status": true,
          "UserID": userID,
        };

        await _database.addTransaction(transactionData);
        Get.snackbar('Success', 'Wallet updated!',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update wallet!',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    int addedAmount = int.tryParse(amountController.text) ?? 0;
    if (userID.isNotEmpty) {
      await addMoneyToWallet(userID, addedAmount);
      fetchWalletBalance();
      getTransactionHistory();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Failed', response.message!,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet Used', response.walletName!,
        backgroundColor: Colors.blue, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 105, 145, 115)),
              child: Row(
                children: [
                  Image.asset("images/wallet.png",
                      height: 60, width: 60, fit: BoxFit.cover),
                  const SizedBox(width: 40.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Wallet",
                          style: AppWidget.semiBoldTextFieldStyle(context)),
                      SizedBox(height: 5.0),
                      Text("₹$availableAmount",
                          style: AppWidget.boldTextFieldStyle(context)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text("Add money",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var amount in [100, 500, 1000, 2000])
                  GestureDetector(
                    onTap: () {
                      int currentAmount =
                          int.tryParse(amountController.text) ?? 0;
                      amountController.text =
                          (currentAmount + amount).toString();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE9E2E2)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text("₹$amount",
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter custom amount",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => openCheckout(amountController.text),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFF008080),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text("Add Money",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const Divider(height: 40.0, thickness: 3.0),
            const Text("Transaction History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No transactions yet"));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      return Column(
                        children: [
                          ListTile(
                            title: Text("₹ ${data['Amount']}"),
                            subtitle: Text(
                              data['Date'] is Timestamp
                                  ? DateFormat('yyyy-MM-dd').format(
                                      (data['Date'] as Timestamp).toDate())
                                  : "Invalid Date",
                            ),
                            trailing: Icon(
                              data['Status']
                                  ? Icons.arrow_downward_outlined
                                  : Icons.arrow_upward_outlined,
                              color: data['Status'] ? Colors.green : Colors.red,
                              size: 30.0,
                            ),
                          ),
                          if (index < snapshot.data!.docs.length - 1)
                            const Divider(), // Add Divider only if it's not the last item
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
