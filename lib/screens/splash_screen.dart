import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key,});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/png/JszLY0VHmd34O0wH4dfS.png",
              height: 60,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.width * 0.15,
            right: MediaQuery.of(context).size.width * 0.5 - 15,
            height: 30,
            width: 30,
            // child: const CupertinoActivityIndicator(radius: 15),
            child: CircularProgressIndicator(color: Colors.blue[400]),
          )
        ],
      )
    );
  }
}
