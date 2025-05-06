import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbite/controller/userID.dart';

Future<List<Map<String, dynamic>>> getCartItems() async {
  final userID = await getUserId();
  if (userID == null || userID.isEmpty) {
    return [];
  }

  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('Cart')
        .where('UserID', isEqualTo: userID)
        .get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data();
      data['docId'] = doc.id; 
      return data;
    }).toList();
  } catch (e) {
    print('Error Fetching user data: $e');
    return [];
  }
}
