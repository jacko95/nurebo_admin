import 'dart:convert';
import 'dart:developer' as dev;

// //import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_edit_screen2.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo_admin/main.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking? booking;

  BookingDetailScreen({this.booking});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late SocketProvider socketProvider;
  Booking? booking;
  late BusinessProvider businessProvider;
  BookingProvider? bookingProvider;

  // Future cancelAppointment() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking");
  //
  //   Map/*<String, String>*/ body = {
  //     'booking_id': widget.appointment!.id,
  //   };
  //
  //   var response = await http.delete(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // print('getAppointmentsByDate.statusCode');
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   appointments = jsonData;
  //     // });
  //     Fluttertoast.showToast(
  //       msg: 'Appuntamento cancellato',
  //       backgroundColor: Colors.grey[700],
  //
  //     )..then((value) => Navigator.pop(context));
  //     // print('Appuntamento cancellato');
  //
  //     // appointmentProvider.cancelSlot(widget.appointment.id);
  //     // await appointmentProvider.init(businessProvider.business.id, socketProvider.socketAppointments);
  //     // appointmentProvider.appointmentsDefinitive.clear();
  //
  //     // print(jsonData);
  //     // print('appointments');
  //     // print(appointments.toString());
  //     return jsonData;
  //   }
  // }

  void _showDeletingDialog(String module, BuildContext context) {
    // BookingProvider? bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Cancellare appuntamento',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Cancella',
            confirmCallback: () async {
              if(widget.booking!.is_guest == 0){
                // cancelAppointment();
                // print('widget.appointment.prestazione.id');
                // print(widget.booking!.prestazione!.id);
                int res = await socketProvider.cancelBooking(widget.booking!, businessProvider.business!, context);

                //todo:cancellarlo anche dal socketprovider
                if(res == 1){
                  setState(() {
                    booking!.isCanceled = 1;
                  });

                  // (bookingProvider!.tasks0 = bookingProvider!.getDateBusinessAppointments(businessProvider.business!.id, context)).then((value) =>
                  //   (bookingProvider!.tasks1 = bookingProvider!.getOccupiedDates(businessProvider.business!.id)).then((value) async {
                  //     // setState(() {
                  //       bookingProvider!.slots = bookingProvider!.createSlots(
                  //         bookingProvider!.occupiedDates,
                  //         bookingProvider!.appointments,
                  //         bookingProvider!.selectedDate.day,
                  //         bookingProvider!.selectedDate.month,
                  //         bookingProvider!.selectedDate.year,
                  //         socketProvider.socketAppointments,
                  //         context
                  //       );
                  //     // });
                  //   })
                  // );
                  // Fluttertoast.showToast(
                  //   msg: 'Appuntamento cancellato',
                  //   backgroundColor: Colors.grey[700],
                  // )..then((value) => Navigator.pop(context));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Appuntamento cancellato',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // backgroundColor: Colors.red,
                    backgroundColor: Colors.green,
                  ));
                  Navigator.pop(context);
                }
                else if(res == 0){
                  Fluttertoast.showToast(
                    msg: 'Errore',
                    backgroundColor: Colors.grey[700],
                  );
                }
                // print('Appuntamento cancellato');

                // socketProvider.myAppointments.clear();
                // socketProvider.deleteAllBookings();
                // Future.wait([
                //   socketProvider.getBusinessAppointments(businessProvider.business),
                // ]);
                // bookingProvider!.appointments!.clear();
                // Future.wait([
                //   bookingProvider!.getAppointmentsByDate(businessProvider.business!.id, context),
                //   bookingProvider!.getGuestAppointmentsByDate(businessProvider.business!.id, context),
                // ]);
              }
              // else if (widget.booking!.is_guest == 1){
              //   // cancelAppointment();
              //   // print('widget.appointment.prestazione.id');
              //   // print(widget.booking!.prestazione!.id);
              //   int res = await bookingProvider!.cancelGuestBooking(widget.booking!, businessProvider.business!, context);
              //
              //   //todo:cancellarlo anche dal socketprovider
              //   if(res == 1){
              //     setState(() {
              //       booking!.isCanceled = 1;
              //     });
              //     // Fluttertoast.showToast(
              //     //   msg: 'Appuntamento cancellato',
              //     //   backgroundColor: Colors.grey[700],
              //     // )..then((value) => Navigator.pop(context));
              //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //       content: Row(
              //         children: [
              //           Icon(
              //             Icons.delete_outline,
              //             color: Colors.white,
              //           ),
              //           SizedBox(width: 10),
              //           Text(
              //             'Appuntamento cancellato',
              //             style: TextStyle(
              //               fontWeight: FontWeight.w600,
              //               color: Colors.white,
              //             ),
              //           ),
              //         ],
              //       ),
              //       // backgroundColor: Colors.red,
              //       backgroundColor: Colors.green,
              //     ));
              //     Navigator.pop(context);
              //   }
              //   else if(res == 0){
              //     Fluttertoast.showToast(
              //       msg: 'Errore',
              //       backgroundColor: Colors.grey[700],
              //     );
              //   }
              //
              //   bookingProvider!.appointments!.clear();
              //   Future.wait([
              //     bookingProvider!.getAppointmentsByDate(businessProvider.business!.id, context),
              //     bookingProvider!.getGuestAppointmentsByDate(businessProvider.business!.id, context),
              //   ]);
              // }
            },

            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    booking = widget.booking;

    // dev.log(
    //   'mwidget.booki',
    //   name: 'myaegory',
    //   error: jsonEncode(widget.booking),
    // );
  }

  @override
  void dispose() {
    super.dispose();
    // bookingProvider!.appointments!.clear();
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    bookingProvider = Provider.of<BookingProvider>(context, listen: true);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color(0xFFF6F7F9),
        // statusBarColor: MaterialColors.blue,
        // systemNavigationBarColor: MaterialColors.blue
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF6F7F9),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue[500], //change your color here
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: IconButton(
              icon: Icon(
                // Icons.arrow_back,
                Icons.arrow_back_ios_new,
                size: 16,
                // size: 29,
                color: Colors.grey[500],
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),
          centerTitle: true,
          elevation: 0,
          // foregroundColor: Colors.blue,
          // backgroundColor: Colors.white,
          // backgroundColor: Color(0xFFF6F7F9),
          backgroundColor: Colors.transparent,
          // centerTitle: true,
          // title: Text(
          //   'Prenotazioni',
          //   style: TextStyle(
          //       color: Colors.blue,
          //       // color: Colors.grey[800],
          //       fontWeight: FontWeight.w600,
          //       fontSize: 16
          //   ),
          // ),
          actions: [
            Visibility(
              visible: widget.booking!.is_guest == 1,
              child: Container(
                // height: MediaQuery.of(context).size.width * 0.1,
                // width: MediaQuery.of(context).size.width * 0.4,
                margin: EdgeInsets.only(
                    // left: MediaQuery.of(context).size.width * 0.2,
                    right: 10,
                    // right: MediaQuery.of(context).size.width * 0.2,
                    top: 10,
                    bottom: 10
                ),
                child: ElevatedButton(
                // child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.blue[500],
                        // backgroundColor: Colors.white,
                        // backgroundColor: Colors.grey[300],
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * .25,
                            MediaQuery.of(context).size.width * .05
                        ),
                        alignment: Alignment.center
                    ),
                    onPressed: (){
                      Navigator.push(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: BookingEditScreen2(
                            booking: booking!,
                          )
                        )
                      );
                    },
                    child: Text(
                      'Modifica',
                      style: TextStyle(
                        // color: Colors.blue[500],
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    )
                ),
              ),
            ),
          ],
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
              children: [
                // Container(
                //   color: Color(0xFFF6F7F9),
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 10, top: 10),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.all(Radius.circular(10)),
                //           child: Container(
                //             color: Colors.transparent,
                //             // color: Colors.grey[300],
                //
                //             child: IconButton(
                //               onPressed: (){
                //                 Navigator.pop(context);
                //               },
                //               padding: EdgeInsets.all(0),
                //
                //               icon: Icon(
                //                 // Icons.arrow_back,
                //                 // Icons.clear,
                //                 Icons.arrow_back_ios_outlined,
                //                 size: 24,
                //                 // color: CupertinoColors.black,
                //                 color: Colors.grey[600],
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                  // color: Color(0xFFF6F7F9),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            // SizedBox(
                            //   height: 0,
                            // ),
                            
                            /*Container(
                              margin: EdgeInsets.only(top: 20),
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                image: DecorationImage(
                                  image: widget.booking!.prestazione!.image != null && widget.booking!.prestazione!.image != '' ? CachedNetworkImageProvider(
                                    widget.booking!.prestazione!.image!,
                                    errorListener: () => const SizedBox(),
                                  ) : CachedNetworkImageProvider(
                                      businessProvider.business!.profile_image!,
                                    errorListener: () => const SizedBox(),
                                  ),
                                  fit: BoxFit.cover
                                ),
                              ),
                            ),*/
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: FutureImage(
                                  widget.booking!.prestazione!.image != null && widget.booking!.prestazione!.image != ''
                                      ? widget.booking!.prestazione!.image!
                                      : businessProvider.business!.profile_image!,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),

                            ClipPath(
                              clipper: TicketTopClipper(),
                              child: Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GradientText(
                                      businessProvider.business!.name != null ? businessProvider.business!.name! : '',
                                      // 'A partire da € 60,00',
                                      maxLines: 1,
                                      // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                      // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Color(0xff8921aa),
                                          Color(0xffDA44bb),
                                          // Color(0xffDA44bb)
                                        ]
                                      ),
                                      // gradient: LinearGradient(
                                      //     begin: Alignment.bottomLeft,
                                      //     end: Alignment.topRight,
                                      //     colors: [
                                      //       Colors.blue[500],
                                      //       Color(0xffDA44bb),
                                      //
                                      //       Color(0xff8921aa),
                                      //     ]
                                      // ),
                                      style: TextStyle(
                                          color: Colors.blue[500],
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    Marquee(
                                      child: Text(
                                        widget.booking!.prestazione!.title ?? '',
                                        // widget.appointment.business.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          // color: Colors.grey[600]
                                          color: Colors.blue[500]
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 4,),
                                    // Text(
                                    //   // widget.appointment.prestazione.title,
                                    //   '@' + widget.appointment.user.username,
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.w800,
                                    //       fontSize: 14,
                                    //       color: Colors.grey[700]
                                    //   ),
                                    // ),
                                    // SizedBox(height: 6,),
                                    // Text(
                                    //   widget.appointment.business.address ?? ' ',
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.w800,
                                    //       fontSize: 11,
                                    //       color: Colors.grey[500]
                                    //   ),
                                    // ),
                                    SizedBox(height: 30,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat.yMMMMEEEEd('it_IT').format(widget.booking!.begin_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toUpperCase(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[900]
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.grey[700],
                                              size: 18,
                                            ),
                                            SizedBox(width: 3,),
                                            Text(
                                              widget.booking!.begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16) + ' - ' + widget.booking!.end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12,
                                                  color: Colors.grey[700]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 30,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'ID:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: Marquee(
                                            child: Row(
                                              children: [
                                                Text(
                                                  widget.booking!.id ?? '',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: Colors.grey[800]
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    //TODO: INSERIRE ANCHE LE INFORMAZIONI SUL PAGAMENTO: TIPO IL METODO E QUANDO è STATO EFFETTUATO
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Utente:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       widget.booking!.user!.username != null
                                    //         ? '@' + widget.booking!.user!.username!
                                    //         : '-',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           color: Colors.grey[600]
                                    //           // color: Colors.blue[500]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Utente:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                  duration: const Duration(milliseconds: 500),
                                                  alignment: Alignment.center,
                                                  type: PageTransitionType.fade,
                                                  child: UserProfileScreen(
                                                    userId: widget.booking!.user.id!,
                                                    // isTab: false,
                                                  )
                                              ),
                                            );
                                          },
                                          child: Text(
                                            // widget.booking!.user!.name == null && widget.booking!.user!.id == null ? widget.booking!.guestName! : '-',
                                            /*widget.booking!.is_guest == 1
                                              ? widget.booking!.guestName!
                                              : widget.booking!.is_guest == 0 &&*/ widget.booking!.user.name != null
                                                ? widget.booking!.user.name!
                                              : '-',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                // color: Colors.grey[800]
                                                color: Colors.blue[500]
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    widget.booking!.guestPhone != null ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Telefono:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          widget.booking!.guestPhone!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                            // color: Colors.blue[500]
                                          ),
                                        ),
                                      ],
                                    ) : SizedBox(),
                                    widget.booking!.guestPhone != null ? SizedBox(
                                      height: 10,
                                    ) : SizedBox(),

                                    widget.booking!.guestEmail != null ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Email:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          widget.booking!.guestEmail!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                            // color: Colors.blue[500]
                                          ),
                                        ),
                                      ],
                                    ) : SizedBox(),
                                    widget.booking!.guestEmail != null ? SizedBox(
                                      height: 10,
                                    ) : SizedBox(),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Prezzo:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                            !widget.booking!.prestazione!.is_price_range ? '€ ${NumberFormat.currency(
                                            // customPattern: '#,##',
                                              decimalDigits: 2,
                                              symbol: '',
                                              locale: 'IT_it'
                                          ).format(widget.booking!.prestazione!.price)}' : '€ ${NumberFormat.currency(
                                              // customPattern: '#,##',
                                                decimalDigits: 2,
                                                symbol: '',
                                                locale: 'IT_it'
                                            ).format(widget.booking!.prestazione!.price_min)} - € ${NumberFormat.currency(
                                              // customPattern: '#,##',
                                                decimalDigits: 2,
                                                symbol: '',
                                                locale: 'IT_it'
                                            ).format(widget.booking!.prestazione!.price_max)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              // color: Colors.grey[800]
                                              color: Colors.green[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Durata:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                          widget.booking!.prestazione!.duration.toString()
                                          + ' minuti',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                              // color: Colors.blue[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    widget.booking!.is_guest == 1 ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Text(
                                            'Creato il:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          child: Marquee(
                                            child: Text(
                                              DateFormat.yMMMMd('it_IT').format(widget.booking!.created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                              + ' alle ' + widget.booking!.created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                  color: Colors.grey[800]
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Text(
                                            'Acquistato il:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMMd('it_IT').format(widget.booking!.created_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                          + ' alle ' + widget.booking!.created_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'Valido fino al:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${DateFormat.yMMMMd('it_IT').format(widget.booking!.end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)} alle ${widget.booking!.end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)}',
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 30,
                                    ),

                                    SizedBox(
                                      height: 30,
                                    ),
                                    generateDashedDivider(
                                        MediaQuery.of(context).size.width * 0.68
                                    )
                                    // Image.network(
                                    //     widget.singleEventTicket.qr_code
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            ClipPath(
                              clipper: TicketBottomClipper(),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                widget.booking!.isCanceled == 1 ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Questa prenotazione è stata cancellata',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // color: Colors.blue[500],
                        color: Colors.red[500],
                        // color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ) : DateTime.now().isBefore(widget.booking!.begin_at!) ? Column(
                  children: [
                    // Container(
                    //   // height: MediaQuery.of(context).size.width * 0.1,
                    //   // width: MediaQuery.of(context).size.width * 0.4,
                    //   margin: EdgeInsets.only(
                    //       left: MediaQuery.of(context).size.width * 0.2,
                    //       right: MediaQuery.of(context).size.width * 0.2,
                    //       top: 5,
                    //       bottom: 5
                    //   ),
                    //   child: ElevatedButton(
                    //       style: OutlinedButton.styleFrom(
                    //           padding: EdgeInsets.zero,
                    //           backgroundColor: Colors.blue[500],
                    //           // backgroundColor: Colors.white,
                    //           minimumSize: Size(
                    //               MediaQuery.of(context).size.width * .5,
                    //               MediaQuery.of(context).size.width * .1
                    //           ),
                    //           alignment: Alignment.center
                    //       ),
                    //       onPressed: (){
                    //
                    //       },
                    //       child: Text(
                    //         'Modifica',
                    //         style: TextStyle(
                    //           // color: Colors.blue[500],
                    //           // color: Colors.red[500],
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.w800,
                    //           fontSize: 13,
                    //         ),
                    //       )
                    //   ),
                    // ),
                    Container(
                      // height: MediaQuery.of(context).size.width * 0.1,
                      // width: MediaQuery.of(context).size.width * 0.4,
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.2,
                          right: MediaQuery.of(context).size.width * 0.2,
                          top: 5,
                          bottom: 5
                      ),
                      child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.red[500],
                              // backgroundColor: Colors.white,
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * .5,
                                MediaQuery.of(context).size.width * .1
                              ),
                              alignment: Alignment.center
                          ),
                          onPressed: (){
                            _showDeletingDialog(
                              // "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento e rimborsare il cliente"
                              "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento",
                              context
                            );
                          },
                          child: Text(
                            'Cancella',
                            style: TextStyle(
                              // color: Colors.blue[500],
                              // color: Colors.red[500],
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          )
                      ),
                    ),
                  ],
                ) : DateTime.now().isAfter(widget.booking!.begin_at!) ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Questa prenotazione è già stata effettuata',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[500],
                        // color: Colors.red[500],
                        // color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ) : SizedBox(),
                SizedBox(height: 50,),
              ],
            ),
        ),
      )
    );
  }
}

class TicketTopClipper extends CustomClipper<Path> {
  double radius = 15;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(radius, size.height - radius, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(size.width - radius, size.height - radius,
        size.width, size.height - radius);
    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget generateDashedDivider(double width) {
  int n = width ~/ 5;
  return Marquee(
    child: Row(
      children: List.generate(
          n,
              (index) => (index % 2 == 0)
              ? Container(
            height: 2,
            width: width / n,
            color: Color(0xFFE4E4E4),
          )
              : SizedBox(
            width: width / n,
          )),
    ),
  );
}

class TicketBottomClipper extends CustomClipper<Path> {
  double radius = 15;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, radius);
    path.quadraticBezierTo(size.width - radius, radius, size.width - radius, 0);
    path.lineTo(radius, 0);
    path.quadraticBezierTo(radius, radius, 0, radius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
