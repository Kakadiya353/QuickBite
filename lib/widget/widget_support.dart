import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFieldStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle HeadLineTextFieldStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle LigthTextFieldStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle semiBoldTextFieldStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle shortTextFieldStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle inAmountFieldStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle OrderHeaderFieldStyle(BuildContext context) {
    return TextStyle(
      backgroundColor: Theme.of(context).dividerColor,
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle font(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
  }
}
