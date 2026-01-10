import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/booking_insert_screen.dart';
import 'package:nurebo_admin/screens/booking_insert_screen2.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class BookingScreen extends StatefulWidget {
  // final Business bookingBusiness;

  BookingScreen({Key? key, /*this.bookingBusiness*/});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime now = DateTime.now();
  late SocketProvider socketProvider;
  late BusinessProvider businessProvider;
  BookingProvider? bookingProvider;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    // print('socketProvider.myAppointments.length0');
    // print(socketProvider.myAppointments.length);
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(this.context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(this.context, listen: true);
    bookingProvider = Provider.of<BookingProvider>(context, listen: true);

    return RefreshIndicator(
      edgeOffset: 60,
      // strokeWidth: 5,
      // displacement: 200,
      // triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        socketProvider.myAppointments.clear();
        Future.wait([
          socketProvider.getBusinessAppointments(/*businessProvider.business*/),
          // socketProvider.getGuestBookings(),
        ]);
        // print('socketProvider.myAppointments.length1');
        // print(socketProvider.myAppointments.length);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
            'Prenotazioni',
            style: TextStyle(
                color: Colors.blue[500],
                // color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 16
            ),
          ),
          actions: [
            // Container(
            //   // height: MediaQuery.of(context).size.width * 0.001,
            //   width: MediaQuery.of(context).size.width * 0.25,
            //   margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 10),
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       padding: EdgeInsets.zero,
            //       backgroundColor: Colors.white,
            //       // backgroundColor: Colors.grey[500],
            //       // minimumSize: Size(50, 30),
            //       alignment: Alignment.center,
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //           duration: const Duration(milliseconds: 500),
            //           alignment: Alignment.center,
            //           type: PageTransitionType.fade,
            //           child: const BookingInsertScreen2(
            //             // bookingBusiness: businessProvider.business,
            //           )
            //         )
            //       );
            //     },
            //     child: Text(
            //       'Aggiungi',
            //       style: TextStyle(
            //         color: Colors.blue[500],
            //         fontWeight: FontWeight.w600,
            //         fontSize: 12,
            //       ),
            //     )
            //   ),
            // ),
          ],
        ),
        /*body: FutureBuilder<Object>(
          future: a,
          builder: (context, snapshot) {
            return*/body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: ListView.separated(
                separatorBuilder: (context, i){
                  return Divider(height: 0, indent: 20, endIndent: 20, thickness: 1, color: Colors.grey[300],);
                },
                  // itemCount: myAppointments.length,
                  itemCount: socketProvider.myAppointments.length,
                  itemBuilder: (context, index){
                      // Appointment appointment = new Appointment(
                      //   id: myAppointments[index]['booking_id'],
                      //   // note: myAppointments[index]['note'],
                      //   // user_id: myAppointments[index]['user_id'].toString(),
                      //   prestazione: new Prestazione(
                      //     duration: myAppointments[index]['prestazione_duration'],
                      //     image: myAppointments[index]['prestazione_image'],
                      //     price: myAppointments[index]['prestazione_price'],
                      //     title: myAppointments[index]['prestazione_title'],
                      //     description: myAppointments[index]['prestazione_description'],
                      //     business_id: myAppointments[index]['prestazione_business_id'],
                      //   ),
                      //   user: new User(
                      //     email: myAppointments[index]['user_email'],
                      //     username: myAppointments[index]['user_username'],
                      //     name: myAppointments[index]['user_name'],
                      //     phone_number: myAppointments[index]['user_phone_number'],
                      //     profile_image: myAppointments[index]['user_profile_image'],
                      //     // description: appointments[i]['user_description'],
                      //   ),
                      //   // business: new Business(
                      //   //   image: myAppointments[index]['profile_image'],
                      //   //   id: myAppointments[index]['business_id'],
                      //   //   // is_booking_business: 1,
                      //   //   name: myAppointments[index]['name'],
                      //   //   address: myAppointments[index]['address'],
                      //   //   phone_number: myAppointments[index]['phone_number'],
                      //   //   // max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
                      //   //
                      //   // ),
                      //   // is_paid: myAppointments[index]['is_paid'],
                      //   begin_at: DateTime.tryParse(myAppointments[index]['begin_at']).toLocal(),
                      //   end_at: DateTime.tryParse(myAppointments[index]['begin_at']).add(Duration(minutes: myAppointments[index]['prestazione_duration'].toInt())).toLocal(),
                      //   created_at: DateTime.tryParse(myAppointments[index]['created_at']).toLocal(),
                      // );

                      /*Appointment appointment = new Appointment(
                        id: socketProvider.myAppointments[index]['booking_id'],
                        isCanceled: socketProvider.myAppointments[index]['is_canceled'],
                        // note: myAppointments[index]['note'],
                        // user_id: myAppointments[index]['user_id'].toString(),
                        prestazione: new Prestazione(
                          duration: socketProvider.myAppointments[index]['prestazione_duration'],
                          image: socketProvider.myAppointments[index]['prestazione_image'],
                          price: socketProvider.myAppointments[index]['prestazione_price'],
                          title: socketProvider.myAppointments[index]['prestazione_title'],
                          description: socketProvider.myAppointments[index]['prestazione_description'],
                          business_id: socketProvider.myAppointments[index]['prestazione_business_id'],
                        ),
                        user: new User(
                          email: socketProvider.myAppointments[index]['user_email'],
                          username: socketProvider.myAppointments[index]['user_username'],
                          name: socketProvider.myAppointments[index]['user_name'],
                          phone_number: socketProvider.myAppointments[index]['user_phone_number'],
                          profile_image: socketProvider.myAppointments[index]['user_profile_image'],
                          // description: appointments[i]['user_description'],
                        ),
                        // business: new Business(
                        //   image: myAppointments[index]['profile_image'],
                        //   id: myAppointments[index]['business_id'],
                        //   // is_booking_business: 1,
                        //   name: myAppointments[index]['name'],
                        //   address: myAppointments[index]['address'],
                        //   phone_number: myAppointments[index]['phone_number'],
                        //   // max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
                        //
                        // ),
                        // is_paid: myAppointments[index]['is_paid'],
                        begin_at: DateTime.tryParse(socketProvider.myAppointments[index]['begin_at']).toLocal(),
                        end_at: DateTime.tryParse(socketProvider.myAppointments[index]['begin_at']).add(Duration(minutes: socketProvider.myAppointments[index]['prestazione_duration'].toInt())).toLocal(),
                        created_at: DateTime.tryParse(socketProvider.myAppointments[index]['created_at']).toLocal(),
                      );*/

                      return InkWell(
                        onTap: (){
                          // print(myAppointments[index]['single_event_title']);
                          // if(socketProvider.myAppointments[index].guestName == null){
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: const Duration(milliseconds: 500),
                                    alignment: Alignment.center,
                                    type: PageTransitionType.fade,
                                    child: BookingDetailScreen(
                                      // appointment: appointment,
                                      booking: socketProvider.myAppointments[index],
                                      // business: widget.bookingBusiness,
                                      // appointment: new Appointment(
                                      //   id: socketProvider.myAppointments[index]['booking_id'],
                                      //   isCanceled: socketProvider.myAppointments[index]['is_canceled'],
                                      //   // note: myAppointments[index]['note'],
                                      //   // user_id: myAppointments[index]['user_id'].toString(),
                                      //   prestazione: new Prestazione(
                                      //     duration: socketProvider.myAppointments[index]['prestazione_duration'],
                                      //     image: socketProvider.myAppointments[index]['prestazione_image'],
                                      //     price: socketProvider.myAppointments[index]['prestazione_price'],
                                      //     title: socketProvider.myAppointments[index]['prestazione_title'],
                                      //     description: socketProvider.myAppointments[index]['prestazione_description'],
                                      //     business_id: socketProvider.myAppointments[index]['prestazione_business_id'],
                                      //   ),
                                      //   user: new User(
                                      //     email: socketProvider.myAppointments[index]['user_email'],
                                      //     username: socketProvider.myAppointments[index]['user_username'],
                                      //     name: socketProvider.myAppointments[index]['user_name'],
                                      //     phone_number: socketProvider.myAppointments[index]['user_phone_number'],
                                      //     profile_image: socketProvider.myAppointments[index]['user_profile_image'],
                                      //     // description: appointments[i]['user_description'],
                                      //   ),
                                      //   // business: new Business(
                                      //   //   image: myAppointments[index]['profile_image'],
                                      //   //   id: myAppointments[index]['business_id'],
                                      //   //   // is_booking_business: 1,
                                      //   //   name: myAppointments[index]['name'],
                                      //   //   address: myAppointments[index]['address'],
                                      //   //   phone_number: myAppointments[index]['phone_number'],
                                      //   //   // max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
                                      //   //
                                      //   // ),
                                      //   // is_paid: myAppointments[index]['is_paid'],
                                      //   begin_at: DateTime.tryParse(socketProvider.myAppointments[index]['begin_at']).toLocal(),
                                      //   end_at: DateTime.tryParse(socketProvider.myAppointments[index]['begin_at']).add(Duration(minutes: socketProvider.myAppointments[index]['prestazione_duration'].toInt())).toLocal(),
                                      //   created_at: DateTime.tryParse(socketProvider.myAppointments[index]['created_at']).toLocal(),
                                      // )
                                    )
                                  // child: TicketDetailScreen(
                                  //   user: widget.user,
                                  //   singleEventTicket: singleEventTicket,
                                  // ),
                                )
                            );
                          // }
                        },
                        child: ListTile(
                          isThreeLine: true,
                          leading: Card(
                            // margin: EdgeInsets.only(right: ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: 5,
                            child: FutureImage(
                              // myAppointments[index]['image'],
                              // appointment.prestazione.image,
                              // appointment.user.profile_image,
                              // socketProvider.myAppointments[index]['user_profile_image'],
                              // socketProvider.myAppointments[index].user!.profile_image,
                              socketProvider.myAppointments[index].prestazione!.image != null && socketProvider.myAppointments[index].prestazione!.image != 'null' && socketProvider.myAppointments[index].prestazione!.image != ''
                                ? socketProvider.myAppointments[index].prestazione!.image!
                                // : socketProvider.myAppointments[index].prestazione!.business!.profile_image!,
                                : businessProvider.business!.profile_image!,
                              // event.image,
                              width: 70,
                              height: 60,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .4,
                                child: Marquee(
                                  child: Text(
                                   // myAppointments[index]['user_username'],
                                   // appointment.user.username,
                                   //  socketProvider.myAppointments[index]['user_username'],
                                   //  socketProvider.myAppointments[index].user!.username != null
                                   //      ? '@' + socketProvider.myAppointments[index].user!.username!
                                   //      : socketProvider.myAppointments[index].guestName!,
                                    socketProvider.myAppointments[index].user!.name != null
                                        ? socketProvider.myAppointments[index].user!.name!
                                        : socketProvider.myAppointments[index].user!.username!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.blue[500],
                                      // color: Colors.grey[700],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                timeAgo.format(
                                  // appointment.created_at,
                                  // DateTime.tryParse(socketProvider.myAppointments[index]['created_at']),
                                  socketProvider.myAppointments[index].created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
                                  locale: 'it'
                                ),
                                // booking.prestazione.title,
                                // booking.business.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    // color: Colors.blue,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(event.performer_name),
                              SizedBox(
                                height: 3.2,
                              ),
                              // GradientText(
                              Text(
                                // myAppointments[index]['single_event_title'],
                                // appointment.prestazione.title,
                                // socketProvider.myAppointments[index]['prestazione_title'],
                                socketProvider.myAppointments[index].prestazione!.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  // color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[850],
                                  // color: Colors.blue[500],
                                  fontSize: 13

                                ),
                                // gradient: LinearGradient(
                                //     begin: Alignment.bottomLeft,
                                //     end: Alignment.topRight,
                                //     colors: [
                                //       Color(0xff8921aa),
                                //       // Color(0xffDA44bb),
                                //       Colors.pink
                                //     ]
                                // )
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Marquee(
                                child: Row(
                                  children: [
                                    // myAppointments[index]['is_canceled'] == 0 ? Text(
                                    // socketProvider.socketAppointments[index]['is_canceled'] == 0 ? Text(
                                    // appointment.isCanceled == 0 ? Text(
                                    // socketProvider.myAppointments[index]['is_canceled']/*.toString()*/ == 0/*.toString()*/ ? Text(
                                    socketProvider.myAppointments[index].isCanceled/*.toString()*/ == 0/*.toString()*/ ? Text(
                                      !socketProvider.myAppointments[index].prestazione!.is_price_range ? '€ ${NumberFormat.currency(
                                        // customPattern: '#,##',
                                        decimalDigits: 2,
                                        symbol: '',
                                        locale: 'IT_it',
                                        // symbol: '€'
                                      // ).format(double.tryParse(appointment.prestazione.price.toString())),
                                      // ).format(double.tryParse(socketProvider.myAppointments[index]['prestazione_price'].toString())),
                                      ).format(double.tryParse(socketProvider.myAppointments[index].prestazione!.price.toString()))}' : 'da € ${NumberFormat.currency(
                                        // customPattern: '#,##',
                                        decimalDigits: 2,
                                        symbol: '',
                                        locale: 'IT_it',
                                        // symbol: '€'
                                        // ).format(double.tryParse(appointment.prestazione.price.toString())),
                                        // ).format(double.tryParse(socketProvider.myAppointments[index]['prestazione_price'].toString())),
                                      ).format(double.tryParse(socketProvider.myAppointments[index].prestazione!.price_min.toString()))} a € ${NumberFormat.currency(
                                        // customPattern: '#,##',
                                        decimalDigits: 2,
                                        symbol: '',
                                        locale: 'IT_it',
                                        // symbol: '€'
                                        // ).format(double.tryParse(appointment.prestazione.price.toString())),
                                        // ).format(double.tryParse(socketProvider.myAppointments[index]['prestazione_price'].toString())),
                                      ).format(double.tryParse(socketProvider.myAppointments[index].prestazione!.price_max.toString()))}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.green[500],
                                        fontWeight: FontWeight.w800,
                                          fontSize: 13
                                      ),
                                    ) : Padding(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      child: Text(
                                        'Annullato',
                                        style: TextStyle(
                                          color: Colors.red[500],
                                          fontWeight: FontWeight.w800,
                                            fontSize: 13
                                        ),
                                      ),
                                    ),
                                    Text(
                                      // "25 posti disponibili",
                                      // DateTime.tryParse(myAppointments[index]['begin_at']).toString(),
                                      // /*booking.begin_at.toString().substring(11, 16) +*/ ' •  ' + DateFormat.yMMMMd('it_IT').format(appointment.begin_at).toString() + ' alle ' + appointment.begin_at.toString().substring(11, 16),
                                      // /*booking.begin_at.toString().substring(11, 16) +*/ ' •  ' + DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(socketProvider.myAppointments[index]['begin_at'])).toString() + ' alle ' + DateTime.tryParse(socketProvider.myAppointments[index]['begin_at']).toString().substring(11, 16),
                                      /*booking.begin_at.toString().substring(11, 16) +*/ ' •  ${DateFormat.yMMMMd('it_IT').format(socketProvider.myAppointments[index].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)} alle ${socketProvider.myAppointments[index].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13
                                      ),
                                      // gradient: LinearGradient(
                                      //     begin: Alignment.bottomLeft,
                                      //     end: Alignment.topRight,
                                      //     colors: [
                                      //       Color(0xff8921aa),
                                      //       // Color(0xffDA44bb),
                                      //       Colors.pink
                                      //     ]
                                      // )
                                    ),
                                  ],
                                ),
                              ),
                              // myAppointments[index]['is_paid'] == 0 && myAppointments[index]['is_valibookingd'] == 0
                              //   ? Text(
                              //       // "25 posti disponibili",
                              //       "Biglietto valido",
                              //       style: TextStyle(
                              //         color: Colors.greenAccent[700],
                              //         fontWeight: FontWeight.w600,
                              //       ),
                              //     )
                              //   : myAppointments[index]['is_expired'] == 1
                              //     ? Text(
                              //         // "25 posti disponibili",
                              //         "Biglietto scaduto",
                              //         style: TextStyle(
                              //           color: Colors.redAccent[700],
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       )
                              //     : myAppointments[index]['is_valibookingd'] == 1
                              //     ? Text(
                              //   // "25 posti disponibili",
                              //   "Biglietto convalidato",
                              //   style: TextStyle(
                              //     color: Colors.indigoAccent[700],
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ) : Text(
                              //   // "25 posti disponibili",
                              //   "",
                              // )
                            ],
                          ),
                        ),
                      );

                  }
              ),
            // );
          // }
        ),

      ),
    );
  }
}
