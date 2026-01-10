import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/booking_insert_screen.dart';
import 'package:nurebo_admin/screens/booking_insert_screen2.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class CalendarScreen2 extends StatefulWidget {
  const CalendarScreen2({Key? key,});

  @override
  _CalendarScreen2State createState() => _CalendarScreen2State();
}

class _CalendarScreen2State extends State<CalendarScreen2> {
  late SocketProvider socketProvider;
  late BusinessProvider businessProvider;
  late BookingProvider bookingProvider;
  Future a = Future((){}), b = Future((){});

  final double _borderRadius = 12;

  var items = [
    PlaceInfo('Giovanni Malagò', Color(0xff6DC8F3), Color(0xff73A1F9),
        4.4, 'Massaggio del viso', '@malakira'),
    PlaceInfo('Giovanni Malagò', Color(0xffD76EF5), Color(0xff8F7AFE),
        4.4, 'Massaggio del viso', '@malakira'),
    PlaceInfo('Hamriyah Food Court', Color(0xffFFB157), Color(0xffFFA057), 3.7,
        'Sharjah', 'All you can eat · Casual · Groups'),
    PlaceInfo('Gate of Food Court', Color(0xffFF5B95), Color(0xffF8556D), 4.5,
        'Dubai · Near Dubai Aquarium', 'Casual · Groups'),
    PlaceInfo('BurJuman Food Court', Color(0xff42E695), Color(0xff3BB2B8), 4.2,
        'Dubai · In BurJuman', '...'),
    PlaceInfo('Giovanni Malagò', Color(0xFF6448FE), Color(0xFF5FC6FF),
        4.4, 'Massaggio del viso', '@malakira'),
    PlaceInfo('Giovanni Malagò', Color(0xFFFE6197), Color(0xFFFFB463),
        4.4, 'Massaggio del viso', '@malakira'),
    PlaceInfo('Hamriyah Food Court', Color(0xFF61A3FE), Color(0xFF63FFD5), 3.7,
        'Sharjah', 'All you can eat · Casual · Groups'),
    PlaceInfo('Gate of Food Court', Color(0xFFFFA738), Color(0xFFFFE130), 4.5,
        'Dubai · Near Dubai Aquarium', 'Casual · Groups'),
    PlaceInfo('BurJuman Food Court', Color(0xFFFF5DCD), Color(0xFFFF8484), 4.2,
        'Dubai · In BurJuman', '...'),
  ];


  Widget _dateBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 4),
      child: DatePicker(
        DateTime.now(),
        //height: 100.0,
        initialSelectedDate: DateTime.now(),
        locale: 'it_IT',
        selectionColor: Colors.transparent,
        // selectionColor: Colors.blue[500],
        selectedTextColor: Colors.blue[500]!,
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
              fontWeight: FontWeight.w500
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 10.0,
            color: Colors.grey,
          ),
        ),
        // deactivatedColor: Colors.white,
        onDateChange: (date) async {
          setState(() {
            bookingProvider.selectedDate = date;
          });
          bookingProvider.appointments!.clear();
          Future.wait([
            // appointmentProvider.init(businessProvider.business!.id, socketProvider.socketAppointments, context)
            a = bookingProvider.getAppointmentsByDate(businessProvider.business!.id, context),
            b = bookingProvider.getGuestAppointmentsByDate(businessProvider.business!.id, context),
          ]);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    bookingProvider.appointments!.clear();
    bookingProvider.selectedDate = DateTime.now();

    Future.wait([
      // appointmentProvider.init(businessProvider.business!.id, socketProvider.socketAppointments, context)
      a = bookingProvider.getAppointmentsByDate(businessProvider.business!.id, context),
      b = bookingProvider.getGuestAppointmentsByDate(businessProvider.business!.id, context)
    ]).then((value) {
      // print('ssvbfdgf5ddf');
      // print(bookingProvider.appointments!.length);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    bookingProvider = Provider.of<BookingProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        // leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.all(0),
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
          'Calendario',
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
          //       style: OutlinedButton.styleFrom(
          //         padding: EdgeInsets.zero,
          //         backgroundColor: Colors.white,
          //         // backgroundColor: Colors.grey[500],
          //         // minimumSize: Size(50, 30),
          //         alignment: Alignment.center,
          //       ),
          //       onPressed: () {
          //         Navigator.push(
          //             context,
          //             PageTransition(
          //                 duration: const Duration(milliseconds: 500),
          //                 alignment: Alignment.center,
          //                 type: PageTransitionType.fade,
          //                 child: const BookingInsertScreen2(
          //                   // bookingBusiness: businessProvider.business,
          //                 )
          //             )
          //         );
          //       },
          //       child: Text(
          //         'Aggiungi',
          //         style: TextStyle(
          //           color: Colors.blue[500],
          //           fontWeight: FontWeight.w600,
          //           fontSize: 12,
          //         ),
          //       )
          //   ),
          // ),
        ],
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // _todayDate(),
          _dateBar(),
          FutureBuilder<Object>(
            future: Future.wait([a, b]),
            builder: (context, snapshot) {
              // int rColor = Random().nextInt(10);
              // print('fghf5fdf5f5f');
              // print(appointmentProvider.appointmentsDefinitive.length);
              if(snapshot.connectionState == ConnectionState.done && /*items.length*/bookingProvider.appointments!.length > 0) {
                return Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView(
                      // shrinkWrap: true,
                      children: [
                        // Container(height: 10, color: Color.fromRGBO(251, 253, 255, 1),),
                        Container(
                          padding: EdgeInsets.only(top: 5),
                          // color: Color.fromRGBO(251, 253, 255, 1),
                          child: NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowIndicator();
                              return true;
                            },
                            child: ListView.separated(
                              separatorBuilder: (BuildContext context, int index) => const Divider(
                                indent: 20,
                                endIndent: 20,
                              ),
                              padding: EdgeInsets.only(bottom: 20),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              // padding: EdgeInsets.symmetric(horizontal: 50),
                              itemCount: bookingProvider.appointments!.length,
                              // itemCount: items.length,
                              itemBuilder: (context, index) {
                                // int rColor = Random().nextInt(items.length);
                                int rColor = bookingProvider.appointments![index].is_guest == 0 ? 1 : 0;
                                return InkWell(
                                  onTap: (){
                                    // Booking booking = Booking(
                                    //   id: appointmentProvider.appointments![index]['booking_id'],
                                    //   isCanceled: appointmentProvider.appointments![index]['is_canceled'],
                                    //   guestName: appointmentProvider.appointments![index]['guest_name'],
                                    //   guestEmail: appointmentProvider.appointments![index]['guest_contact'],
                                    //   // note: myAppointments[index]['note'],
                                    //   // user_id: myAppointments[index]['user_id'].toString(),
                                    //   prestazione: Prestazione(
                                    //     duration: appointmentProvider.appointments![index]['prestazione_duration'],
                                    //     id: appointmentProvider.appointments![index]['prestazione_id'],
                                    //     image: appointmentProvider.appointments![index]['prestazione_image'],
                                    //     price: appointmentProvider.appointments![index]['prestazione_price'].toDouble(),
                                    //     title: appointmentProvider.appointments![index]['prestazione_title'],
                                    //     description: appointmentProvider.appointments![index]['prestazione_description'],
                                    //     business_id: appointmentProvider.appointments![index]['prestazione_business_id'],
                                    //   ),
                                    //   user: User(
                                    //     id: appointmentProvider.appointments![index]['user_id'],
                                    //     email: appointmentProvider.appointments![index]['user_email'],
                                    //     username: appointmentProvider.appointments![index]['user_username'],
                                    //     name: appointmentProvider.appointments![index]['user_name'],
                                    //     phone_number: appointmentProvider.appointments![index]['user_phone_number'],
                                    //     profile_image: appointmentProvider.appointments![index]['user_profile_image'] ?? 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                                    //     // description: appointments[i]['user_description'],
                                    //   ),
                                    //   begin_at: DateTime.tryParse(appointmentProvider.appointments![index]['begin_at'])/*.toLocal()*/,
                                    //   end_at: DateTime.tryParse(appointmentProvider.appointments![index]['begin_at']).add(Duration(minutes: appointmentProvider.appointments![index]['prestazione_duration'].toInt()))/*.toLocal()*/,
                                    //   created_at: DateTime.tryParse(appointmentProvider.appointments![index]['created_at']).toLocal()/*.add(Duration(hours: 2))*/,
                                    // );

                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        duration: const Duration(milliseconds: 500),
                                        alignment: Alignment.center,
                                        type: PageTransitionType.fade,
                                        // child: AppointmentDetailScreen(
                                        //   appointment: appointmentProvider.appointmentsDefinitive[i],
                                        // )
                                        child: BookingDetailScreen(
                                          // appointment: booking,
                                          booking: bookingProvider.appointments![index],
                                        )
                                      )
                                    );
                                  },
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            height: 110,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(_borderRadius),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    items[rColor].startColor,
                                                    items[rColor].endColor
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: items[rColor].endColor,
                                                  blurRadius: 12,
                                                  offset: Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            top: 0,
                                            child: CustomPaint(
                                              size: Size(100, 150),
                                              painter: CustomCardShapePainter(
                                                  _borderRadius,
                                                  items[rColor].startColor,
                                                  items[rColor].endColor
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Row(
                                              children: <Widget>[
                                                // Expanded(
                                                //   child: Image.asset(
                                                //     'assets/icon.png',
                                                //     height: 64,
                                                //     width: 64,
                                                //   ),
                                                //   flex: 2,
                                                // ),
                                                SizedBox(width: 10,),
                                                Container(
                                                  // padding: EdgeInsets.all(3),
                                                  width: 60,
                                                  height: 60,
                                                  child: Card(
                                                    semanticContainer: true,
                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(50))
                                                    ),
                                                    child: bookingProvider.appointments![index].is_guest == 0 ? FutureImage(
                                                      // imageUrl: "https://images.pexels.com/photos/9921261/pexels-photo-9921261.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
                                                      // imageUrl: appointmentProvider.appointments![index]['user_profile_image'] != null
                                                      //   ? appointmentProvider.appointments![index]['user_profile_image']
                                                      //   : "https://images.pexels.com/photos/9921261/pexels-photo-9921261.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
                                                      bookingProvider.appointments![index].user!.profile_image ?? "https://images.pexels.com/photos/9921261/pexels-photo-9921261.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
                                                      width: MediaQuery.of(context).size.width,
                                                    ) : Image.network(
                                                      // imageUrl: "https://images.pexels.com/photos/9921261/pexels-photo-9921261.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
                                                      // imageUrl: appointmentProvider.appointments![index]['user_profile_image'] != null
                                                      //   ? appointmentProvider.appointments![index]['user_profile_image']
                                                      //   : "https://images.pexels.com/photos/9921261/pexels-photo-9921261.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
                                                      "",
                                                      width: MediaQuery.of(context).size.width,
                                                      errorBuilder: (context, url, error) => Container(
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15,),
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Marquee(
                                                        child: bookingProvider.appointments![index].user.name != null ? Row(
                                                          children: [
                                                            // Text(
                                                              // items[index].name,
                                                            //   'Nome: ',
                                                            //   maxLines: 1,
                                                            //   style: TextStyle(
                                                            //     color: Colors.white,
                                                            //     fontFamily: 'Avenir',
                                                            //     fontWeight: FontWeight.w700,
                                                            //     fontSize: 15,
                                                            //   ),
                                                            // ),
                                                            Icon(
                                                              Icons.person,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width * 0.4,
                                                              child: Marquee(
                                                                child: Text(
                                                                  // items[index].name,
                                                                  bookingProvider.appointments![index].user.name ?? '',
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontFamily: 'Avenir',
                                                                    fontWeight: FontWeight.w700,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ) : Row(
                                                          children: [
                                                            // Text(
                                                            //   // items[index].name,
                                                            //   'Nome:',
                                                            //   maxLines: 1,
                                                            //   style: TextStyle(
                                                            //     color: Colors.white,
                                                            //     fontFamily: 'Avenir',
                                                            //     fontWeight: FontWeight.w500,
                                                            //     fontSize: 12,
                                                            //   ),
                                                            // ),
                                                            Icon(
                                                              Icons.person,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width * 0.4,
                                                              child: Marquee(
                                                                child: Text(
                                                                  bookingProvider.appointments![index].guestName!,
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontFamily: 'Avenir',
                                                                    fontWeight: FontWeight.w700,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 5,),
                                                      Row(
                                                        children: [
                                                          // Text(
                                                          //   // items[index].name,
                                                          //   'Telefono:',
                                                          //   maxLines: 1,
                                                          //   style: TextStyle(
                                                          //     color: Colors.white,
                                                          //     fontFamily: 'Avenir',
                                                          //     fontWeight: FontWeight.w500,
                                                          //     fontSize: 12,
                                                          //   ),
                                                          // ),
                                                          Icon(
                                                            bookingProvider.appointments![index].user.username != null ? Icons.account_circle_rounded : Icons.phone,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.4,
                                                            child: Marquee(
                                                              child: Text(
                                                                // items[index].category,
                                                                bookingProvider.appointments![index].user.username != null ? "@${bookingProvider.appointments![index].user.username!}"
                                                                  : "${bookingProvider.appointments![index].guestPhone}",
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontFamily: 'Avenir',
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 15
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4,),
                                                      Visibility(
                                                        visible: bookingProvider.appointments![index].is_guest == 1 && bookingProvider.appointments![index].guestEmail != '',
                                                        child: Row(
                                                          children: [
                                                            // Text(
                                                            //   // items[index].name,
                                                            //   'Email:',
                                                            //   maxLines: 1,
                                                            //   style: TextStyle(
                                                            //     color: Colors.white,
                                                            //     fontFamily: 'Avenir',
                                                            //     fontWeight: FontWeight.w500,
                                                            //     fontSize: 12,
                                                            //   ),
                                                            // ),
                                                            Icon(
                                                              Icons.email,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width * 0.4,
                                                              child: Marquee(
                                                                child: Text(
                                                                  // items[index].category,
                                                                  "${bookingProvider.appointments![index].guestEmail}",
                                                                  maxLines: 1,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontFamily: 'Avenir',
                                                                    fontWeight: FontWeight.w700,
                                                                    fontSize: 15
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      SizedBox(height: 5.5),
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            // padding: EdgeInsets.all(3),
                                                            width: 16,
                                                            height: 16,
                                                            child: Card(
                                                              semanticContainer: true,
                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                              elevation: 3,
                                                              margin: EdgeInsets.all(0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(5))
                                                              ),
                                                              child: FutureImage(
                                                                // imageUrl: "https://images.pexels.com/photos/3997397/pexels-photo-3997397.jpeg?auto=compress&cs=tinysrgb&w=600",
                                                                bookingProvider.appointments![index].prestazione!.image!,
                                                                width: MediaQuery.of(context).size.width,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * .4,
                                                            child: Marquee(
                                                              child: Text(
                                                                // items[index].location,
                                                                bookingProvider.appointments![index].prestazione!.title!,
                                                                maxLines: 1,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontFamily: 'Avenir',
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w700
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      SizedBox(height: 30),
                                                      Text(
                                                        // items[index].rating.toString(),
                                                        // '14.00',
                                                        bookingProvider.appointments![index].begin_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'Avenir',
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w700
                                                        ),
                                                      ),
                                                      Text(
                                                        // items[index].rating.toString(),
                                                        // '14.30',
                                                        bookingProvider.appointments![index].begin_at!.add(Duration(minutes: bookingProvider.appointments![index].prestazione!.duration!))/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'Avenir',
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w700),
                                                      ),
                                                      // RatingBar(rating: items[index].rating),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 2,)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Container(height: 20, color: Color.fromRGBO(251, 253, 255, 1),),
                      ],
                    )
                  ),
                );
              }
              else if(snapshot.connectionState == ConnectionState.done && bookingProvider.appointments!.length == 0) {
                return Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                        // Lottie.asset(
                        //   'assets/animations/16683-closed.json',
                        //   // 'assets/animations/51661-closed-tag.json',
                        //   height: MediaQuery.of(context).size.height * 0.35,
                        //   width: MediaQuery.of(context).size.height * 0.35,
                        //   // height: MediaQuery.of(context).size.height * 0.45,
                        //   // width: MediaQuery.of(context).size.height * 0.45,
                        //
                        // ),
                        SizedBox(height: MediaQuery.of(context).size.height * .035,),
                        Center(
                          child: Image.asset(
                            'assets/png/Saly-39.png',
                            height: MediaQuery.of(context).size.height * .25,
                            // width: MediaQuery.of(context).size.width * .7,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .05,),
                        Center(
                          child: Text(
                            // "Chiuso",
                            "Oggi non ci sono prenotazioni",
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.red[800],
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // else if(snapshot.connectionState == ConnectionState.waiting) {
              //   return Center(child: CircularProgressIndicator());
              // }
              else return SizedBox();
              // else return Center(child: Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),child: CircularProgressIndicator()));
            }
          )
        ],
      )
    );
  }
}

class PlaceInfo {
  final String name;
  final String category;
  final String location;
  final double rating;
  final Color startColor;
  final Color endColor;

  PlaceInfo(this.name, this.startColor, this.endColor, this.rating,
      this.location, this.category);
}

class CustomCardShapePainter extends CustomPainter {
  final double radius;
  final Color startColor;
  final Color endColor;

  CustomCardShapePainter(this.radius, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = 24.0;

    var paint = Paint();
    paint.shader = ui.Gradient.linear(
        Offset(0, 0), Offset(size.width, size.height), [
      HSLColor.fromColor(startColor).withLightness(0.8).toColor(),
      endColor
    ]);

    var path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, radius)
      ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
      ..lineTo(size.width - 1.5 * radius, 0)
      ..quadraticBezierTo(-radius, 2 * radius, 0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
