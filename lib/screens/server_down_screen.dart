import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ServerDownScreen extends StatefulWidget {

  const ServerDownScreen({super.key});

  @override
  _ServerDownScreenState createState() => _ServerDownScreenState();
}

class _ServerDownScreenState extends State<ServerDownScreen> {

  @override
  void initState() {
    super.initState();

    // initializeDateFormatting();
    // timeAgo.setLocale('it', timeAgo.Italian());
    // UserPreferences.setUserLastUpdateNotification(DateTime.now());
    // UserPreferences.setUserLastOpenNotification();
    // //print("init UserPreferences.getUserLastUpdateNotification()");
    // //print(UserPreferences.getUserLastUpdateNotification());
    //
    // if(UserPreferences.getIsLogged()){
    //   () async {
    //     await socketProvider.getLocalNotifications(userProvider.user);
    //   } ();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // UserPreferences.setUserLastUpdateNotification(DateTime.now());
    // UserPreferences.setUserLastClosedNotification();
    // //print("dispose UserPreferences.getUserLastUpdateNotification()");
    // //print(UserPreferences.getUserLastUpdateNotification());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   titleSpacing: 0,
      //   // leadingWidth: 40,
      //   leading: IconButton(
      //     icon: Icon(
      //       // Icons.arrow_back,
      //       Icons.arrow_back_ios_new,
      //       // size: 22,
      //       size: 16,
      //       color: Colors.grey[500],
      //     ),
      //     onPressed: (){
      //       Navigator.pop(context);
      //     },
      //   ),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   elevation: 0,
      //   title: Text(
      //     'Novità',
      //     // 'Le mie prestazioni',
      //     style: TextStyle(
      //         color: Colors.blue,
      //         // color: Colors.grey[800],
      //         fontWeight: FontWeight.w600,
      //         fontSize: 15
      //     ),
      //   ),
      // ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .2,),
            Center(
              child: Image.asset(
                'assets/png/vecteezy_server-down-illustration-3d_12596918.png',
                height: MediaQuery.of(context).size.height * .35,
                // width: MediaQuery.of(context).size.width * .4,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .02,),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * .8,
                child: Text(
                  'Stiamo aggiornando i nostri server.\nRiprova più tardi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: Colors.blue,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w700,
                      fontSize: 20
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
