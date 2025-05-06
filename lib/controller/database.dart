import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a new document to the specified collection
  Future<bool> addItem(String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
      return true; // Success
    } catch (e) {
      debugPrint("Error adding item : $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getItems(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Update Item
  Future<bool> updateItem(
      String collection, String docId, Map<String, dynamic> newData) async {
    try {
      await _firestore.collection(collection).doc(docId).update(newData);
      return true;
    } catch (e) {
      print("Error updating item: $e");
      return false;
    }
  }

  // Delete Item
  Future<bool> deleteItem(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      print("Error deleting item: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getIceCreamDetails() {
    return FirebaseFirestore.instance
        .collection("Ice-cream")
        .where("Price", isLessThan: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getPizzaDetails() {
    return FirebaseFirestore.instance
        .collection("Pizza")
        .where("Price", isLessThan: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getSaladDetails() {
    return FirebaseFirestore.instance
        .collection("Salad")
        .where("Price", isLessThan: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getBurgerDetails() {
    return FirebaseFirestore.instance
        .collection("Burger")
        .where("Price", isLessThan: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getFilteredOfIceCreamDetails() {
    return FirebaseFirestore.instance
        .collection('Ice-cream')
        .where("Price", isGreaterThanOrEqualTo: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getFilteredOfPizzaDetails() {
    return FirebaseFirestore.instance
        .collection('Pizza')
        .where("Price", isGreaterThanOrEqualTo: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getFilteredOfSaladDetails() {
    return FirebaseFirestore.instance
        .collection('Salad')
        .where("Price", isGreaterThanOrEqualTo: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getFilteredOfBurgerDetails() {
    return FirebaseFirestore.instance
        .collection('Burger')
        .where("Price", isGreaterThanOrEqualTo: 10)
        .snapshots();
  }

  Future<bool> updateTotalPrice(String userid, double totalPrice) async {
    try {
      var querySnapshot = await _firestore
          .collection("Wallet")
          .where("UserID", isEqualTo: userid)
          .limit(1) // Get only one matching record
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        double currentAmount = querySnapshot.docs.first["Amount"] ?? 0.0;

        if (currentAmount < totalPrice) {
          debugPrint("Insufficient balance");
          return false; // Not enough funds
        }

        double newAmount = currentAmount - totalPrice; // Deduct the amount

        await _firestore.collection("Wallet").doc(docId).update({
          "Amount": newAmount,
        });

        return true; // Update successful
      }
      return false; // Wallet not found
    } catch (e) {
      debugPrint("Wallet update failed: $e");
      return false;
    }
  }

  Future<void> moveCartToOrder(String userid, double totalPrice) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference cartCollection = firestore.collection("Cart");
    CollectionReference orderCollection = firestore.collection("Order");

    try {
      QuerySnapshot cartSnapshot =
          await cartCollection.where('UserID', isEqualTo: userid).get();

      if (cartSnapshot.docs.isEmpty) {
        print("No items in cart");
        return;
      }

      List<Map<String, dynamic>> cartItems = [];

      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
        cartItems.add(itemData);
        totalPrice += (itemData["Price"] as num?)?.toDouble() ?? 0.0;
      }

      await orderCollection.add({
        'UserID': userid,
        'items': cartItems,
        'TotalPrice': totalPrice,
        'Date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'Status': false,
      });

      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        await cartCollection.doc(doc.id).delete();
      }
      print('Order placed successfully, cart items deleted!');
    } catch (e) {
      print("Error moving cart to order: $e");
    }
  }

  Future<double> calculateTotalPrice(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference cartCollection = firestore.collection("Cart");

    double totalPrice = 0.0;

    try {
      QuerySnapshot cartSnapshot =
          await cartCollection.where('UserID', isEqualTo: userId).get();

      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
        totalPrice += (itemData["TotalPrice"] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      print("Error calculating total price: $e");
    }

    return totalPrice;
  }

  Stream<QuerySnapshot> getOrdersData(String userID) {
    return FirebaseFirestore.instance
        .collection('Order')
        .where("UserID", isEqualTo: userID)
        .snapshots();
  }

  //Wallet

  // Get user's wallet document

  // // Fetch available wallet balance
  // Future<double> getAvailableAmount(String userID) async {
  //   try {
  //     var doc = await _firestore.collection('Wallet').doc(userID).get();
  //     return doc.exists ? (doc["Amount"] ?? 0.0).toDouble() : 0.0;
  //   } catch (e) {
  //     print("Error fetching wallet balance: $e");
  //     return 0.0;
  //   }
  // }

  // Add a new wallet record
  // Future<bool> addWallet(Map<String, dynamic> walletData) async {
  //   try {
  //     await _firestore
  //         .collection('Wallet')
  //         .doc(walletData["UserID"])
  //         .set(walletData);
  //     return true;
  //   } catch (e) {
  //     print("Error adding wallet: $e");
  //     return false;
  //   }
  // }

  // // Update existing wallet balance
  // Future<bool> updateWallet(
  //     String userID, Map<String, dynamic> walletData) async {
  //   try {
  //     await _firestore.collection('Wallet').doc(userID).update(walletData);
  //     return true;
  //   } catch (e) {
  //     print("Error updating wallet: $e");
  //     return false;
  //   }
  // }

  // // Add a transaction
  // Future<void> addTransaction(Map<String, dynamic> transactionData) async {
  //   try {
  //     await _firestore.collection('Transaction').add(transactionData);
  //   } catch (e) {
  //     print("Error adding transaction: $e");
  //   }
  // }

  // Get transaction history
  // Stream<QuerySnapshot> getTransaction(String userID) {
  //   return _firestore
  //       .collection('Transaction')
  //       .where("UserID", isEqualTo: userID)
  //       .orderBy("Date", descending: true)
  //       .snapshots();
  // }

  // Stream<QuerySnapshot> getTransaction(String userId) {
  //   return FirebaseFirestore.instance
  //       .collection('transactions')
  //       .where('userId', isEqualTo: userId)
  //       .orderBy('date', descending: true)
  //       .snapshots();
  // }

  // Future<bool> updateWallet(String userid, Map<String, dynamic> data) async {
  //   try {
  //     var querySnapshot = await _firestore
  //         .collection("Wallet")
  //         .where("UserID", isEqualTo: userid)
  //         .limit(1) // Get only one matching record
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       await _firestore
  //           .collection("Wallet")
  //           .doc(querySnapshot.docs.first.id)
  //           .update(data);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     debugPrint("Wallet update failed: $e");
  //     return false;
  //   }
  // }

  //   Future<bool> addwallet(Map<String, dynamic> data) async {
  //   try {
  //     await _firestore.collection("Wallet").add(data);
  //     return true;
  //   } catch (e) {
  //     debugPrint("Wallet add failed : $e");
  //     return false;
  //   }
  // }

  //  Future<DocumentSnapshot?> getUserWalletRecord(String userid) async {
  //   try {
  //     var querySnapshot = await _firestore
  //         .collection("Wallet")
  //         .where("UserID", isEqualTo: userid)
  //         .limit(1) // Fetch only one record
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       return querySnapshot.docs.first; // Return existing wallet record
  //     } else {
  //       return null; // No record found
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching wallet record: $e");
  //     return null;
  //   }
  // }

  // Future<double> getAvailableAmount(String userid) async {
  //   try {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('Wallet')
  //         .where("UserID", isEqualTo: userid)
  //         .limit(1)
  //         .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       var data = snapshot.docs.first.data() as Map<String, dynamic>;
  //       return (data["Amount"] as num?)?.toDouble() ??
  //           0.0; // Ensure it's a number
  //     } else {
  //       return 0.0;
  //     }
  //   } catch (e) {
  //     print("Error fetching wallet amount: $e");
  //     return 0.0;
  //   }
  // }

  // Fetch wallet balance based on UserID (NOT Doc ID)
  Future<double> getAvailableAmount(String userID) async {
    QuerySnapshot walletSnapshot = await _firestore
        .collection('Wallet')
        .where('UserID', isEqualTo: userID)
        .get();

    if (walletSnapshot.docs.isNotEmpty) {
      return walletSnapshot.docs.first['Amount'].toDouble();
    }
    return 0.0;
  }

  // Get wallet document based on UserID
  Future<DocumentSnapshot?> getUserWalletRecord(String userID) async {
    QuerySnapshot walletSnapshot = await _firestore
        .collection('Wallet')
        .where('UserID', isEqualTo: userID)
        .get();

    if (walletSnapshot.docs.isNotEmpty) {
      return walletSnapshot.docs.first;
    }
    return null;
  }

  // Update wallet amount based on UserID
  Future<bool> updateWallet(
      String userID, Map<String, dynamic> walletData) async {
    QuerySnapshot walletSnapshot = await _firestore
        .collection('Wallet')
        .where('UserID', isEqualTo: userID)
        .get();

    if (walletSnapshot.docs.isNotEmpty) {
      String docID = walletSnapshot.docs.first.id; // Get existing document ID
      await _firestore.collection('Wallet').doc(docID).update(walletData);
      return true;
    }
    return false;
  }

  Future<bool> addWallet(Map<String, dynamic> walletData) async {
    try {
      await _firestore.collection('Wallet').add(walletData);
      return true;
    } catch (e) {
      print("Error adding wallet: $e");
      return false;
    }
  }

  // Fetch transactions for a specific user
  Stream<QuerySnapshot> getTransaction(String userID) {
    return _firestore
        .collection('Transaction')
        .where('UserID', isEqualTo: userID)
        .orderBy('Date', descending: true) // Order by Date (latest first)
        .snapshots();
  }

  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    transactionData['Date'] = FieldValue.serverTimestamp();
    await _firestore.collection('Transaction').add(transactionData);
  }
}
