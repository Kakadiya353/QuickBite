import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getUserId() async {
  final sp = await SharedPreferences.getInstance();
  return await sp.getString('documentId');
}
