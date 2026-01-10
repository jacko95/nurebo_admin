import 'dart:convert';
import 'dart:math';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/booking_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class NotificationsScreen extends StatefulWidget {

  const NotificationsScreen({Key? key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late SocketProvider socketProvider;
  BusinessProvider? businessProvider;
  
  
  @override
  void initState() {
    super.initState();
    // /*await */BusinessPreferences.init();
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    // sqfliteProvider = Provider.of<SqfliteProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    BusinessPreferences.setBusinessLastUpdateNotification(DateTime.now());
    BusinessPreferences.setBusinessLastOpenNotification();
    // print("init BusinessPreferences.getUserLastUpdateNotification()");
    // print(BusinessPreferences.getBusinessLastUpdateNotification());

    //todo: da levare quando riuscirò ad aggiornare "myappointmentlist" (e i tutti i campi) in provider quando arriva una cancellazione o un appuntamento al background service socket.io
    // socketProvider.getLocalAppointmentNotifications(businessProvider.user);
    // if(BusinessPreferences.getIsLogged()){
    //   () async {
    //     await socketProvider.getLocalNotifications(businessProvider.business);
    //   } ();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    BusinessPreferences.setBusinessLastUpdateNotification(DateTime.now());
    BusinessPreferences.setBusinessLastClosedNotification();
    // print("dispose BusinessPreferences.getUserLastUpdateNotification()");
    // print(BusinessPreferences.getBusinessLastUpdateNotification());
  }

  @override
  Widget build(BuildContext context) {
    // sqfliteProvider = Provider.of<SqfliteProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

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
          'Notifiche',
          // 'Aggiornamenti',
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
        child: socketProvider.notificationList.isNotEmpty ? Container(
          // child: ListView.builder(
          child: ListView.separated(
              separatorBuilder: (context, i){
                return Divider(indent: 15, endIndent: 15,);
              },
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 0,
                bottom: 10
                // left: 10,
                // right: 10
              ),
              itemCount: socketProvider.notificationList.length,
              itemBuilder: (context, i) {
                //todo: passare tutto questo da booking_notification con socket.io
                // Prestazione prestazione = new Prestazione(
                //   id: socketProvider.notificationList[i]['prestazione_id'],
                //   duration: socketProvider.notificationList[i]['prestazione_duration'],
                //   image: socketProvider.notificationList[i]['prestazione_image'],
                //   price: socketProvider.notificationList[i]['prestazione_price'],
                //   title: socketProvider.notificationList[i]['prestazione_title'],
                //   description: socketProvider.notificationList[i]['prestazione_description'],
                //   business: new Business(
                //     profile_image: socketProvider.notificationList[i]e['business_profile_image'] ?? '',
                //     id: socketProvider.notificationList[i]['business_id'],
                //     is_booking_business: 1,
                //     name: socketProvider.notificationList[i]['business_name'],
                //     description: socketProvider.notificationList[i]['business_description'],
                //     category_id: socketProvider.notificationList[i]['category_id'],
                //     address: socketProvider.notificationList[i]['business_address'],
                //     phone_number: socketProvider.notificationList[i]['business_phone_number'],
                //     email: socketProvider.notificationList[i]['business_email'],
                //     max_contemporary_appointments: socketProvider.notificationList[i]['max_contemporary_appointments'],
                //   ),
                // );

                Map<String, dynamic> notification = {
                  "id": socketProvider.notificationList[i]['id'],
                  "booking_id": socketProvider.notificationList[i]['booking_id'],
                  'booking_price': socketProvider.notificationList[i]['booking_price'],
                  "booking_begin_at": socketProvider.notificationList[i]['booking_begin_at'],
                  "prestazione_id": socketProvider.notificationList[i]['prestazione_id'],
                  'prestazione_image': socketProvider.notificationList[i]['prestazione_image'],
                  'prestazione_title': socketProvider.notificationList[i]['prestazione_title'],
                  'is_canceled': socketProvider.notificationList[i]['is_canceled'],
                  'user_id': socketProvider.notificationList[i]['user_id'],
                  'user_name': socketProvider.notificationList[i]['user_name'],
                  'user_username': socketProvider.notificationList[i]['user_username'],
                  'user_profile_image': socketProvider.notificationList[i]['user_profile_image'],
                  'business_id': socketProvider.notificationList[i]['business_id'],
                  'business_name': socketProvider.notificationList[i]['business_name'],
                  'sent_at': socketProvider.notificationList[i]['sent_at'],
                };

                // print('notificationaaaaaaaa');
                // print(notification);

                Booking? appun;
                for(Booking e in socketProvider.myAppointments){
                  if(e.id == socketProvider.notificationList[i]['booking_id']){
                    appun = e;
                  }
                }

                return /*Dismissible(
                  // key: ObjectKey(socketProvider.notificationList[i]),
                  // key: UniqueKey(),
                  key: ObjectKey(notification['id']),
                  // behavior: HitTestBehavior.translucent,
                  direction: DismissDirection.endToStart,
                  // dragStartBehavior: DragStartBehavior.start,
                  // crossAxisEndOffset: 22,
                  // confirmDismiss: (direction){
                  //
                  // },
                  onDismissed: (direction) async {
                    // setState(() {
                      // items.removeAt(index);
                      await socketProvider.deleteLocalNotification(
                        'appointment_notification',
                        // notification['booking_id'],
                        notification['id'].toString(),
                        i
                      );
                    // });
                  },
                  child: */InkWell(
                    onTap: (){

                      Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: BookingDetailScreen(
                                booking: appun,
                              )
                            // child: TicketDetailScreen(
                            //   user: widget.user,
                            //   singleEventTicket: singleEventTicket,
                            // ),
                          )
                      );

                      print(socketProvider.notificationList[i]);
                    },
                    // child: Container(
                    //   height: MediaQuery.of(context).size.height * 0.15,
                    //   child: Card(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     clipBehavior: Clip.antiAliasWithSaveLayer,
                    //     elevation: 8,
                    //     child: Stack(
                    //       clipBehavior: Clip.antiAliasWithSaveLayer,
                    //       fit: StackFit.expand,
                    //       children: [
                    //         CachedNetworkImage(
                    //           imageUrl: prestazione.image,
                    //           fit: BoxFit.cover,
                    //           // colorBlendMode: BlendMode.hardLight,
                    //           // width: MediaQuery.of(context).size.width,
                    //           // filterQuality: FilterQuality.high,
                    //           placeholder: (context, url) => Center(
                    //               child: CircularProgressIndicator()
                    //           ),
                    //           errorWidget: (context, url, error) => Icon(Icons.error),
                    //         ),
                    //         DecoratedBox(
                    //           decoration: BoxDecoration(
                    //             // backgroundBlendMode: BlendMode.darken,
                    //             gradient: LinearGradient(
                    //               begin: Alignment.bottomLeft,
                    //               end: Alignment.topRight,
                    //               colors: [
                    //                 Colors.black,
                    //                 // Colors.transparent,
                    //                 Colors.transparent,
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         Positioned(
                    //           bottom: 20,
                    //           left: 20,
                    //           width: MediaQuery.of(context).size.width * 0.4,
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               GradientText(
                    //                 // prestazione.business.name,
                    //                 // notificationList[i]['sender_username'],
                    //                 socketProvider.bookingNotificationList[i]['sender_username'],
                    //                 // 'A partire da € 60,00',
                    //                 maxLines: 1,
                    //
                    //                 // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                    //                 // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                    //                 gradient: LinearGradient(
                    //                     begin: Alignment.bottomLeft,
                    //                     end: Alignment.topRight,
                    //                     colors: [
                    //                       Color(0xff8921aa),
                    //                       Color(0xffDA44bb),
                    //                       // Color(0xffDA44bb)
                    //                     ]
                    //                 ),
                    //                 // gradient: LinearGradient(
                    //                 //     begin: Alignment.bottomLeft,
                    //                 //     end: Alignment.topRight,
                    //                 //     colors: [
                    //                 //       Colors.blue[500],
                    //                 //       Color(0xffDA44bb),
                    //                 //
                    //                 //       Color(0xff8921aa),
                    //                 //     ]
                    //                 // ),
                    //                 style: TextStyle(
                    //                     color: Colors.blue,
                    //                     fontWeight: FontWeight.w800,
                    //                     fontSize: 13
                    //                 ),
                    //                 textAlign: TextAlign.left,
                    //               ),
                    //               GradientText(
                    //                 // prestazione.title,
                    //                 // notificationList[i]['sent_at'],
                    //                 socketProvider.bookingNotificationList[i]['sent_at'],
                    //                 maxLines: 2,
                    //                 shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                    //                 gradient: Gradients.haze,
                    //                 style: TextStyle(
                    //                     color: Colors.white,
                    //                     fontWeight: FontWeight.w800,
                    //                     fontSize: 15
                    //                 ),
                    //                 textAlign: TextAlign.left,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    child: Container(
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                      color: Colors.white,
                      // color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10, /*top: 10, bottom: 10*/),
                            child: Container(
                              width: 90,
                              height: 80,
                              child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: notification['prestazione_image'] != null && notification['prestazione_image'] != '' ? FutureImage(
                                  notification['prestazione_image'],
                                  // imageUrl: notification['user_profile_image'],
                                  width: MediaQuery.of(context).size.width,
                                ) : SizedBox(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 5,
                                //margin: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                          notification['is_canceled'] == 1 ? Expanded(
                            //alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                //mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: /*Gradient*/Container(
                                      width: MediaQuery.of(context).size.width * .55,
                                      child: Marquee(
                                        child: Text(
                                          // '@' + socketProvider.notificationList[i]['sender_username'],
                                          // '@' + socketProvider.notificationList[i]['business_name'],
                                          // '@' + prestazione.business.name,
                                          // /*'@' + */notification['user_name'] ?? '',
                                          notification['user_name'] ?? "@${notification['user_username']}",
                                          maxLines: 1,
                                          // gradient: LinearGradient(
                                          //     begin: Alignment.bottomLeft,
                                          //     end: Alignment.topRight,
                                          //     colors: [
                                          //       Color(0xff8921aa),
                                          //       Color(0xffDA44bb),
                                          //       // Color(0xffDA44bb)
                                          //     ]
                                          // ),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.0,
                                              // color: Colors.white
                                              // color: Colors.black
                                              color: Colors.blue
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        child: Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.black
                                                // color: Colors.white,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  // text: "Parteciperà a ",
                                                  text: "La prenotazione di ",
                                                  // style: TextStyle(
                                                  //   color: Colors.grey[900]
                                                  // )
                                                ),
                                                TextSpan(
                                                  // text: prestazione.title,
                                                  text: notification['prestazione_title'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    // color: Colors.blue[500]
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " da ",
                                                  // style: TextStyle(
                                                  //     color: Colors.grey[900]
                                                  // )
                                                ),
                                                TextSpan(
                                                  // text: prestazione.business.name,
                                                  // text: notification['business_name'],
                                                  text: notification['user_name'] ?? "@${notification['user_username']}",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                                TextSpan(
                                                  // text: "Parteciperà a ",
                                                  text: " per il ",
                                                  // style: TextStyle(
                                                  //   color: Colors.grey[900]
                                                  // )
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(notification['booking_begin_at'])!).toString(),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: ' alle ',
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: notification['booking_begin_at'].substring(11, 16),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: ' è stata ',

                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: 'annullata',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.red[600]
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // child: Text(
                                          //   //"Feed me right now or else ... ",
                                          //   "Parteciperà all'evento " + notifications[i].title +
                                          //       " il " + notifications[i].booking + " alle ore " +
                                          //       notifications[i].hour + " al " + notifications[i].place
                                          //   /*+ " organizzato da " + notifications[i].eventOrganizer*/,
                                          //   maxLines: 2,
                                          //   overflow: TextOverflow.ellipsis,
                                          //   // softWrap: true,
                                          //   style: TextStyle(
                                          //     color: Colors.grey[600],
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      timeAgo.format(
                                          // DateTime.tryParse(socketProvider.notificationList[i]['sent_at']),
                                          DateTime.tryParse(socketProvider.notificationList[i]['sent_at'])!,
                                          locale: 'it'
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.0,
                                          // color: Colors.white
                                          color: Colors.grey[500]
                                      ),
                                    ),
                                  ),
                                  // Column(
                                  //   // mainAxisAlignment: MainAxisAlignment.end,
                                  //   // crossAxisAlignment: CrossAxisAlignment.center,
                                  //   children: [
                                  //     Padding(
                                  //       padding: EdgeInsets.only(top: 5),
                                  //       child: Text(
                                  //         "Rimangono solo " + '3' + " posti disponibili",
                                  //         style: TextStyle(
                                  //             color: Colors.blue[300],
                                  //             fontSize: 13,
                                  //             fontWeight: FontWeight.w600
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //       vertical: 10.0, horizontal: 0.0
                                  //   ),
                                  //   child: LinearPercentIndicator(
                                  //     padding: EdgeInsets.only(left: 4),
                                  //     // alignment: MainAxisAlignment.center,
                                  //     width: 210.0,
                                  //     lineHeight: 5.0,
                                  //     percent: (60/3)/100,
                                  //     progressColor: Colors.blue[300],
                                  //     // backgroundColor: CupertinoColors.black,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ) : Expanded(
                            //alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                //mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: /*Gradient*/Container(
                                      width: MediaQuery.of(context).size.width * .55,
                                      child: Marquee(
                                        child: Text(
                                          // '@' + socketProvider.notificationList[i]['sender_username'],
                                          // '@' + socketProvider.notificationList[i]['business_name'],
                                          // '@' + prestazione.business.name,
                                          // /*'@' + */notification['business_name'] ?? '',
                                          notification['user_name'] ?? "@${notification['user_username']}",
                                          // gradient: LinearGradient(
                                          //     begin: Alignment.bottomLeft,
                                          //     end: Alignment.topRight,
                                          //     colors: [
                                          //       Color(0xff8921aa),
                                          //       Color(0xffDA44bb),
                                          //       // Color(0xffDA44bb)
                                          //     ]
                                          // ),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.0,
                                              // color: Colors.white
                                              // color: Colors.black
                                              color: Colors.blue
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        child: Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.black
                                                // color: Colors.white,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  // text: "Parteciperà a ",
                                                  text: "La prenotazione di ",
                                                  // style: TextStyle(
                                                  //   color: Colors.grey[900]
                                                  // )
                                                ),
                                                TextSpan(
                                                  // text: prestazione.title,
                                                  text: notification['prestazione_title'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    // color: Colors.blue[500]
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " da ",
                                                  // style: TextStyle(
                                                  //     color: Colors.grey[900]
                                                  // )
                                                ),
                                                TextSpan(
                                                  // text: prestazione.business.name,
                                                  // text: notification['business_name'],
                                                  text: notification['user_name'] ?? "@${notification['user_username']}",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                                TextSpan(
                                                  // text: "Parteciperà a ",
                                                  text: " per il ",
                                                  // style: TextStyle(
                                                  //   color: Colors.grey[900]
                                                  // )
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(notification['booking_begin_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/).toString(),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: ' alle ',
                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: DateTime.tryParse(notification['booking_begin_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700
                                                  ),
                                                ),
                                                // TextSpan(
                                                //   // text: socketProvider.notificationList[i]['created_at'],
                                                //   text: ' è stata effettuata',
                                                // ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: ' è stata ',

                                                ),
                                                TextSpan(
                                                  // text: socketProvider.notificationList[i]['created_at'],
                                                  text: 'effettuata',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.green[600]
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // child: Text(
                                          //   //"Feed me right now or else ... ",
                                          //   "Parteciperà all'evento " + notifications[i].title +
                                          //       " il " + notifications[i].booking + " alle ore " +
                                          //       notifications[i].hour + " al " + notifications[i].place
                                          //   /*+ " organizzato da " + notifications[i].eventOrganizer*/,
                                          //   maxLines: 2,
                                          //   overflow: TextOverflow.ellipsis,
                                          //   // softWrap: true,
                                          //   style: TextStyle(
                                          //     color: Colors.grey[600],
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      timeAgo.format(
                                        // DateTime.tryParse(socketProvider.notificationList[i]['sent_at']),
                                          DateTime.tryParse(socketProvider.notificationList[i]['sent_at'])!,
                                          locale: 'it'
                                      ),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.0,
                                          // color: Colors.white
                                          color: Colors.grey[500]
                                      ),
                                    ),
                                  ),
                                  // Column(
                                  //   // mainAxisAlignment: MainAxisAlignment.end,
                                  //   // crossAxisAlignment: CrossAxisAlignment.center,
                                  //   children: [
                                  //     Padding(
                                  //       padding: EdgeInsets.only(top: 5),
                                  //       child: Text(
                                  //         "Rimangono solo " + '3' + " posti disponibili",
                                  //         style: TextStyle(
                                  //             color: Colors.blue[300],
                                  //             fontSize: 13,
                                  //             fontWeight: FontWeight.w600
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //       vertical: 10.0, horizontal: 0.0
                                  //   ),
                                  //   child: LinearPercentIndicator(
                                  //     padding: EdgeInsets.only(left: 4),
                                  //     // alignment: MainAxisAlignment.center,
                                  //     width: 210.0,
                                  //     lineHeight: 5.0,
                                  //     percent: (60/3)/100,
                                  //     progressColor: Colors.blue[300],
                                  //     // backgroundColor: CupertinoColors.black,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            // Opacity(
                            // visible: DateTime.tryParse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.tryParse(BusinessPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                            visible: DateTime.tryParse(notification['sent_at'])!.isAfter(DateTime.tryParse(BusinessPreferences.getBusinessLastClosedNotification() ?? DateTime.now().toIso8601String())!),
                            // opacity: DateTime.tryParse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.tryParse(BusinessPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                            child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 20, ),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            // Opacity(
                            // visible: !DateTime.tryParse(socketProvider.notificationList[i]['sent_at']).isAfter(DateTime.tryParse(BusinessPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())),
                            visible: !DateTime.tryParse(socketProvider.notificationList[i]['sent_at'])!.isAfter(DateTime.tryParse(BusinessPreferences.getBusinessLastClosedNotification() ?? DateTime.now().toIso8601String())!),
                            // opacity: DateTime.tryParse(socketProvider.bookingNotificationList[i]['sent_at']).isAfter(DateTime.tryParse(BusinessPreferences.getUserLastClosedNotification() ?? DateTime.now().toIso8601String())) ? 1 : 0,
                            child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 20, ),
                            ),
                          ),
                          // Divider(height: 5, thickness: 5,),
                        ],
                      ),
                    ),
                  // ),
                );
              }
            // ImageCard(
            //   imageData: imageList[index],
            // ),
          ),
        ) : ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .1,),
            Center(
              child: Image.asset(
                'assets/png/Saly-14.png',
                height: MediaQuery.of(context).size.height * .4,
                // width: MediaQuery.of(context).size.width * .4,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05,),
            Center(
              child: Text(
                'Non ci sono notifiche',
                // "Non c'è' nessuna notifica...",
                // 'Le mie prestazioni',
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
