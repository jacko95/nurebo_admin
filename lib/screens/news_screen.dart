import 'dart:convert';
import 'dart:math';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class NewsScreen extends StatefulWidget {

  const NewsScreen({Key? key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

  @override
  void initState() {
    super.initState();

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    // BusinessPreferences.setBusinessLastUpdateNotification(DateTime.now());
    // BusinessPreferences.setBusinessLastOpenNotification();
    // print("init BusinessPreferences.getUserLastUpdateNotification()");
    // print(BusinessPreferences.getUserLastUpdateNotification());
    //
    // if(BusinessPreferences.getIsLogged()){
    //   () async {
    //     await socketProvider.getLocalNotifications(businessProvider.user);
    //   } ();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // BusinessPreferences.setBusinessLastUpdateNotification(DateTime.now());
    // BusinessPreferences.setUserLastClosedNotification();
    // print("dispose BusinessPreferences.getUserLastUpdateNotification()");
    // print(BusinessPreferences.getUserLastUpdateNotification());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        // leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
            // size: 22,
            size: 16,
            color: Colors.grey[500],
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Novità',
          // 'Le mie prestazioni',
          style: TextStyle(
              color: Colors.blue[500],
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .1,),
            Center(
              child: Image.asset(
                'assets/png/Saly-42.png',
                height: MediaQuery.of(context).size.height * .35,
                // width: MediaQuery.of(context).size.width * .4,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05,),
            Center(
              child: Text(
                'Attualmente non ci sono novità',
                style: TextStyle(
                  // color: Colors.blue,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
                    fontSize: 20
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
