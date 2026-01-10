import 'dart:convert';

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
import 'package:nurebo_admin/utils/utils.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key,});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late SocketProvider socketProvider;
  late BusinessProvider businessProvider;
  late BookingProvider appointmentProvider;


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
            appointmentProvider.selectedDate = date;
          });
          // print(DateFormat.yMMMMd('it_IT').format(appointmentProvider.selectedDate));
          appointmentProvider.timetableDay!.clear();
          // print('openingDates00');
          // print(openingDates.toString());
          appointmentProvider.openingDates.clear();
          appointmentProvider.closingDates.clear();
          appointmentProvider.intervalliDaMezzoraPerApertura.clear();
          appointmentProvider.intervalliDaMezzoraPerAperturaBegin.clear();
          appointmentProvider.intervalliDaMezzoraPerAperturaEnd.clear();
          // occupiedDates.clear();
          // appointments.clear();
          appointmentProvider.appointmentsDefinitive.clear();

          await appointmentProvider.getTimetableDay(businessProvider.business!.id, appointmentProvider.selectedDate.weekday).then((value) =>
              appointmentProvider.getDateBusinessAppointments(businessProvider.business!.id, context).then((value){
                appointmentProvider.createSlots(
                  appointmentProvider.occupiedDates,
                  appointmentProvider.appointments,
                  appointmentProvider.selectedDate.day,
                  appointmentProvider.selectedDate.month,
                  appointmentProvider.selectedDate.year,
                  socketProvider.socketAppointments,
                  context
                );
              })
          );

          // occupiedDates.clear();
          // appointments.clear();
          // getAppointmentsByDate();
          // createSlots(occupiedDates, appointments);
          // print('socketAppointments456');
          // print(socketAppointments);
        },
      ),
    );
  }

  // _todayDate() {
  //   return Container(
  //     color: Colors.white,
  //     padding: EdgeInsets.only(top: 10, left: 20, bottom: 10),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               // StringUtils.capitalize(DateFormat.EEEE('it_IT').format(DateTime.now())),
  //               DateFormat.EEEE('it_IT').format(DateTime.now()).capitalize,
  //               style: TextStyle(
  //                   color: Colors.blue[500],
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.w800
  //               ),
  //             ),
  //             // SizedBox(width: 10,),
  //             Text(
  //               DateFormat.yMMMMd('it_IT').format(DateTime.now()),
  //               style: TextStyle(
  //                   color: Colors.grey[600],
  //                   fontSize: 25,
  //                   fontWeight: FontWeight.w800
  //               ),
  //             ),
  //           ],
  //         ),
  //         // OutlinedButton(
  //         //   onPressed: (){
  //         //
  //         //   },
  //         // )
  //       ],
  //     ),
  //   );
  // }
  //
  // _rowDate(int i0, int i, int type){
  //   return Row(
  //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text(
  //         (openingDates[i0].add(Duration(minutes: i * 30))).toString().substring(11, 16)
  //             + ' - ' +
  //             (openingDates[i0].add(Duration(minutes: (i * 30) + 30))).toString().substring(11, 16),
  //         style: TextStyle(
  //           // color: Colors.blue[500],
  //           color: Colors.grey[700],
  //           fontWeight: FontWeight.w800,
  //           fontSize: 14,
  //         ),
  //       ),
  //       SizedBox(width: 50,),
  //       Container(
  //         width: MediaQuery.of(context).size.width * 0.4,
  //         // height: 30,
  //         child: type == 0
  //             ? OutlinedButton(
  //           // style: ButtonStyle(
  //           //   padding: EdgeInsets.all(0),
  //           // ),
  //             style: OutlinedButton.styleFrom(
  //                 padding: EdgeInsets.zero,
  //                 backgroundColor: Colors.grey[50],
  //                 // backgroundColor: Colors.white,
  //                 // minimumSize: Size(50, 30),
  //                 alignment: Alignment.center
  //             ),
  //             onPressed: () {
  //               // print('aaaa');
  //               // print(openingDates[i0].add(Duration(minutes: i * 30)));
  //               // print(openingDates[i0].add(Duration(minutes: i * 30 + 30)));
  //               // if(!isOccupied) {
  //               setOccupiedDates(
  //                 openingDates[i0].add(Duration(minutes: i * 30)),
  //                 openingDates[i0].add(Duration(minutes: i * 30 + 30))
  //               );
  //                 //   appointmentProvider.appointmentsDefinitive[i0].begin_at,
  //                 //   appointmentProvider.appointmentsDefinitive[i0].end_at);
  //
  //               getOccupiedDates();
  //               // }
  //               // else if(isOccupied){
  //               //   print('ciao');
  //               //   deleteOccupiedDates(
  //               //       openingDates[i0].add(Duration(minutes: i * 30)).toUTC(),
  //               //       openingDates[i0].add(Duration(minutes: i * 30 + 30)).toUTC()
  //               //   );
  //               //   getOccupiedDates();
  //               // }
  //             },
  //             child: Text(
  //               // 'Prenota',
  //                 'Occupato',
  //                 style:TextStyle(
  //                   // color: Colors.blue[500],
  //                   color: Colors.blue[500],
  //                   fontWeight: FontWeight.w800,
  //                   fontSize: 12,
  //                 ) /* : Text(
  //                                     'Prenotato',
  //                                     style: TextStyle(
  //                                       // color: Colors.blue[500],
  //                                       color: Colors.blue[500],
  //                                       fontWeight: FontWeight.w800,
  //                                       fontSize: 12,
  //                                     ),
  //                                   )*//* : Icon(
  //                                   Icons.check,
  //                                   color: Colors.white,
  //                                 )*/
  //               /*: Text(
  //                                       'Acquistato',
  //                                       style: TextStyle(
  //                                         // color: Colors.blue[500],
  //                                         color: Colors.blue[500],
  //                                         fontWeight: FontWeight.w800,
  //                                         fontSize: 12,
  //                                     ),
  //                                   ),*/
  //             )
  //         )
  //             : type == 1
  //             ? OutlinedButton(
  //           // style: ButtonStyle(
  //           //   padding: EdgeInsets.all(0),
  //           // ),
  //             style: OutlinedButton.styleFrom(
  //                 padding: EdgeInsets.zero,
  //                 backgroundColor: Colors.blue,
  //                 // backgroundColor: Colors.white,
  //                 // minimumSize: Size(50, 30),
  //                 alignment: Alignment.center
  //             ),
  //             onPressed: () {
  //               // print('aaaa');
  //               // print(openingDates[i0].add(Duration(minutes: i * 30)));
  //               // print(openingDates[i0].add(Duration(minutes: i * 30 + 30)));
  //
  //               // deleteOccupiedDates(
  //               //     openingDates[i0].add(Duration(minutes: i * 30)),
  //               //     openingDates[i0].add(Duration(minutes: i * 30 + 30))
  //               //   // appointmentProvider.appointmentsDefinitive[i0].begin_at,
  //               //   // appointmentProvider.appointmentsDefinitive[i0].end_at
  //               // );
  //               // getOccupiedDates();
  //               setState(() {
  //                 deleteOccupiedDates(
  //                     openingDates[i0].add(Duration(minutes: i * 30)),
  //                     openingDates[i0].add(Duration(minutes: i * 30 + 30))
  //                   // appointmentProvider.appointmentsDefinitive[i0].begin_at,
  //                   // appointmentProvider.appointmentsDefinitive[i0].end_at
  //                 ).then((value) => getOccupiedDates().then((_) => createSlots(
  //                     occupiedDates,
  //                     appointments,
  //                     _selectedDate.day,
  //                     _selectedDate.month,
  //                     _selectedDate.year
  //                 )));
  //                 // appointmentProvider.appointmentsDefinitive.removeWhere((e) => /*e.type == 1 &&*/
  //                 // e.begin_at == openingDates[i0].add(Duration(minutes: i * 30))
  //                 //     && e.end_at == openingDates[i0].add(Duration(minutes: i * 30 + 30)));
  //               });
  //
  //             },
  //             child: Text(
  //               // 'Prenota',
  //               'Disponibile',
  //               style: TextStyle(
  //                 // color: Colors.blue[500],
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w800,
  //                 fontSize: 12,
  //               ),
  //             )/* : Text(
  //                       'Prenotato',
  //                       style: TextStyle(
  //                         // color: Colors.blue[500],
  //                         color: Colors.blue[500],
  //                         fontWeight: FontWeight.w800,
  //                         fontSize: 12,
  //                       ),
  //                     )*//* : Icon(
  //                     Icons.check,
  //                     color: Colors.white,
  //                   )*/
  //           /*: Text(
  //                                     'Acquistato',
  //                                     style: TextStyle(
  //                                       // color: Colors.blue[500],
  //                                       color: Colors.blue[500],
  //                                       fontWeight: FontWeight.w800,
  //                                       fontSize: 12,
  //                                   ),
  //                                 ),*/
  //         )
  //             : null,
  //       )
  //     ],
  //   );
  // }
  //
  // _rowPrenotation(int i0, int i, Appointment appointment){
  //   return Row(
  //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text(
  //         appointment.begin_at.toString().substring(11, 16)
  //         + ' - ' +
  //         appointment.end_at.toString().substring(11, 16),
  //         style: TextStyle(
  //           // color: Colors.blue[500],
  //           color: Colors.grey[700],
  //           fontWeight: FontWeight.w800,
  //           fontSize: 14,
  //         ),
  //       ),
  //       SizedBox(width: 50,),
  //       Container(
  //         width: MediaQuery.of(context).size.width * 0.4,
  //         // height: 30,
  //         child: OutlinedButton(
  //             style: OutlinedButton.styleFrom(
  //                 padding: EdgeInsets.zero,
  //                 backgroundColor: Colors.grey[50],
  //                 // backgroundColor: Colors.white,
  //                 // minimumSize: Size(50, 30),
  //                 alignment: Alignment.center
  //             ),
  //             onPressed: () {
  //             },
  //             child: Text(
  //               'Prenota',
  //                 // appointment.price.toString(),
  //                 style:TextStyle(
  //                   // color: Colors.blue[500],
  //                   color: Colors.blue[500],
  //                   fontWeight: FontWeight.w800,
  //                   fontSize: 12,
  //                 )
  //             )
  //         ),
  //       )
  //     ],
  //   );
  // }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    appointmentProvider = Provider.of<BookingProvider>(context, listen: false);

    // appointmentProvider.getTimetableDay(businessProvider.business.id, appointmentProvider.selectedDate.weekday);
    //
    // (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business.id, )).then((value) =>
    //   (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business.id, )).then((value) async {
    //     appointmentProvider.slots = await appointmentProvider.createSlots(
    //       appointmentProvider.occupiedDates,
    //       appointmentProvider.appointments,
    //       appointmentProvider.selectedDate.day,
    //       appointmentProvider.selectedDate.month,
    //       appointmentProvider.selectedDate.year,
    //       socketProvider.socketAppointments
    //     );
    //   })
    // );
    //
    // appointmentProvider.openingDates.clear();
    // appointmentProvider.closingDates.clear();

    Future.wait([
      appointmentProvider.init(businessProvider.business!.id, socketProvider.socketAppointments, context)
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    appointmentProvider.timetableDay!.clear();
    // print('openingDates00');
    // print(openingDates.toString());
    appointmentProvider.openingDates.clear();
    appointmentProvider.closingDates.clear();
    appointmentProvider.intervalliDaMezzoraPerApertura.clear();
    appointmentProvider.intervalliDaMezzoraPerAperturaBegin.clear();
    appointmentProvider.intervalliDaMezzoraPerAperturaEnd.clear();
    // occupiedDates.clear();
    // appointments.clear();
    appointmentProvider.appointmentsDefinitive.clear();
    // setState(() {
    appointmentProvider.selectedDate = DateTime.now();
    // });
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    appointmentProvider = Provider.of<BookingProvider>(context, listen: true);

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
            //                 child: const BookingInsertScreen(
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
                future: Future.wait([appointmentProvider.tasks0/*.then((value) => value!)*/, appointmentProvider.tasks1/*.then((value) => value!)*/, appointmentProvider.slots/*.then((value) => value!)*/]),
                builder: (context, snapshot) {
                  if(/*snapshot.connectionState == ConnectionState.done &&*/ appointmentProvider.appointmentsDefinitive.length > 0) {
                    return Expanded(
                      child: NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: ListView(
                            // shrinkWrap: true,
                            children: [
                              Container(height: 10, color: Color.fromRGBO(251, 253, 255, 1),),
                              Container(
                                color: Color.fromRGBO(251, 253, 255, 1),
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
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    // padding: EdgeInsets.symmetric(horizontal: 50),
                                    // itemCount: openingDates.length,
                                    itemCount: 1,
                                    itemBuilder: (context, i0) {
                                      // for(var e in appointments) {
                                      //   if(/*(*/DateTime.tryParse(e['begin_at']).toLocal().isBefore(openingDates[i0].add(Duration(minutes: i * 30 + 30))) /*||
                                      //                     DateTime.tryParse(e['begin_at']).toLocal().isAtSameMomentAs(openingDates[i0].add(Duration(minutes: i * 30 + 30))))*/
                                      //       && /*(*/DateTime.tryParse(e['begin_at']).toLocal().add(Duration(minutes: i * 30 + e['duration'].toInt())).isAfter(openingDates[i0].add(Duration(minutes: i * 30 + 30))) /*||
                                      //                         DateTime.tryParse(e['begin_at']).toLocal().add(Duration(minutes: i * 30 + e['duration'].toInt())).isAtSameMomentAs(openingDates[i0].add(Duration(minutes: i * 30 + 30))))*/) {
                                      //     // isUserAppointment = true;
                                      //     isOccupied = 3;
                                      //     print('begin_at');
                                      //     print(
                                      //         DateTime.tryParse(e['begin_at']).toLocal().toString().substring(11, 16)
                                      //     );
                                      //   }
                                      // }

                                      // print('i0');
                                      // print(i0.toString());
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        // padding: EdgeInsets.symmetric(horizontal: 50),
                                        // itemCount: intervalliDaMezzoraPerApertura[i0],
                                        itemCount: appointmentProvider.appointmentsDefinitive.length,
                                        itemBuilder: (context, i) {
                                          if(appointmentProvider.appointmentsDefinitive[i].type == 2){
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  i > 0 && (appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/.toString().substring(11, 16) !=
                                                      appointmentProvider.appointmentsDefinitive[i-1].begin_at!/*.tolocal()*/.toString().substring(11, 16) ||
                                                      appointmentProvider.appointmentsDefinitive[i].end_at!/*.tolocal()*/.toString().substring(11, 16) !=
                                                    appointmentProvider.appointmentsDefinitive[i-1].end_at!/*.tolocal()*/.toString().substring(11, 16)) ? Text(
                                                    appointmentProvider.appointmentsDefinitive[i].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)
                                                        + ' - ' +
                                                        appointmentProvider.appointmentsDefinitive[i].end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                    style: TextStyle(
                                                      // color: Colors.blue[500],
                                                      color: DateTime.now()/*.tolocal()*/.isAfter(appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/) &&
                                                          DateTime.now()/*.tolocal()*/.isBefore(appointmentProvider.appointmentsDefinitive[i].end_at!/*.tolocal()*/)
                                                          ? Colors.blue[500] : Colors.grey[700],
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ) : i == 0 ? Text(
                                                    appointmentProvider.appointmentsDefinitive[i].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)
                                                        + ' - ' +
                                                        appointmentProvider.appointmentsDefinitive[i].end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                    style: TextStyle(
                                                      // color: Colors.blue[500],
                                                      color: DateTime.now()/*.tolocal()*/.isAfter(appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/) &&
                                                          DateTime.now()/*.tolocal()*/.isBefore(appointmentProvider.appointmentsDefinitive[i].end_at!/*.tolocal()*/)
                                                          ? Colors.blue[500] : Colors.grey[700],
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ) : const Text('                        '),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.187,
                                                  ),
                                                  InkWell(
                                                    onTap: (){
                                                      Booking ff = Booking(
                                                        id: appointmentProvider.appointmentsDefinitive[i].id,
                                                        user: appointmentProvider.appointmentsDefinitive[i].user,
                                                        prestazione: appointmentProvider.appointmentsDefinitive[i].prestazione,
                                                        is_guest: appointmentProvider.appointmentsDefinitive[i].is_guest,
                                                        isCanceled: appointmentProvider.appointmentsDefinitive[i].isCanceled,
                                                        type: appointmentProvider.appointmentsDefinitive[i].type,
                                                        begin_at: appointmentProvider.appointmentsDefinitive[i].begin_at!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
                                                        end_at: appointmentProvider.appointmentsDefinitive[i].end_at!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
                                                        created_at: appointmentProvider.appointmentsDefinitive[i].created_at,
                                                      );
                                                      // ff = appointmentProvider.appointmentsDefinitive[i];
                                                      // appointmentProvider.appointmentsDefinitive[i].begin_at!.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours));
                                                      // ff.begin_at!.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours));
                                                      // appointmentProvider.appointmentsDefinitive[i].end_at!.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours));
                                                      // ff.end_at!.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours));

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
                                                            booking: ff,
                                                          )
                                                        )
                                                      );
                                                    },
                                                    child: Card(
                                                      margin: EdgeInsets.all(0),
                                                      borderOnForeground: true,
                                                      // shadowColor: Colors.blue,
                                                      color: Colors.blue[400],
                                                      child: Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                        // color: Colors.red,
                                                        // height: MediaQuery.of(context).size.width * 0.145,
                                                        height: MediaQuery.of(context).size.width * 0.17,
                                                        width: MediaQuery.of(context).size.width * 0.4,
                                                        // margin: EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 5),
                                                        // child: OutlinedButton(
                                                        //     style: OutlinedButton.styleFrom(
                                                        //         padding: EdgeInsets.zero,
                                                        //         backgroundColor: Colors.grey[50],
                                                        //         // backgroundColor: Colors.white,
                                                        //         // minimumSize: Size(50, 30),
                                                        //         alignment: Alignment.center
                                                        //     ),
                                                        //     onPressed: (){
                                                        //         print("aprire un dialog che consente l'annullamento con il conseguente rimborso");
                                                        //     },
                                                        //     child: Text(
                                                        //       appointmentProvider.appointmentsDefinitive[i].begin_at.toString().substring(11, 16),
                                                        //       style: TextStyle(
                                                        //         // color: Colors.blue[500],
                                                        //         color: Colors.grey[700],
                                                        //         fontWeight: FontWeight.w800,
                                                        //         fontSize: 14,
                                                        //       ),
                                                        //     )
                                                        // ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                              // padding: EdgeInsets.all(3),
                                                              width: 40,
                                                              height: 40,
                                                              child: Card(
                                                                semanticContainer: true,
                                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                elevation: 3,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(4))
                                                                ),
                                                                // color: Colors.red,
                                                                // child: CircleAvatar(
                                                                child: FutureImage(
                                                                  // appointmentProvider.appointmentsDefinitive[i].user!.profile_image!,
                                                                  appointmentProvider.appointmentsDefinitive[i].prestazione!.image != 'null' && appointmentProvider.appointmentsDefinitive[i].prestazione!.image != '' && appointmentProvider.appointmentsDefinitive[i].prestazione!.image != null
                                                                    ? appointmentProvider.appointmentsDefinitive[i].prestazione!.image!
                                                                    : businessProvider.business!.profile_image!,
                                                                  width: MediaQuery.of(context).size.width,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 3,),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width * .27,
                                                              child: Marquee(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    // Text(
                                                                    //   appointmentProvider.appointmentsDefinitive[i].user!.username != null
                                                                    //       ? '@' + appointmentProvider.appointmentsDefinitive[i].user!.username!
                                                                    //   // : appointmentProvider.appointmentsDefinitive[i].guestName!,
                                                                    //       : '',
                                                                    //   style: TextStyle(
                                                                    //     color: Colors.blue[500],
                                                                    //     // color: Colors.white,
                                                                    //     fontWeight: FontWeight.w800,
                                                                    //     fontSize: 12,
                                                                    //   ),
                                                                    // ),
                                                                    // SizedBox(height: 2,),
                                                                    Text(
                                                                      appointmentProvider.appointmentsDefinitive[i].user!.name != null
                                                                          ? appointmentProvider.appointmentsDefinitive[i].user!.name!
                                                                      // : appointmentProvider.appointmentsDefinitive[i].guestEmail!,
                                                                          : '',
                                                                      style: TextStyle(
                                                                        // color: Colors.grey[500],
                                                                        // color: Colors.blue[500],
                                                                        color: Colors.blue[50],
                                                                        // color: Colors.white,
                                                                        fontWeight: FontWeight.w800,
                                                                        // fontSize: 10,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 2,),
                                                                    Text(
                                                                      appointmentProvider.appointmentsDefinitive[i].prestazione!.title ?? '',
                                                                      style: TextStyle(
                                                                        // color: Colors.blue[50],
                                                                        // color: Colors.black,
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 12.5,
                                                                      ),
                                                                    ),
                                                                    // SizedBox(height: 2,),
                                                                    // Text(
                                                                    //   'Pagato',
                                                                    //   style: TextStyle(
                                                                    //     color: Colors.green[500],
                                                                    //     // color: Colors.grey[800],
                                                                    //     fontWeight: FontWeight.w800,
                                                                    //     fontSize: 12,
                                                                    //   ),
                                                                    // ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // child: Center(
                                                        //   child: ListTile(
                                                        //     contentPadding: EdgeInsets.all(2),
                                                        //     dense: true,
                                                        //     horizontalTitleGap: 4,
                                                        //     leading: Container(
                                                        //       width: 45,
                                                        //       height: 45,
                                                        //       child: Card(
                                                        //         semanticContainer: true,
                                                        //         clipBehavior: Clip.antiAliasWithSaveLayer,
                                                        //         elevation: 3,
                                                        //         shape: RoundedRectangleBorder(
                                                        //             borderRadius: BorderRadius.all(Radius.circular(6))
                                                        //         ),
                                                        //         // color: Colors.red,
                                                        //         // child: CircleAvatar(
                                                        //         child: Image.network(
                                                        //           appointmentProvider.appointmentsDefinitive[i].user.profile_image,
                                                        //           fit: BoxFit.fitWidth,
                                                        //         ),
                                                        //       ),
                                                        //     ),
                                                        //     title: Text(
                                                        //       '@' + appointmentProvider.appointmentsDefinitive[i].user.username,
                                                        //       style: TextStyle(
                                                        //         // color: Colors.blue[500],
                                                        //         color: Colors.blue[500],
                                                        //         fontWeight: FontWeight.w800,
                                                        //         fontSize: 12,
                                                        //       ),
                                                        //     ),
                                                        //     subtitle: Text(
                                                        //       appointmentProvider.appointmentsDefinitive[i].prestazione.title,
                                                        //       style: TextStyle(
                                                        //         // color: Colors.blue[500],
                                                        //         color: Colors.grey[700],
                                                        //         fontWeight: FontWeight.w800,
                                                        //         fontSize: 11,
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          else if(appointmentProvider.appointmentsDefinitive[i].type == 1){
                                            // return _rowDate(i0, i, 1);
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    appointmentProvider.appointmentsDefinitive[i].begin_at!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*//*.tolocal()*/.toString().substring(11, 16)
                                                        + ' - ' +
                                                        appointmentProvider.appointmentsDefinitive[i].end_at!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*//*.tolocal()*/.toString().substring(11, 16),
                                                    style: TextStyle(
                                                      // color: Colors.blue[500],
                                                      color: Colors.grey[700],
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.2,
                                                  ),
                                                  Container(
                                                    height: MediaQuery.of(context).size.width * 0.1,
                                                    width: MediaQuery.of(context).size.width * 0.4,
                                                    // margin: EdgeInsets.only(/*left: 40, right: 40,*/ top: 5, bottom: 5),
                                                    child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                            padding: EdgeInsets.zero,
                                                            backgroundColor: Colors.blue[500],
                                                            // backgroundColor: Colors.grey[500],
                                                            // minimumSize: Size(50, 30),
                                                            alignment: Alignment.center
                                                        ),
                                                        onPressed: () async {
                                                          /*await*/ appointmentProvider.deleteOccupiedDates(
                                                              businessProvider.business!.id,
                                                              appointmentProvider.appointmentsDefinitive[i].begin_at!/*.toUtc()*/,
                                                              appointmentProvider.appointmentsDefinitive[i].end_at!/*.toUtc()*/,
                                                              context
                                                          );

                                                          //aggiornare in apointments definitive il type
                                                          for(var e in appointmentProvider.appointmentsDefinitive){
                                                            if(e.begin_at == appointmentProvider.appointmentsDefinitive[i].begin_at){
                                                              e.type = 0;
                                                            }
                                                          }

                                                          // appointmentProvider.appointmentsDefinitive.clear();

                                                          (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business!.id, context)).then((value) =>
                                                              (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business!.id)).then((value){
                                                                setState(() {
                                                                  appointmentProvider.slots = appointmentProvider.createSlots(
                                                                    appointmentProvider.occupiedDates,
                                                                    appointmentProvider.appointments,
                                                                    appointmentProvider.selectedDate.day,
                                                                    appointmentProvider.selectedDate.month,
                                                                    appointmentProvider.selectedDate.year,
                                                                    socketProvider.socketAppointments,
                                                                    context
                                                                  );
                                                                });
                                                              }) /*.then((value) =>
                                                      print('appointmentProvider.appointmentsDefinitive8888')).then((value) =>
                                                      print(appointmentProvider.appointmentsDefinitive[i].begin_at)*/);
                                                        },
                                                        child: Text(
                                                          // 'Occupato',
                                                          'Bloccato',
                                                          style: TextStyle(
                                                            // color: Colors.blue[500],
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w800,
                                                            fontSize: 12,
                                                          ),
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          else if(appointmentProvider.appointmentsDefinitive[i].type == 0){
                                            // return _rowDate(i0, i, 0);
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    appointmentProvider.appointmentsDefinitive[i].begin_at!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)
                                                        + ' - ' +
                                                        appointmentProvider.appointmentsDefinitive[i].end_at!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                    style: TextStyle(
                                                      // color: Colors.blue[500],
                                                      color: Colors.grey[700],
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.2,
                                                  ),
                                                  Container(
                                                    height: MediaQuery.of(context).size.width * 0.1,
                                                    width: MediaQuery.of(context).size.width * 0.4,
                                                    // margin: EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 5),
                                                    child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                            padding: EdgeInsets.zero,
                                                            // backgroundColor: Colors.grey[50],
                                                            backgroundColor: Colors.white,
                                                            // minimumSize: Size(50, 30),
                                                            alignment: Alignment.center
                                                        ),
                                                        onPressed: () async {
                                                          /*await*/ appointmentProvider.setOccupiedDates(
                                                              businessProvider.business!.id,
                                                              appointmentProvider.appointmentsDefinitive[i].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*//*.toUtc()*/,
                                                              appointmentProvider.appointmentsDefinitive[i].end_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*//*.toUtc()*/,
                                                              context
                                                          );

                                                          // appointmentProvider.appointmentsDefinitive.clear();

                                                          (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business!.id, context)).then((value) =>
                                                              (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business!.id)).then((value){
                                                                setState(() {
                                                                  appointmentProvider.slots = appointmentProvider.createSlots(
                                                                    appointmentProvider.occupiedDates,
                                                                    appointmentProvider.appointments,
                                                                    appointmentProvider.selectedDate.day,
                                                                    appointmentProvider.selectedDate.month,
                                                                    appointmentProvider.selectedDate.year,
                                                                    socketProvider.socketAppointments,
                                                                    context
                                                                  );
                                                                });
                                                              })
                                                            /*}).then((value) {
                                                        // print('appointmentProvider.appointmentsDefinitive7777');
                                                      }).then((value) async {
                                                      // print('appointmentProvider.appointmentsDefinitive7777');
                                                      // print(appointmentProvider.appointmentsDefinitive[i].begin_at);
                                                      // await Navigator.push(
                                                      //     context,
                                                      //     PageTransition(
                                                      //         duration: const Duration(milliseconds: 500),
                                                      //         alignment: Alignment.center,
                                                      //         type: PageTransitionType.fade,
                                                      //         child: BookingInsertScreen(
                                                      //           beginAt: appointmentProvider.appointmentsDefinitive[i].begin_at,
                                                      //           // bookingBusiness: businessProvider.business,
                                                      //         )
                                                      //     )*/
                                                          );

                                                          // // print('fdggfgfgf ' + appointmentProvider.appointmentsDefinitive[i].begin_at.toString());
                                                        },
                                                        child: Text(
                                                          'Disponibile',
                                                          style: TextStyle(
                                                            // color: Colors.blue[500],
                                                            color: Colors.blue[500],
                                                            fontWeight: FontWeight.w800,
                                                            fontSize: 12,
                                                          ),
                                                        )
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          else {
                                            return SizedBox();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Container(height: 20, color: Color.fromRGBO(251, 253, 255, 1),),
                            ],
                          )
                      ),
                    );
                  }
                  else /*if(snapshot.connectionState != ConnectionState.done && appointmentProvider.appointmentsDefinitive.length == 0)*/ {
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
                  // else return SizedBox();
                  // else return Center(child: CircularProgressIndicator());
                }
            )
          ],
        )
    );
  }
}
