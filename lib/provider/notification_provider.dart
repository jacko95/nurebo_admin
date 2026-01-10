import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends ChangeNotifier {

  showFlushbar(BuildContext context){
    Flushbar(
      // title: "Hey",
      // titleColor: Colors.white,
      // message: "La prestazione è stata creata con successo",

      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeIn,
      backgroundColor: Colors.black,
      // boxShadows: [
      //   BoxShadow(
      //       color: Colors.blue[800],
      //       offset: Offset(0.0, 2.0),
      //       blurRadius: 3.0
      //   )
      // ],
      // backgroundGradient: LinearGradient(
      //     colors: [
      //       Colors.blueGrey,
      //       Colors.black
      //     ]
      // ),
      isDismissible: false,
      duration: Duration(seconds: 4),
      icon: Icon(
        Icons.check,
        color: Colors.blue[500],
        size: 25,

      ),
      // mainButton: FlatButton(
      //   onPressed: () {},
      //   child: Text(
      //     "CLAP",
      //     style: TextStyle(color: Colors.amber),
      //   ),
      // ),
      // showProgressIndicator: true,
      // progressIndicatorBackgroundColor: Colors.blueGrey,
      // titleText: Text(
      //   "Hello Hero",
      //   style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20.0,
      //       color: Colors.yellow[600],
      //       fontFamily: "ShadowsIntoLightTwo"
      //   ),
      // ),
      messageText: Text(
        "La prestazione è stata aggiornata con successo",
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          // fontFamily: "ShadowsIntoLightTwo"
        ),
      ),
    ).show(context);
  }

}
