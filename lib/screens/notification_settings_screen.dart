import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';


class NotificationSettingsScreen extends StatefulWidget {
  // final Business business;

  const NotificationSettingsScreen({super.key/*, this.business*/});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool? isEnabled;
  bool? isBackground;
  bool? isVibrate;
  bool? isSilent;
  bool? isEmailNotification;
  bool? isChatNotification;
  SocketProvider? socketProvider;
  late BusinessProvider businessProvider;


  Future<int> updateEmailNotification() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business/email_notification");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/email_notification/${isEmailNotification == true ? 1 : 0}");

    Map<String, dynamic> body = {
      'email_notification': isEmailNotification == true ? 1 : 0,
      'business_id': businessProvider.business!.id,
    };

    var response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      businessProvider.updateEmailNotification(isEmailNotification == true ? 1 : 0);

      // Fluttertoast.showToast(
      //   msg: 'Notifica Email aggiornata',
      //   backgroundColor: Colors.grey[700],
      // );
      // Navigator.pop(context);

      // return jsonData;
    }
    return response.statusCode;
  }

  Future<int> updateChatNotification() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business/email_notification");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/chat_notification/${isChatNotification == true ? 1 : 0}");

    Map<String, dynamic> body = {
      'chat_notification': isChatNotification == true ? 1 : 0,
      'business_id': businessProvider.business!.id,
    };

    var response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      businessProvider.updateChatNotification(isChatNotification == true ? 1 : 0);

      // Fluttertoast.showToast(
      //   msg: 'Notifica Email aggiornata',
      //   backgroundColor: Colors.grey[700],
      // );
      // Navigator.pop(context);

      // return jsonData;
    }
    return response.statusCode;
  }

  @override
  void initState() {
    super.initState();

    BusinessPreferences.init();

    socketProvider = Provider.of<SocketProvider>(this.context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(this.context, listen: false);

    // businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // if(BusinessPreferences.getEnableNotifications() == null){
    //   BusinessPreferences.setEnableNotifications(true);
    // }
    // isEnabled = BusinessPreferences.getEnableNotifications() ?? ;
    isEnabled = BusinessPreferences.getEnableNotifications();

    // if(BusinessPreferences.getBackgroundNotifications() == null){
    //   BusinessPreferences.setBackgroundNotifications(true);
    // }
    isBackground = BusinessPreferences.getBackgroundNotifications();

    // if(BusinessPreferences.getVibrateNotifications() == null){
    //   BusinessPreferences.setVibrateNotifications(true);
    // }
    isVibrate = BusinessPreferences.getVibrateNotifications();

    // if(BusinessPreferences.getSilentNotifications() == null){
    //   BusinessPreferences.setSilentNotifications(false);
    // }
    isSilent = BusinessPreferences.getSilentNotifications();
    // isEmailNotification = businessProvider.business!.email_notification == 1 ? true : false;
    isEmailNotification = businessProvider.business!.businessSetting?.email_notification == 1 ? true : false;
    isChatNotification = businessProvider.business!.businessSetting?.chat_notification == 1 ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue[500], //change your color here
          ),
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
          centerTitle: true,
          elevation: 0,
          // foregroundColor: Colors.blue,
          backgroundColor: Colors.white,
          // centerTitle: true,
          title: Text(
            // 'I miei dati',
            'Notifiche',
            style: TextStyle(
                color: Colors.blue[500],
                // color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 15
            ),
          ),
          actions: [

          ],
        ),
      ),
      // body: buildSettingsList(),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          // backgroundColor: Colors.white,
          shrinkWrap: true,
          children: [
            // Container(
            //   padding: EdgeInsets.only(
            //       top: 8,
            //       bottom: 8,
            //       left: 15,
            //       right: 15
            //   ),
            //   width: double.infinity,
            //   color: Colors.white,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.notifications_none,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .6,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Abilitate',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                         // fontWeight: FontWeight.w500,
            //                         // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   // 'Ricevi notifiche di chat, esperienze e molto altro dai tuoi amici!',
            //                   'Ricevi notifiche di chat, prenotazioni, esperienze e molto altro dai tuoi clienti!',
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       Container(
            //         padding: EdgeInsets.only(right: 25),
            //         width: 24,
            //         // height: 24,
            //         // padding: EdgeInsets.only(left: 50),
            //         // margin: EdgeInsets.only(left: 50),
            //         child: Switch(
            //           value: isEnabled,
            //           // splashRadius: 20,
            //           onChanged: (value) {
            //             setState(() {
            //               isEnabled = value;
            //             });
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            /*SizedBox(height: 5,),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                hoverColor: Colors.transparent,
                focusNode: FocusNode(

                ),
                // enableFeedback: false,
                selectedTileColor: Colors.transparent,
                // activeColor: Colors.transparent,
                // activeTrackColor: Colors.transparent,
                // tileColor: Colors.transparent,
                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        Icons.notifications_none,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                // 'Abilitate',
                                'Locali',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              // 'Ricevi notifiche di chat, esperienze e molto altro dai tuoi amici!',
                              // 'Ricevi notifiche di chat, prenotazioni, esperienze e molto altro dai tuoi clienti!',
                              'Ricevi notifiche di chat, prenotazioni, e molto altro dai tuoi clienti!',
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                // subtitle: Text(
                //   "Attiva la vibrazione per le notifiche",
                //   // style: GoogleFonts.roboto(
                //   style: TextStyle(
                //     // fontWeight: FontWeight.w500,
                //     // color: Colors.blue,
                //       color: Colors.grey[600],
                //       fontSize: 13
                //   ),
                // ),
                value: isEnabled!,
                // splashRadius: 20,
                onChanged: (value) async {
                  await BusinessPreferences.setEnableNotifications(value);
                  setState(() {
                    // isEnabled = value;
                    isEnabled = BusinessPreferences.getEnableNotifications();
                  });
                  if(value && isBackground!){
                    // var c = BackgroundServiceProvider.instance.registerFunction(socketProvider.connect(widget.business.id));
                    // var b = registerFunction();

                    // // var a = BackgroundServiceProvider.instance.registerFunction(backgroundFunction);
                    // // await FlutterBackgroundService().start();
                    // await FlutterBackgroundService().startService();
                  }
                  else if(!value){
                    // // var a = BackgroundServiceProvider.instance.stopFunction();
                    // // FlutterBackgroundService().stopBackgroundService();
                    // // FlutterBackgroundService().sendData({"action": "stopService"},);
                    // FlutterBackgroundService().invoke("stopService");
                  }
                },
              ),
            ),*/

            // SizedBox(height: 15,),

            // Container(
            //   padding: EdgeInsets.only(
            //     top: 8,
            //     bottom: 8,
            //     left: 15,
            //     right: 15
            //   ),
            //   width: double.infinity,
            //   color: Colors.white,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             // Icons.notifications_active_outlined,
            //             Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .6,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Background',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "Ricevi notifiche anche quando l'app è chiusa!",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       Container(
            //         padding: EdgeInsets.only(right: 25,),
            //         // margin: EdgeInsets.only(left: 55,),
            //         width: 24,
            //         // height: 24,
            //         // padding: EdgeInsets.only(left: 50),
            //         // margin: EdgeInsets.only(left: 50),
            //         child: Switch(
            //           value: isBackground,
            //           // splashRadius: 20,
            //           onChanged: (value) {
            //             setState(() {
            //               isBackground = value;
            //             });
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            SizedBox(height: 10,),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                // selected: !isEnabled,
                // selectedTileColor: Colors.grey[200],

                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        Icons.mark_email_unread_outlined,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                'Email',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Ricevi notifiche mail riguardanti le tue prenotazioni",
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // value: userProvider.user.email_notification == 1 ? true : false,
                value: isEmailNotification!,
                onChanged: (value) async {
                  // await UserPreferences.setSilentNotifications(value);
                  isEmailNotification = value;
                  int status = await updateEmailNotification();
                  if(status == 200){
                    if(value){
                      setState(() {
                        businessProvider.business!.email_notification = 1;
                        isEmailNotification = value;
                      });
                    }
                    else {
                      setState(() {
                        businessProvider.business!.email_notification = 0;
                        isEmailNotification = value;
                      });
                    }
                  }
                  // print('businessProvider.business.email_notification');
                  // print(businessProvider.business!.email_notification);
                },
              ),
            ),

            SizedBox(height: 10,),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                // selected: !isEnabled,
                // selectedTileColor: Colors.grey[200],

                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        // Icons.sms_failed_outlined,
                        Icons.mark_chat_unread_outlined,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                'Chat',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Ricevi notifiche chat",
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // value: userProvider.user.email_notification == 1 ? true : false,
                value: isChatNotification!,
                onChanged: (value) async {
                  // await UserPreferences.setSilentNotifications(value);
                  isChatNotification = value;
                  int status = await updateChatNotification();
                  if(status == 200){
                    if(value){
                      setState(() {
                        businessProvider.business!.businessSetting?.chat_notification = 1;
                        isChatNotification = value;
                      });
                    }
                    else {
                      setState(() {
                        businessProvider.business!.businessSetting?.chat_notification = 0;
                        isChatNotification = value;
                      });
                    }
                  }
                  // print('businessProvider.business.email_notification');
                  // print(businessProvider.business!.email_notification);
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 20, bottom: 5),
                  child: Text(
                    'Generale',
                    style: GoogleFonts.roboto(
                      color: Colors.blue[500],
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),

            // SizedBox(height: 10,),
            //
            // Theme(
            //   data: ThemeData(
            //     splashColor: Colors.transparent,
            //     highlightColor: Colors.transparent,
            //   ),
            //   child: SwitchListTile(
            //     // isThreeLine: true,
            //     hoverColor: Colors.transparent,
            //     selected: false,
            //     focusNode: FocusNode(
            //
            //     ),
            //     // enableFeedback: false,
            //     selectedTileColor: Colors.transparent,
            //     // activeColor: Colors.transparent,
            //     // activeTrackColor: Colors.transparent,
            //     // tileColor: Colors.transparent,
            //     title: Container(
            //       width: MediaQuery.of(context).size.width * .5,
            //       child: Row(
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.notifications,
            //             // Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .53,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Background',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "Ricevi notifiche anche quando l'app è chiusa!",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //
            //         ],
            //       ),
            //     ),
            //
            //     value: isBackground! && isEnabled!,
            //     // splashRadius: 20,
            //     onChanged: (value) async {
            //       await BusinessPreferences.setBackgroundNotifications(value);
            //       setState(() {
            //         // isEnabled = value;
            //         isBackground = BusinessPreferences.getBackgroundNotifications()! && isEnabled!;
            //       });
            //       if(value && isEnabled!){
            //         // var c = BackgroundServiceProvider.instance.registerFunction(socketProvider.connect(widget.business.id));
            //
            //         // var b = registerFunction();
            //
            //         // var a = BackgroundServiceProvider.instance.registerFunction(backgroundFunction);
            //
            //         // // FlutterBackgroundService().sendData({"action": "setAsForeground"});
            //         // // await FlutterBackgroundService().start();
            //         // await FlutterBackgroundService().startService();
            //       }
            //       else if(!value){
            //         // // var a = BackgroundServiceProvider.instance.stopFunction();
            //         // // FlutterBackgroundService().stopBackgroundService();
            //         // // FlutterBackgroundService().sendData({"action": "stopService"},);
            //         // FlutterBackgroundService().invoke("stopService");
            //       }
            //     },
            //   ),
            // ),

            SizedBox(height: 10,),

            // Container(
            //   padding: EdgeInsets.only(
            //       top: 8,
            //       bottom: 8,
            //       left: 15,
            //       right: 15
            //   ),
            //   width: double.infinity,
            //   color: Colors.white,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           SizedBox(width: 5,),
            //           Icon(
            //             Icons.notifications_active_outlined,
            //             // Icons.notifications,
            //             color: Colors.grey[500],
            //             size: 27,
            //           ),
            //           SizedBox(width: 30,),
            //           Container(
            //             width: MediaQuery.of(context).size.width * .6,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Padding(
            //                   padding: EdgeInsets.only(bottom: .0),
            //                   child: Text(
            //                     'Vibrazione',
            //                     // style: GoogleFonts.roboto(
            //                     style: TextStyle(
            //                       // fontWeight: FontWeight.w500,
            //                       // color: Colors.blue,
            //                         color: Colors.grey[800],
            //                         fontSize: 16
            //                     ),
            //                   ),
            //                 ),
            //                 SizedBox(height: 2,),
            //                 Text(
            //                   "Attiva la vibrazione per le notifiche",
            //                   // style: GoogleFonts.roboto(
            //                   style: TextStyle(
            //                     // fontWeight: FontWeight.w500,
            //                     // color: Colors.blue,
            //                       color: Colors.grey[600],
            //                       fontSize: 13
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //
            //       InkWell(
            //         onTap: (){
            //           setState(() {
            //             isVibrate = !isVibrate;
            //           });
            //         },
            //         child: Container(
            //           padding: EdgeInsets.only(right: 25, left: 0, top: 0),
            //           // margin: EdgeInsets.only(left: 55,),
            //           width: 24,
            //           // height: 24,
            //           // padding: EdgeInsets.only(left: 50),
            //           // margin: EdgeInsets.only(left: 50),
            //           child: Switch(
            //             value: isVibrate,
            //             // autofocus: true,
            //
            //             // splashRadius: 20,
            //             onChanged: (value) {
            //               setState(() {
            //                 isVibrate = value;
            //               });
            //             },
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                // selected: !isEnabled,
                // selectedTileColor: Colors.grey[200],

                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        Icons.notifications_active_outlined,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                'Vibrazione',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Attiva la vibrazione per le notifiche",
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                value: isVibrate! && isEnabled!,
                onChanged: (value) async {
                  await BusinessPreferences.setVibrateNotifications(value);
                  setState(() {
                    // isEnabled = value;
                    isVibrate = BusinessPreferences.getVibrateNotifications()! && isEnabled!;
                  });
                },
              ),
            ),

            SizedBox(height: 10,),

            Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                // isThreeLine: true,
                // selected: !isEnabled,
                // selectedTileColor: Colors.grey[200],

                title: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Icon(
                        Icons.notifications_off_outlined,
                        // Icons.notifications,
                        color: Colors.grey[500],
                        size: 27,
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * .53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: .0),
                              child: Text(
                                'Silenzioso',
                                // style: GoogleFonts.roboto(
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  // color: Colors.blue,
                                    color: Colors.grey[800],
                                    fontSize: 16
                                ),
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              "Attiva la modalità silenziosa per le notifiche",
                              // style: GoogleFonts.roboto(
                              style: TextStyle(
                                // fontWeight: FontWeight.w500,
                                // color: Colors.blue,
                                  color: Colors.grey[600],
                                  fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                value: isSilent! && isEnabled!,
                onChanged: (value) async {
                  await BusinessPreferences.setSilentNotifications(value);
                  setState(() {
                    // isEnabled = value;
                    isSilent = BusinessPreferences.getSilentNotifications()! && isEnabled!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/*Future<void> _showNotification({
  String? senderUsername, String? senderProfileImage, String? text, String senderId = '0'
}) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(onDidReceiveLocalNotification: null);
  final MacOSInitializationSettings initializationSettingsMacOS =
  MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: null);
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'fcm_nurebo_admin_channel', 'fcm_nurebo_admin_channel', //'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    // 0,
      int.tryParse(senderId) ?? 0,
      senderUsername ?? 'title',
      text ?? 'body',
      platformChannelSpecifics,
      payload: 'item x'
  );
}*/
