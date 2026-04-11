import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void errorToast(String message) {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 12.0);
}

void successToast(String message) {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 12.0);
}

void warningToast(String message) {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.amber, textColor: Colors.black, fontSize: 12.0);
}
