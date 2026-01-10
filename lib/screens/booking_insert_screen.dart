import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/timetable_settings_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/account.dart';
import 'package:nurebo_admin/widgets/account_selector.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/popover.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


class BookingInsertScreen extends StatefulWidget {
  final DateTime? beginAt;

  const BookingInsertScreen({Key? key, this.beginAt});

  @override
  _BookingInsertScreenState createState() => _BookingInsertScreenState();
}

class _BookingInsertScreenState extends State<BookingInsertScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // final TextEditingController _limitController = TextEditingController();
  bool? editableName;
  bool? editableContact;
  // bool editableLimit;
  // bool editablePhone;
  bool? editableDescription;
  File? _image;
  // final picker = ImagePicker();
  // bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  late PrestazioneProvider prestazioneProvider;
  late BookingProvider appointmentProvider;
  late SocketProvider socketProvider;
  List bookingBusinessTimetable = [];
  NumberFormat? formatter;
  String resultText = "";
  int selectedId = -1;
  DateTime? selectedDateTime = DateTime.now();
  List<Account> accountList = [];
  // PersistentBottomSheetController _controller; // <------ Instance variable
  // final _scaffoldKey = GlobalKey<ScaffoldState>(); // <---- Another instance variable


  Widget _dateBar(StateSetter setState1) {
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
          setState1(() {
            // setState(() {
            // _controller.setState(() {
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
          setState1(() {
          });
        },
      ),
    );
  }

  // bottomSheetOptions(BuildContext context/*, Experience experience*/) {
  //   showModalBottomSheet<int>(
  //     backgroundColor: Colors.transparent,
  //     context: context,
  //     builder: (context) {
  //       return Popover(
  //         child: Column(
  //           children: [
  //             // SettingsTile.switchTile(
  //             //   title: 'Lock app in background',
  //             //   leading: Icon(Icons.phonelink_lock),
  //             //   switchValue: lockInBackground,
  //             //   onToggle: (bool value) {
  //             //     setState(() {
  //             //       lockInBackground = value;
  //             //       notificationsEnabled = value;
  //             //     });
  //             //   },
  //             // ),
  //             // SwitchListTile(
  //             //   // contentPadding: EdgeInsets.all(15),
  //             //   title: Text("Gluten Free",style: TextStyle(
  //             //       color: Colors.deepblueAccent,fontWeight: FontWeight.bold,
  //             //       fontSize: 20
  //             //   ),
  //             //   ),
  //             //   subtitle: Text("Includes Only Gluten Free Dishes"),
  //             //   value: filterValues["gluten"], onChanged: (value) {
  //             //   setState(() {
  //             //     filterValues["gluten"]=value;
  //             //   });
  //             // },),
  //             GestureDetector(
  //               onTap: (){
  //                 print("Copia link");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Copia link"),
  //                   leading: Icon(Icons.attach_file_outlined),
  //                 ),
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: (){
  //                 print("Condividi");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Condividi"),
  //                   leading: Icon(Icons.send_outlined),
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               onTap: (){
  //                 print("Elimina reazione");
  //                 Navigator.of(context).pop();
  //                 // showDeletingDialog("Sei sicuro di voler cancellare la propria rection emoji a questa esperienza?");
  //                 // btn2(context);
  //                 // if(!experience.isDateExperience){
  //                 //   postProvider.deleteSingleEventExperienceReaction(
  //                 //       experience.reaction_emoji_experience,
  //                 //       userProvider.user.id
  //                 //   );
  //                 // }
  //                 // else if(experience.isDateExperience){
  //                 //   postProvider.deleteDateExperienceReaction(
  //                 //       experience.reaction_emoji_experience,
  //                 //       userProvider.user.id
  //                 //   );
  //                 // }
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Elimina reazione"),
  //                   leading: Icon(Icons.circle_outlined),
  //                 ),
  //               ),
  //             ),
  //             // btn1(context),
  //             GestureDetector(
  //               onTap: (){
  //                 print("Segnala");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Segnala"),
  //                   leading: Icon(Icons.warning_amber_outlined),
  //                 ),
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: (){
  //                 print("Non seguire più");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Non seguire più"),
  //                   leading: Icon(Icons.person_remove_alt_1_outlined),
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               onTap: (){
  //                 print("Blocca utente");
  //               },
  //               child: Container(
  //                 child: ListTile(
  //                   title: Text("Blocca utente"),
  //                   leading: Icon(Icons.block),
  //                 ),
  //               ),
  //             ),
  //             // SettingsTile.switchTile(
  //             //   title: 'Silenzia',
  //             //   enabled: true,
  //             //
  //             //   leading: Icon(Icons.airline_seat_individual_suite_outlined),
  //             //   switchValue: false,
  //             //   onToggle: (value) {
  //             //     setState(() {
  //             //       // lockInBackground = value;
  //             //       // notificationsEnabled = value;
  //             //     });
  //             //     value = true;
  //             //   },
  //             // ),
  //
  //             // GestureDetector(
  //             //   onTap: (){
  //             //
  //             //   },
  //             //   child: Container(
  //             //     child: ListTile(
  //             //       title: Text("Limita"),
  //             //       leading: Icon(Icons.account_box_outlined),
  //             //     ),
  //             //   ),
  //             // ),
  //             // GestureDetector(
  //             //   onTap: (){
  //             //
  //             //   },
  //             //   child: Container(
  //             //     child: ListTile(
  //             //       title: Text("Blocca"),
  //             //       leading: Icon(Icons.admin_panel_settings_outlined),
  //             //     ),
  //             //   ),
  //             // ),
  //             // SettingsTile.switchTile(
  //             //   title: 'Notifiche',
  //             //   enabled: true,
  //             //
  //             //   leading: Icon(Icons.notifications_active_outlined),
  //             //   switchValue: false,
  //             //   onToggle: (value) {
  //             //     setState(() {
  //             //       lockInBackground = value;
  //             //       notificationsEnabled = value;
  //             //     });
  //             //     value = true;
  //             //   },
  //             //
  //             // ),
  //             // SettingsTile.switchTile(
  //             //   title: 'Post',
  //             //   leading: Icon(Icons.panorama_outlined),
  //             //   switchValue: lockInBackground,
  //             //   onToggle: (bool value) {
  //             //     setState(() {
  //             //       lockInBackground = value;
  //             //       // notificationsEnabled = value;
  //             //     });
  //             //   },
  //             // ),
  //             // SettingsTile.switchTile(
  //             //     title: 'Storie',
  //             //     // subtitle: 'Allow application to access stored fingerprint IDs.',
  //             //     leading: Icon(Icons.all_inclusive_outlined),
  //             //     onToggle: (bool value) {},
  //             //     switchValue: false
  //             // ),
  //             // SwitchListTile(
  //             //   value: true,
  //             //   // value: context.watch<PostCreateViewModel>().isShareFacebook,
  //             //   onChanged: (value) {
  //             //     if(value == true)
  //             //       value = false;
  //             //     else value = true;
  //             //     // context.read<PostCreateViewModel>().enableSocialShare(SocialShare.FACEBOOK, value);
  //             //   },
  //             //   title: Text('Facebook'),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Total Task'),
  //             //   leading: Icon(
  //             //     Icons.check_circle_outline,
  //             //     color: Colors.black,
  //             //   ),
  //             //   trailing: Switch(
  //             //     value: true,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Due Soon'),
  //             //   leading: Icon(Icons.inbox),
  //             //   trailing: Switch(
  //             //     value: false,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Completed'),
  //             //   leading: Icon(Icons.check_circle),
  //             //   trailing: Switch(
  //             //     value: false,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //             // _buildListItem(
  //             //   context,
  //             //   title: Text('Working On'),
  //             //   leading: Icon(Icons.flag),
  //             //   trailing: Switch(
  //             //     value: false,
  //             //     onChanged: (value) {},
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  bottomSheetOptions(BuildContext context/*, Experience experience*/) {
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

    /*_scaffoldKey.currentState.*/showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState2 /*You can rename this!*/) {
            return Popover(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start
                children: [
                  _dateBar(setState2),
                  FutureBuilder<Object>(
                      future: Future.wait([appointmentProvider.tasks0/*.then((value) => value!)*/, appointmentProvider.tasks1/*.then((value) => value!)*/, appointmentProvider.slots/*.then((value) => value!)*/]),
                      builder: (context, snapshot) {
                        if(/*snapshot.connectionState == ConnectionState.done && */appointmentProvider.appointmentsDefinitive.length > 0) {
                          return NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return true;
                              },
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.4,
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
                                                          appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/.toString().substring(11, 16)
                                                              + ' - ' +
                                                              appointmentProvider.appointmentsDefinitive[i].end_at!/*.tolocal()*/.toString().substring(11, 16),
                                                          style: TextStyle(
                                                            // color: Colors.blue[500],
                                                            color: DateTime.now()/*.tolocal()*/.isAfter(appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/) &&
                                                                DateTime.now()/*.tolocal()*/.isBefore(appointmentProvider.appointmentsDefinitive[i].end_at!/*.tolocal()*/)
                                                                ? Colors.blue[500] : Colors.grey[700],
                                                            fontWeight: FontWeight.w800,
                                                            fontSize: 14,
                                                          ),
                                                        ) : i == 0 ? Text(
                                                          appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/.toString().substring(11, 16)
                                                            + ' - ' +
                                                            appointmentProvider.appointmentsDefinitive[i].end_at!/*.tolocal()*/.toString().substring(11, 16),
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
                                                                      booking: appointmentProvider.appointmentsDefinitive[i],
                                                                    )
                                                                )
                                                            );
                                                          },
                                                          child: Card(
                                                            margin: EdgeInsets.all(0),
                                                            borderOnForeground: true,
                                                            // shadowColor: Colors.blue,
                                                            // color: Colors.blue[500],
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
                                                              child: Marquee(
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
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                                                        ),
                                                                        // color: Colors.red,
                                                                        // child: CircleAvatar(
                                                                        child: FutureImage(
                                                                          appointmentProvider.appointmentsDefinitive[i].user!.profile_image!,
                                                                          width: MediaQuery.of(context).size.width,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 3,),
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          appointmentProvider.appointmentsDefinitive[i].user!.username != null
                                                                            ? '@' + appointmentProvider.appointmentsDefinitive[i].user!.username!
                                                                            : appointmentProvider.appointmentsDefinitive[i].guestName!,
                                                                          style: TextStyle(
                                                                            color: Colors.blue[500],
                                                                            // color: Colors.white,
                                                                            fontWeight: FontWeight.w800,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 2,),
                                                                        Text(
                                                                          appointmentProvider.appointmentsDefinitive[i].user!.name ?? '',
                                                                          style: TextStyle(
                                                                            color: Colors.grey[500],
                                                                            // color: Colors.blue[500],
                                                                            fontWeight: FontWeight.w800,
                                                                            fontSize: 10,
                                                                            // fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 2,),
                                                                        Text(
                                                                          appointmentProvider.appointmentsDefinitive[i].prestazione!.title ?? '',
                                                                          style: TextStyle(
                                                                            // color: Colors.blue[500],
                                                                            color: Colors.black,
                                                                            fontWeight: FontWeight.w800,
                                                                            fontSize: 11,
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
                                                                  ],
                                                                ),
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
                                                else if(selectedDateTime!.isAtSameMomentAs(appointmentProvider.appointmentsDefinitive[i].begin_at!)){
                                                  // return _rowDate(i0, i, 1);
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          appointmentProvider.appointmentsDefinitive[i].begin_at!/*.tolocal()*/.toString().substring(11, 16)
                                                              + ' - ' +
                                                              appointmentProvider.appointmentsDefinitive[i].begin_at!.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration!))/*.tolocal()*/.toString().substring(11, 16),
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
                                                              onPressed: (){
                                                                setState2((){
                                                                  selectedDateTime = DateTime.now();
                                                                });
                                                                // appointmentProvider.deleteOccupiedDates(
                                                                //     businessProvider.business.id,
                                                                //     appointmentProvider.appointmentsDefinitive[i].begin_at.toUtc(),
                                                                //     appointmentProvider.appointmentsDefinitive[i].end_at.toUtc(),
                                                                //     context
                                                                // );
                                                                //aggiornare in apointments definitive il type
                                                                for(var e in appointmentProvider.appointmentsDefinitive){
                                                                  if(e.begin_at == appointmentProvider.appointmentsDefinitive[i].begin_at){
                                                                    e.type = 0;
                                                                  }
                                                                }

                                                                // appointmentProvider.appointmentsDefinitive.clear();
                                                                (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business!.id, context)).then((value) =>
                                                                    // (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business!.id)).then((value){
                                                                      setState2(() {
                                                                        appointmentProvider.slots = appointmentProvider.createSlots(
                                                                          appointmentProvider.occupiedDates,
                                                                          appointmentProvider.appointments,
                                                                          appointmentProvider.selectedDate.day,
                                                                          appointmentProvider.selectedDate.month,
                                                                          appointmentProvider.selectedDate.year,
                                                                          socketProvider.socketAppointments,
                                                                          context
                                                                        );
                                                                      // });
                                                                    })
                                                                /*).then((value) =>
                                                                    print('appointmentrovider.appointmentsDefinitive888')).then((value) =>
                                                                    print(appointmentProvider.appointmentsDefinitive[i].begin_at)*/);
                                                              },
                                                              child: Text(
                                                                // 'Occupato',
                                                                'Selezionato',
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
                                                else if(selectedDateTime!.isAfter(appointmentProvider.appointmentsDefinitive[i].begin_at!) || selectedDateTime!.isBefore(appointmentProvider.appointmentsDefinitive[i].begin_at!)){
                                                  // return _rowDate(i0, i, 0);
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          appointmentProvider.appointmentsDefinitive[i].begin_at.toString().substring(11, 16)
                                                              + ' - ' +
                                                              appointmentProvider.appointmentsDefinitive[i].begin_at!.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration!)).toString().substring(11, 16),
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
                                                              onPressed: (){
                                                                setState2((){
                                                                  selectedDateTime = appointmentProvider.appointmentsDefinitive[i].begin_at;
                                                                });
                                                                // appointmentProvider.setOccupiedDates(
                                                                //     businessProvider.business.id,
                                                                //     appointmentProvider.appointmentsDefinitive[i].begin_at.toUtc(),
                                                                //     appointmentProvider.appointmentsDefinitive[i].end_at.toUtc(),
                                                                //     context
                                                                // );
                                                                // appointmentProvider.appointmentsDefinitive.clear();
                                                                (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business!.id, context)).then((value) =>
                                                                    // (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business!.id)).then((value){
                                                                      setState2(() {
                                                                        appointmentProvider.slots = appointmentProvider.createSlots(
                                                                          appointmentProvider.occupiedDates,
                                                                          appointmentProvider.appointments,
                                                                          appointmentProvider.selectedDate.day,
                                                                          appointmentProvider.selectedDate.month,
                                                                          appointmentProvider.selectedDate.year,
                                                                          socketProvider.socketAppointments,
                                                                          context
                                                                        );
                                                                      // });
                                                                    })
                                                                /*).then((value) => print('appointmentProvider.appointmentsDefinitive7777')
                                                                ).then((value) => print(appointmentProvider.appointmentsDefinitive[i].begin_at)*/);
                                                              },
                                                              child: Text(
                                                                'Seleziona',
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
                                ),
                              )
                          );
                        }
                        else /*if(snapshot.connectionState != ConnectionState.done *//*&& appointmentProvider.appointmentsDefinitive.length == 0*//*)*/ {
                          return NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowIndicator();
                              return true;
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                                // Lottie.asset(
                                //   'assets/animations/16683-closed.json',
                                //   // 'assets/animations/51661-closed-tag.json',
                                //   height: MediaQuery.of(context).size.height * 0.35,
                                //   width: MediaQuery.of(context).size.height * 0.35,
                                //   // height: MediaQuery.of(context).size.height * 0.45,
                                //   // width: MediaQuery.of(context).size.height * 0.45,
                                //
                                // ),
                                SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                Center(
                                  child: Image.asset(
                                    'assets/png/Saly-39.png',
                                    height: MediaQuery.of(context).size.height * .2,
                                    // width: MediaQuery.of(context).size.width * .7,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * .025,),
                                Center(
                                  child: Text(
                                    // "Chiuso",
                                    "Oggi non ci sono prenotazioni",
                                    // textAlign: TextAlign.center,
                                    style: TextStyle(
                                      // color: Colors.red[800],
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * .1,),
                              ],
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
        );
      },
    );
  }

  // bottomSheetOptions(BuildContext context/*, Experience experience*/) async {
  //   _controller = _scaffoldKey.currentState.showBottomSheet<int>(
  //   (context) {
  //     return Popover(
  //         child: Column(
  //           // crossAxisAlignment: CrossAxisAlignment.start,
  //           // mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             _dateBar(),
  //             FutureBuilder<Object>(
  //                 future: Future.wait([appointmentProvider.tasks0, appointmentProvider.tasks1, appointmentProvider.slots]),
  //                 builder: (context, snapshot) {
  //                   if(/*snapshot.connectionState == ConnectionState.done && */appointmentProvider.appointmentsDefinitive.length > 0) {
  //                     return NotificationListener<OverscrollIndicatorNotification>(
  //                         onNotification: (overscroll) {
  //                           overscroll.disallowIndicator();
  //                           return true;
  //                         },
  //                         child: Container(
  //                           height: MediaQuery.of(context).size.height * 0.4,
  //                           child: ListView(
  //                             // shrinkWrap: true,
  //                             children: [
  //                               Container(height: 10, color: Color.fromRGBO(251, 253, 255, 1),),
  //                               Container(
  //                                 color: Color.fromRGBO(251, 253, 255, 1),
  //                                 child: NotificationListener<OverscrollIndicatorNotification>(
  //                                   onNotification: (overscroll) {
  //                                     overscroll.disallowIndicator();
  //                                     return true;
  //                                   },
  //                                   child: ListView.separated(
  //                                     separatorBuilder: (BuildContext context, int index) => const Divider(
  //                                       indent: 20,
  //                                       endIndent: 20,
  //                                     ),
  //                                     shrinkWrap: true,
  //                                     physics: NeverScrollableScrollPhysics(),
  //                                     // padding: EdgeInsets.symmetric(horizontal: 50),
  //                                     // itemCount: openingDates.length,
  //                                     itemCount: 1,
  //                                     itemBuilder: (context, i0) {
  //                                       // for(var e in appointments) {
  //                                       //   if(/*(*/DateTime.tryParse(e['begin_at']).toLocal().isBefore(openingDates[i0].add(Duration(minutes: i * 30 + 30))) /*||
  //                                       //                     DateTime.tryParse(e['begin_at']).toLocal().isAtSameMomentAs(openingDates[i0].add(Duration(minutes: i * 30 + 30))))*/
  //                                       //       && /*(*/DateTime.tryParse(e['begin_at']).toLocal().add(Duration(minutes: i * 30 + e['duration'].toInt())).isAfter(openingDates[i0].add(Duration(minutes: i * 30 + 30))) /*||
  //                                       //                         DateTime.tryParse(e['begin_at']).toLocal().add(Duration(minutes: i * 30 + e['duration'].toInt())).isAtSameMomentAs(openingDates[i0].add(Duration(minutes: i * 30 + 30))))*/) {
  //                                       //     // isUserAppointment = true;
  //                                       //     isOccupied = 3;
  //                                       //     print('begin_at');
  //                                       //     print(
  //                                       //         DateTime.tryParse(e['begin_at']).toLocal().toString().substring(11, 16)
  //                                       //     );
  //                                       //   }
  //                                       // }
  //
  //                                       // print('i0');
  //                                       // print(i0.toString());
  //                                       return ListView.builder(
  //                                         shrinkWrap: true,
  //                                         physics: NeverScrollableScrollPhysics(),
  //                                         // padding: EdgeInsets.symmetric(horizontal: 50),
  //                                         // itemCount: intervalliDaMezzoraPerApertura[i0],
  //                                         itemCount: appointmentProvider.appointmentsDefinitive.length,
  //                                         itemBuilder: (context, i) {
  //                                           if(appointmentProvider.appointmentsDefinitive[i].type == 2){
  //                                             return Padding(
  //                                               padding: const EdgeInsets.only(top: 5.0, bottom: 5),
  //                                               child: Row(
  //                                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                                 children: [
  //                                                   i > 0 && (appointmentProvider.appointmentsDefinitive[i].begin_at.toLocal().toString().substring(11, 16) !=
  //                                                       appointmentProvider.appointmentsDefinitive[i-1].begin_at.toLocal().toString().substring(11, 16) ||
  //                                                       appointmentProvider.appointmentsDefinitive[i].end_at.toLocal().toString().substring(11, 16) !=
  //                                                           appointmentProvider.appointmentsDefinitive[i-1].end_at.toLocal().toString().substring(11, 16)) ? Text(
  //                                                     appointmentProvider.appointmentsDefinitive[i].begin_at.toLocal().toString().substring(11, 16)
  //                                                         + ' - ' +
  //                                                         appointmentProvider.appointmentsDefinitive[i].end_at.toLocal().toString().substring(11, 16),
  //                                                     style: TextStyle(
  //                                                       // color: Colors.blue[500],
  //                                                       color: DateTime.now().toLocal().isAfter(appointmentProvider.appointmentsDefinitive[i].begin_at.toLocal()) &&
  //                                                           DateTime.now().toLocal().isBefore(appointmentProvider.appointmentsDefinitive[i].end_at.toLocal())
  //                                                           ? Colors.blue[500] : Colors.grey[700],
  //                                                       fontWeight: FontWeight.w800,
  //                                                       fontSize: 14,
  //                                                     ),
  //                                                   ) : i == 0 ? Text(
  //                                                     appointmentProvider.appointmentsDefinitive[i].begin_at.toLocal().toString().substring(11, 16)
  //                                                         + ' - ' +
  //                                                         appointmentProvider.appointmentsDefinitive[i].end_at.toLocal().toString().substring(11, 16),
  //                                                     style: TextStyle(
  //                                                       // color: Colors.blue[500],
  //                                                       color: DateTime.now().toLocal().isAfter(appointmentProvider.appointmentsDefinitive[i].begin_at.toLocal()) &&
  //                                                           DateTime.now().toLocal().isBefore(appointmentProvider.appointmentsDefinitive[i].end_at.toLocal())
  //                                                           ? Colors.blue[500] : Colors.grey[700],
  //                                                       fontWeight: FontWeight.w800,
  //                                                       fontSize: 14,
  //                                                     ),
  //                                                   ) : const Text('                        '),
  //                                                   SizedBox(
  //                                                     width: MediaQuery.of(context).size.width * 0.187,
  //                                                   ),
  //                                                   InkWell(
  //                                                     onTap: (){
  //                                                       Navigator.push(
  //                                                           context,
  //                                                           PageTransition(
  //                                                               duration: const Duration(milliseconds: 500),
  //                                                               alignment: Alignment.center,
  //                                                               type: PageTransitionType.fade,
  //                                                               // child: AppointmentDetailScreen(
  //                                                               //   appointment: appointmentProvider.appointmentsDefinitive[i],
  //                                                               // )
  //                                                               child: BookingDetailScreen(
  //                                                                 appointment: appointmentProvider.appointmentsDefinitive[i],
  //                                                               )
  //                                                           )
  //                                                       );
  //                                                     },
  //                                                     child: Card(
  //                                                       margin: EdgeInsets.all(0),
  //                                                       borderOnForeground: true,
  //                                                       // shadowColor: Colors.blue,
  //                                                       // color: Colors.blue[500],
  //                                                       child: Container(
  //                                                         margin: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
  //                                                         // color: Colors.red,
  //                                                         // height: MediaQuery.of(context).size.width * 0.145,
  //                                                         height: MediaQuery.of(context).size.width * 0.17,
  //                                                         width: MediaQuery.of(context).size.width * 0.4,
  //                                                         // margin: EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 5),
  //                                                         // child: OutlinedButton(
  //                                                         //     style: OutlinedButton.styleFrom(
  //                                                         //         padding: EdgeInsets.zero,
  //                                                         //         backgroundColor: Colors.grey[50],
  //                                                         //         // backgroundColor: Colors.white,
  //                                                         //         // minimumSize: Size(50, 30),
  //                                                         //         alignment: Alignment.center
  //                                                         //     ),
  //                                                         //     onPressed: (){
  //                                                         //         print("aprire un dialog che consente l'annullamento con il conseguente rimborso");
  //                                                         //     },
  //                                                         //     child: Text(
  //                                                         //       appointmentProvider.appointmentsDefinitive[i].begin_at.toString().substring(11, 16),
  //                                                         //       style: TextStyle(
  //                                                         //         // color: Colors.blue[500],
  //                                                         //         color: Colors.grey[700],
  //                                                         //         fontWeight: FontWeight.w800,
  //                                                         //         fontSize: 14,
  //                                                         //       ),
  //                                                         //     )
  //                                                         // ),
  //                                                         child: Marquee(
  //                                                           child: Row(
  //                                                             mainAxisAlignment: MainAxisAlignment.start,
  //                                                             crossAxisAlignment: CrossAxisAlignment.center,
  //                                                             children: [
  //                                                               Container(
  //                                                                 // padding: EdgeInsets.all(3),
  //                                                                 width: 40,
  //                                                                 height: 40,
  //                                                                 child: Card(
  //                                                                   semanticContainer: true,
  //                                                                   clipBehavior: Clip.antiAliasWithSaveLayer,
  //                                                                   elevation: 3,
  //                                                                   shape: RoundedRectangleBorder(
  //                                                                       borderRadius: BorderRadius.all(Radius.circular(5))
  //                                                                   ),
  //                                                                   // color: Colors.red,
  //                                                                   // child: CircleAvatar(
  //                                                                   child: CachedNetworkImage(
  //                                                                     imageUrl: appointmentProvider.appointmentsDefinitive[i].user.profile_image,
  //                                                                     fit: BoxFit.cover,
  //                                                                   ),
  //                                                                 ),
  //                                                               ),
  //                                                               SizedBox(width: 3,),
  //                                                               Column(
  //                                                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                                                 children: [
  //                                                                   Text(
  //                                                                     '@' + appointmentProvider.appointmentsDefinitive[i].user.username ?? '',
  //                                                                     style: TextStyle(
  //                                                                       color: Colors.blue[500],
  //                                                                       // color: Colors.white,
  //                                                                       fontWeight: FontWeight.w800,
  //                                                                       fontSize: 12,
  //                                                                     ),
  //                                                                   ),
  //                                                                   SizedBox(height: 2,),
  //                                                                   Text(
  //                                                                     appointmentProvider.appointmentsDefinitive[i].user.name ?? '',
  //                                                                     style: TextStyle(
  //                                                                       color: Colors.grey[500],
  //                                                                       // color: Colors.blue[500],
  //                                                                       fontWeight: FontWeight.w800,
  //                                                                       fontSize: 10,
  //                                                                       // fontSize: 12,
  //                                                                     ),
  //                                                                   ),
  //                                                                   SizedBox(height: 2,),
  //                                                                   Text(
  //                                                                     appointmentProvider.appointmentsDefinitive[i].prestazione.title ?? '',
  //                                                                     style: TextStyle(
  //                                                                       // color: Colors.blue[500],
  //                                                                       color: Colors.black,
  //                                                                       fontWeight: FontWeight.w800,
  //                                                                       fontSize: 11,
  //                                                                     ),
  //                                                                   ),
  //                                                                   // SizedBox(height: 2,),
  //                                                                   // Text(
  //                                                                   //   'Pagato',
  //                                                                   //   style: TextStyle(
  //                                                                   //     color: Colors.green[500],
  //                                                                   //     // color: Colors.grey[800],
  //                                                                   //     fontWeight: FontWeight.w800,
  //                                                                   //     fontSize: 12,
  //                                                                   //   ),
  //                                                                   // ),
  //                                                                 ],
  //                                                               ),
  //                                                             ],
  //                                                           ),
  //                                                         ),
  //                                                         // child: Center(
  //                                                         //   child: ListTile(
  //                                                         //     contentPadding: EdgeInsets.all(2),
  //                                                         //     dense: true,
  //                                                         //     horizontalTitleGap: 4,
  //                                                         //     leading: Container(
  //                                                         //       width: 45,
  //                                                         //       height: 45,
  //                                                         //       child: Card(
  //                                                         //         semanticContainer: true,
  //                                                         //         clipBehavior: Clip.antiAliasWithSaveLayer,
  //                                                         //         elevation: 3,
  //                                                         //         shape: RoundedRectangleBorder(
  //                                                         //             borderRadius: BorderRadius.all(Radius.circular(6))
  //                                                         //         ),
  //                                                         //         // color: Colors.red,
  //                                                         //         // child: CircleAvatar(
  //                                                         //         child: Image.network(
  //                                                         //           appointmentProvider.appointmentsDefinitive[i].user.profile_image,
  //                                                         //           fit: BoxFit.fitWidth,
  //                                                         //         ),
  //                                                         //       ),
  //                                                         //     ),
  //                                                         //     title: Text(
  //                                                         //       '@' + appointmentProvider.appointmentsDefinitive[i].user.username,
  //                                                         //       style: TextStyle(
  //                                                         //         // color: Colors.blue[500],
  //                                                         //         color: Colors.blue[500],
  //                                                         //         fontWeight: FontWeight.w800,
  //                                                         //         fontSize: 12,
  //                                                         //       ),
  //                                                         //     ),
  //                                                         //     subtitle: Text(
  //                                                         //       appointmentProvider.appointmentsDefinitive[i].prestazione.title,
  //                                                         //       style: TextStyle(
  //                                                         //         // color: Colors.blue[500],
  //                                                         //         color: Colors.grey[700],
  //                                                         //         fontWeight: FontWeight.w800,
  //                                                         //         fontSize: 11,
  //                                                         //       ),
  //                                                         //     ),
  //                                                         //   ),
  //                                                         // ),
  //                                                       ),
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             );
  //                                           }
  //                                           else if(appointmentProvider.appointmentsDefinitive[i].type == 1){
  //                                             // return _rowDate(i0, i, 1);
  //                                             return Padding(
  //                                               padding: const EdgeInsets.only(top: 5.0, bottom: 5),
  //                                               child: Row(
  //                                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                                 children: [
  //                                                   Text(
  //                                                     appointmentProvider.appointmentsDefinitive[i].begin_at.toLocal().toString().substring(11, 16)
  //                                                         + ' - ' +
  //                                                         appointmentProvider.appointmentsDefinitive[i].begin_at.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration)).toLocal().toString().substring(11, 16),
  //                                                     style: TextStyle(
  //                                                       // color: Colors.blue[500],
  //                                                       color: Colors.grey[700],
  //                                                       fontWeight: FontWeight.w800,
  //                                                       fontSize: 14,
  //                                                     ),
  //                                                   ),
  //                                                   SizedBox(
  //                                                     width: MediaQuery.of(context).size.width * 0.2,
  //                                                   ),
  //                                                   Container(
  //                                                     height: MediaQuery.of(context).size.width * 0.1,
  //                                                     width: MediaQuery.of(context).size.width * 0.4,
  //                                                     // margin: EdgeInsets.only(/*left: 40, right: 40,*/ top: 5, bottom: 5),
  //                                                     child: OutlinedButton(
  //                                                         style: OutlinedButton.styleFrom(
  //                                                             padding: EdgeInsets.zero,
  //                                                             backgroundColor: Colors.blue[500],
  //                                                             // backgroundColor: Colors.grey[500],
  //                                                             // minimumSize: Size(50, 30),
  //                                                             alignment: Alignment.center
  //                                                         ),
  //                                                         onPressed: (){
  //                                                           // appointmentProvider.deleteOccupiedDates(
  //                                                           //     businessProvider.business.id,
  //                                                           //     appointmentProvider.appointmentsDefinitive[i].begin_at.toUtc(),
  //                                                           //     appointmentProvider.appointmentsDefinitive[i].end_at.toUtc(),
  //                                                           //     context
  //                                                           // );
  //                                                           //aggiornare in apointments definitive il type
  //                                                           for(var e in appointmentProvider.appointmentsDefinitive){
  //                                                             if(e.begin_at == appointmentProvider.appointmentsDefinitive[i].begin_at){
  //                                                               e.type = 0;
  //                                                             }
  //                                                           }
  //
  //                                                           // appointmentProvider.appointmentsDefinitive.clear();
  //                                                           (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business.id, context)).then((value) =>
  //                                                               (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business.id)).then((value){
  //                                                                 setState(() {
  //                                                                   appointmentProvider.slots = appointmentProvider.createSlots(
  //                                                                       appointmentProvider.occupiedDates,
  //                                                                       appointmentProvider.appointments,
  //                                                                       appointmentProvider.selectedDate.day,
  //                                                                       appointmentProvider.selectedDate.month,
  //                                                                       appointmentProvider.selectedDate.year,
  //                                                                       socketProvider.socketAppointments
  //                                                                   );
  //                                                                 });
  //                                                               })
  //                                                           ).then((value) =>
  //                                                               print('appointmentProvider.appointmentsDefinitive888')).then((value) =>
  //                                                               print(appointmentProvider.appointmentsDefinitive[i].begin_at));
  //                                                         },
  //                                                         child: Text(
  //                                                           // 'Occupato',
  //                                                           'Bloccato',
  //                                                           style: TextStyle(
  //                                                             // color: Colors.blue[500],
  //                                                             color: Colors.white,
  //                                                             fontWeight: FontWeight.w800,
  //                                                             fontSize: 12,
  //                                                           ),
  //                                                         )
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             );
  //                                           }
  //                                           else if(appointmentProvider.appointmentsDefinitive[i].type == 0){
  //                                             // return _rowDate(i0, i, 0);
  //                                             return Padding(
  //                                               padding: const EdgeInsets.only(top: 5.0, bottom: 5),
  //                                               child: Row(
  //                                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                                 children: [
  //                                                   Text(
  //                                                     appointmentProvider.appointmentsDefinitive[i].begin_at.toString().substring(11, 16)
  //                                                         + ' - ' +
  //                                                         appointmentProvider.appointmentsDefinitive[i].begin_at.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration)).toString().substring(11, 16),
  //                                                     style: TextStyle(
  //                                                       // color: Colors.blue[500],
  //                                                       color: Colors.grey[700],
  //                                                       fontWeight: FontWeight.w800,
  //                                                       fontSize: 14,
  //                                                     ),
  //                                                   ),
  //                                                   SizedBox(
  //                                                     width: MediaQuery.of(context).size.width * 0.2,
  //                                                   ),
  //                                                   Container(
  //                                                     height: MediaQuery.of(context).size.width * 0.1,
  //                                                     width: MediaQuery.of(context).size.width * 0.4,
  //                                                     // margin: EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 5),
  //                                                     child: OutlinedButton(
  //                                                         style: OutlinedButton.styleFrom(
  //                                                             padding: EdgeInsets.zero,
  //                                                             // backgroundColor: Colors.grey[50],
  //                                                             backgroundColor: Colors.white,
  //                                                             // minimumSize: Size(50, 30),
  //                                                             alignment: Alignment.center
  //                                                         ),
  //                                                         onPressed: (){
  //                                                           // appointmentProvider.setOccupiedDates(
  //                                                           //     businessProvider.business.id,
  //                                                           //     appointmentProvider.appointmentsDefinitive[i].begin_at.toUtc(),
  //                                                           //     appointmentProvider.appointmentsDefinitive[i].end_at.toUtc(),
  //                                                           //     context
  //                                                           // );
  //                                                           // appointmentProvider.appointmentsDefinitive.clear();
  //                                                           (appointmentProvider.tasks0 = appointmentProvider.getDateBusinessAppointments(businessProvider.business.id, context)).then((
  //                                                               value) =>
  //                                                               (appointmentProvider.tasks1 = appointmentProvider.getOccupiedDates(businessProvider.business.id)).then((value){
  //                                                                 setState(() {
  //                                                                   appointmentProvider.slots = appointmentProvider.createSlots(
  //                                                                       appointmentProvider.occupiedDates,
  //                                                                       appointmentProvider.appointments,
  //                                                                       appointmentProvider.selectedDate.day,
  //                                                                       appointmentProvider.selectedDate.month,
  //                                                                       appointmentProvider.selectedDate.year,
  //                                                                       socketProvider.socketAppointments
  //                                                                   );
  //                                                                 });
  //                                                               })
  //                                                           ).then((value) => print('appointmentProvider.appointmentsDefinitive7777')
  //                                                           ).then((value) => print(appointmentProvider.appointmentsDefinitive[i].begin_at));
  //                                                         },
  //                                                         child: Text(
  //                                                           'Seleziona',
  //                                                           style: TextStyle(
  //                                                             // color: Colors.blue[500],
  //                                                             color: Colors.blue[500],
  //                                                             fontWeight: FontWeight.w800,
  //                                                             fontSize: 12,
  //                                                           ),
  //                                                         )
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             );
  //                                           }
  //                                           else {
  //                                             return SizedBox();
  //                                           }
  //                                         },
  //                                       );
  //                                     },
  //                                   ),
  //                                 ),
  //                               ),
  //                               Container(height: 20, color: Color.fromRGBO(251, 253, 255, 1),),
  //                             ],
  //                           ),
  //                         )
  //                     );
  //                   }
  //                   else /*if(snapshot.connectionState != ConnectionState.done *//*&& appointmentProvider.appointmentsDefinitive.length == 0*//*)*/ {
  //                     return NotificationListener<OverscrollIndicatorNotification>(
  //                       onNotification: (overscroll) {
  //                         overscroll.disallowIndicator();
  //                         return true;
  //                       },
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
  //                           // Lottie.asset(
  //                           //   'assets/animations/16683-closed.json',
  //                           //   // 'assets/animations/51661-closed-tag.json',
  //                           //   height: MediaQuery.of(context).size.height * 0.35,
  //                           //   width: MediaQuery.of(context).size.height * 0.35,
  //                           //   // height: MediaQuery.of(context).size.height * 0.45,
  //                           //   // width: MediaQuery.of(context).size.height * 0.45,
  //                           //
  //                           // ),
  //                           SizedBox(height: MediaQuery.of(context).size.height * .03,),
  //                           Center(
  //                             child: Image.asset(
  //                               'assets/png/Saly-39.png',
  //                               height: MediaQuery.of(context).size.height * .15,
  //                               // width: MediaQuery.of(context).size.width * .7,
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //                           SizedBox(height: MediaQuery.of(context).size.height * .025,),
  //                           Center(
  //                             child: Text(
  //                               // "Chiuso",
  //                               "Oggi non ci sono prenotazioni",
  //                               // textAlign: TextAlign.center,
  //                               style: TextStyle(
  //                                 // color: Colors.red[800],
  //                                 color: Colors.grey[400],
  //                                 fontWeight: FontWeight.w600,
  //                                 fontSize: 17,
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(height: MediaQuery.of(context).size.height * .1,),
  //                         ],
  //                       ),
  //                     );
  //                   }
  //                   // else if(snapshot.connectionState == ConnectionState.waiting) {
  //                   //   return Center(child: CircularProgressIndicator());
  //                   // }
  //                   // else return SizedBox();
  //                   // else return Center(child: CircularProgressIndicator());
  //                 }
  //             )
  //           ],
  //         )
  //     );
  //   },
  //     backgroundColor: Colors.transparent,
  //   );
  // }

  // Future insertBooking(Booking e) async {
  //   var url = Uri.parse("${Utils.httpServerUrl}booking");
  //   // final socketProvider = Provider.of<SocketProvider>(context, listen: true);
  //   // final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
  //
  //   // Map<String, dynamic> body = {
  //   //   // 'user_id': widget.user.id,
  //   //   'user_id': userProvider.user.id,
  //   //   'business_id': e.prestazione.business.id,
  //   //   'prestazione_id': e.prestazione_id,
  //   //   'begin_at': e.begin_at./*toUtc().*/toString(),
  //   //   'note': e.note,
  //   //   //bookingtime.now()
  //   // };
  //
  //   // print('e.begin_at.toIso8601String() hhhh');
  //   // print(e.begin_at.toIso8601String());
  //   // print('e.begin_at.toUtc().toString() uuuuu');
  //   // print(e.begin_at.toUtc().toString());
  //
  //   Map<String, dynamic> body = {
  //     // "booking_id": jsonData,
  //     // "user_order_id": e.userOrderId,
  //     "prestazione_id": e.prestazione.id,
  //     "note": e.note,
  //     "begin_at": e.begin_at.toUtc().toString(),
  //     // "begin_at": e.begin_at.toIso8601String(),
  //     'prestazione_duration': e.prestazione.duration,
  //     'prestazione_image': e.prestazione.image,
  //     'prestazione_description': e.prestazione.description,
  //     'prestazione_title': e.prestazione.title,
  //     'presale_price': e.prestazione.price,
  //     'prestazione_price': e.prestazione.price,
  //     // 'user_id': e.userId,
  //     // 'user_id': userProvider.user.id,
  //     // 'user_username': userProvider.user.username,
  //     // 'user_phone_number': userProvider.user.phone_number,
  //     // 'user_email': userProvider.user.email,
  //     // 'user_name': userProvider.user.name,
  //     // 'user_profile_image': userProvider.user.profile_image,
  //     // 'first_name': widget.user.first_name,
  //     // 'last_name': widget.user.last_name,
  //     // 'business_id': e.prestazione.business_id,
  //     'business_id': e.business.id,
  //     'business_name': e.business.name,
  //     'is_booking_business': e.business.business_type_id,
  //     'business_profile_image': e.business.profile_image,
  //     'business_description': e.business.description,
  //     'business_address': e.business.address,
  //     'business_phone_number': e.business.phone_number,
  //     'max_contemporary_appointments': e.business.max_contemporary_appointments,
  //     'created_at': DateTime.now().toIso8601String(),
  //     'is_canceled': 0,
  //   };
  //
  //   // print('body');
  //   // print(body);
  //
  //   // notificationProvider.showFlushbar(context);
  //
  //   // Fluttertoast.showToast(
  //   //   msg: "Appuntamento prenotato correttamente",
  //   //   backgroundColor: Colors.grey[700],
  //   // );
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()
  //       }
  //   );
  //
  //   // print("jjjj l response.statusCode:");
  //   // print(response.statusCode);
  //
  //   if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
  //     // if (!mounted) return;
  //     await businessProvider.logout(context);
  //   }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     //todo: inserire l appuntamento in provider
  //
  //     // // print('jsonData create booking');
  //     // // print(jsonData);
  //     //
  //     // Map<String, dynamic> socketBody = {
  //     //   "booking_id": jsonData,
  //     //   "user_order_id": e.userOrderId,
  //     //   "prestazione_id": e.prestazione.id,
  //     //   "note": e.note,
  //     //   "begin_at": e.begin_at/*.toUtc()*//*.add(Duration(hours: 2))*//*.toLocal()*/.toString()/*.toIso8601String()*/,
  //     //   'prestazione_duration': e.prestazione.duration,
  //     //   'prestazione_image': e.prestazione.image,
  //     //   'prestazione_description': e.prestazione.description,
  //     //   'prestazione_title': e.title,
  //     //   'presale_price': e.presale_price,
  //     //   'prestazione_price': e.prestazione.price,
  //     //   // 'user_id': e.userId,
  //     //   'user_id': userProvider.user.id,
  //     //   'user_username': userProvider.user.username,
  //     //   'user_phone_number': userProvider.user.phone_number,
  //     //   'user_email': userProvider.user.email,
  //     //   'user_name': userProvider.user.name,
  //     //   'user_profile_image': userProvider.user.profile_image,
  //     //   // 'first_name': widget.user.first_name,
  //     //   // 'last_name': widget.user.last_name,
  //     //   // 'business_id': e.prestazione.business_id,
  //     //   'business_id': e.business.id,
  //     //   'business_name': e.business.name,
  //     //   'is_booking_business': e.business.business_type_id,
  //     //   'business_profile_image': e.business.profile_image,
  //     //   'business_description': e.business.description,
  //     //   'business_address': e.business.address,
  //     //   'business_phone_number': e.business.phone_number,
  //     //   'max_contemporary_appointments': e.business.max_contemporary_appointments,
  //     //   'created_at': DateTime.now().toIso8601String(),
  //     //   'is_canceled': 0,
  //     // };
  //     //
  //     // // socketProvider.socket.emit(
  //     // //     'upbooking_booking_business_appointments',
  //     // //     socketBody
  //     // // );
  //     //
  //     // //todo: farlo direttamente nella query nel server
  //     // // socketProvider.sendAppointment(
  //     // //     socketBody
  //     // // );
  //     // socketProvider.addAppointment(
  //     //     socketBody
  //     // );
  //     //
  //     // // if(isShared){
  //     // //   /*await*/ notificationFollowers(socketBody);
  //     // // }
  //     //
  //     // Map<String, dynamic> values = {
  //     //   "booking_id": jsonData,
  //     //   'booking_price': e.prestazione.price,
  //     //   "booking_begin_at": e.begin_at.toString()/*.toIso8601String()*/,
  //     //   "prestazione_id": e.prestazione.id,
  //     //   'prestazione_image': e.prestazione.image != null && e.prestazione.image != '' ?  e.prestazione.image : e.business.profile_image,
  //     //   'prestazione_title': e.title,
  //     //   'is_canceled': 0,
  //     //   'user_id': userProvider.user.id,
  //     //   'business_id': e.business.id,
  //     //   'business_name': e.business.name,
  //     //   'sent_at': DateTime.now().toIso8601String(),
  //     // };
  //     //
  //     // await socketProvider.insertLocalNotification(
  //     //     'appointment_notification',
  //     //     values
  //     // );
  //     //
  //     // // print('socketProvider.notificationList.length');
  //     // // print(socketProvider.notificationList.length);
  //     //
  //     // // notificationProvider.showDateNotification(
  //     // //   beginAt: e.begin_at.toString(),
  //     // //   prestazioneTitle: e.prestazione.title,
  //     // //   imagePrestazione: e.prestazione.image,
  //     // // );
  //     // // showNotification(
  //     // //   title: e.prestazione.title,
  //     // //   body: e.begin_at.toString(),
  //     // //   largeIconPath: e.prestazione.image,
  //     // // );
  //     // // return response.statusCode;
  //   }
  //   return response.statusCode;
  // }

  @override
  void initState() {
    super.initState();
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    appointmentProvider = Provider.of<BookingProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    initializeDateFormatting();
    formatter = NumberFormat("00");

    // if(businessProvider.business.name != null)
    //   _nameController.text = businessProvider.business.name;
    // if(businessProvider.business.address != null)
    //   _addressController.text = businessProvider.business.address;
    // if(businessProvider.business.description != null)
    //   _descriptionController.text = businessProvider.business.description;
    // if(businessProvider.business.phone_number != null)
    //   _phoneNumberController.text = businessProvider.business.phone_number.toString();
    // if(businessProvider.business.email != null)
    //   _contactController.text = businessProvider.business.email;
    // if(businessProvider.business.max_contemporary_appointments != null)
    //   _limitController.text = businessProvider.business.max_contemporary_appointments.toString();

    accountList = List.generate(
        prestazioneProvider.prestazioneList.length,
        (index){
          return Account(
            title: prestazioneProvider.prestazioneList[index].title,
            datetime: '€ ${NumberFormat.currency(
              // customPattern: '#,##',
                decimalDigits: 2,
                symbol: '',
                locale: 'IT_it'
            ).format(prestazioneProvider.prestazioneList[index].price)}',
            // datetime: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(allEntities[index]['begin_at'])).toString()
            //     + ' alle ' + DateTime.tryParse(allEntities[index]['begin_at']).toString().substring(11, 16),
            subtitle: "${prestazioneProvider.prestazioneList[index].duration} min",
            accountImageWidget: FutureImage(
              prestazioneProvider.prestazioneList[index].image!,
              width: 200,
            ),
          );
        }
    );

    Future.wait([
    //   getDateBusinessTimetable(),
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
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    appointmentProvider = Provider.of<BookingProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    return Scaffold(
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
        title: Text(
          'Inserisci prenotazione',
          style: TextStyle(
              // color: Colors.blue,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 16
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () async {
                // int res = await insertBooking(
                //   //todo: da completare
                //   Booking(
                //     business: businessProvider.business,
                //     created_at: DateTime.now(),
                //     // prestazione:
                //   )
                // );
                Response res = await appointmentProvider.createDate(
                  Booking(
                    user: User(profile_image: 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                    // id: e['booking_id'],
                    // isCanceled: 0,
                    note: _descriptionController.text,
                    // user_id: myAppointments[index]['user_id'].toString(),
                    prestazione: prestazioneProvider.prestazioneList[selectedId],
                    business: businessProvider.business,
                    guestEmail: _contactController.text,
                    guestName: _nameController.text,
                    // user: new User(
                    //   id: e['user_id'],
                    //   email: e['user_email'],
                    //   username: e['user_username'],
                    //   name: e['user_name'],
                    //   phone_number: e['user_phone_number'],
                    //   profile_image: e['user_profile_image'],
                    //   // description: appointments[i]['user_description'],
                    // ),
                    begin_at: selectedDateTime,
                    end_at: selectedDateTime!.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration!))/*.toUtc()*/,
                    created_at: DateTime.now()/*.toUtc()*/,
                  ),
                  context
                );
                if(res.statusCode == 200){
                  Navigator.pop(context);
                  // Fluttertoast.showToast(
                  //   msg: 'Prenotazione inserita',
                  //   backgroundColor: Colors.grey[700],
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Prenotazione inserita',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ));
                  // Navigator.pop(context);
                }
                else{
                  Fluttertoast.showToast(
                    msg: res.body,
                    backgroundColor: Colors.grey[700],
                  );
                }
              },
              child: Text(
                'Salva',
                style: TextStyle(
                    color: Colors.blue
                ),
              )
              // child: Icon(
              //   Icons.add,
              //   color: Colors.blue,
              // ),
            ),
          )
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          physics: ClampingScrollPhysics(),
          // padding: EdgeInsets.only(bottom: 15),
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  margin: EdgeInsets.all(0),
                  height: 58.0,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        'Nome',
                        style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          // suffix: Icon(
                          //     Icons.keyboard_arrow_right
                          // ),
                          obscureText: false,
                          controller: _nameController,
                          clearButtonMode: _nameController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Inserire il nome del Cliente",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.placeholderText
                          ),
                          keyboardType: TextInputType.text,
                          // maxLength: 15,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                          ),
                          readOnly: false,
                          onChanged: (value) {
                            if(_nameController.text == ''){
                              setState(() {
                                editableName = false;
                              });
                            }
                            else{
                              setState(() {
                                editableName = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  // endIndent: 15,
                  // indent: 15,
                ),
              ],
            ),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  margin: EdgeInsets.all(0),
                  height: 58.0,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        'Contatto',
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          // suffix: Icon(
                          //     Icons.keyboard_arrow_right
                          // ),
                          obscureText: false,
                          controller: _contactController,
                          clearButtonMode: _contactController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Inserire il Recapito",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.placeholderText
                          ),
                          keyboardType: TextInputType.emailAddress,
                          // maxLength: 15,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                          readOnly: false,
                          onChanged: (value) {
                            if(_contactController.text == ''){
                              setState(() {
                                editableContact = false;
                              });
                            }
                            else{
                              setState(() {
                                editableContact = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  // endIndent: 20,
                  // indent: 20,
                ),
              ],
            ),

            // Column(
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            //       margin: EdgeInsets.all(0),
            //       height: 58.0,
            //       color: Colors.white,
            //       child: Row(
            //         children: [
            //           Text(
            //             'Telefono',
            //             style: TextStyle(
            //                 color: Colors.blue,
            //                 fontWeight: FontWeight.w600
            //             ),
            //           ),
            //           SizedBox(
            //             width: 15,
            //           ),
            //           Expanded(
            //             child: CupertinoTextField(
            //               // suffix: Icon(
            //               //     Icons.keyboard_arrow_right
            //               // ),
            //               obscureText: false,
            //               controller: _phoneNumberController,
            //               clearButtonMode: _phoneNumberController.text != ''
            //                 ? OverlayVisibilityMode.always
            //                 : OverlayVisibilityMode.never,
            //               enabled: true,
            //               decoration: BoxDecoration(color: Colors.white),
            //               textAlign: /*row.textAlign ??*/ TextAlign.left,
            //               placeholder: /*row.placeholder ??*/ "Inserire il numero di telefono del locale",
            //               placeholderStyle: TextStyle(
            //                   fontSize: 15,
            //                   color: CupertinoColors.placeholderText
            //               ),
            //               keyboardType: TextInputType.number,
            //               // maxLength: 15,
            //               style: TextStyle(
            //                 fontSize: 15,
            //                 color: Colors.grey[700],
            //               ),
            //               readOnly: false,
            //               onChanged: (value) {
            //                 if(_phoneNumberController.text == ''){
            //                   setState(() {
            //                     editablePhone = false;
            //                   });
            //                 }
            //                 else{
            //                   setState(() {
            //                     editablePhone = true;
            //                   });
            //                 }
            //               },
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     Divider(
            //       color: Colors.grey[400],
            //       height: 1,
            //       // endIndent: 20,
            //       // indent: 20,
            //     ),
            //   ],
            // ),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                  margin: EdgeInsets.all(0),
                  // height: 58.0,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prestazione',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      selectedId == -1 ? Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        // margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        // child: Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   children: [
                        //     ListView.separated(
                        //         separatorBuilder: (context, i) {
                        //           return SizedBox(height: 4,);
                        //         },
                        //         shrinkWrap: true,
                        //         itemCount: businessProvider.business.bookingBusinessTimetable.length,
                        //         physics: NeverScrollableScrollPhysics(),
                        //         itemBuilder: (context, i){
                        //           if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 1){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Lunedì ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 2){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Martedì ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 3){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Mercoledì ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 4){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Giovedì ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 5){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Venerdì ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 6){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Sabato ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else if(businessProvider.business.bookingBusinessTimetable[i]['weekday_id'] == 7){
                        //             return Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Domenica ',
                        //                   style: TextStyle(
                        //                     // color: Colors.blue[500],
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':' +
                        //                       formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['open_at_minute']))
                        //                       + ' - '
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_hour']) + DateTime.now().timeZoneOffset.inHours) + ':'
                        //                       + formatter.format(int.tryParse(businessProvider.business.bookingBusinessTimetable[i]['close_at_minute'])),
                        //                   style: TextStyle(
                        //                       color: Colors.grey[600],
                        //                       fontWeight: FontWeight.w600,
                        //                       fontSize: 13
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           }
                        //           else return null;
                        //         }
                        //     ),
                        //   ],
                        // ),
                      ) : Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        // margin: EdgeInsets.only(left: 33),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            GradientText(
                              prestazioneProvider.prestazioneList[selectedId].title!,
                              style: TextStyle(
                                  color: Colors.blue[500],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // textAlign: TextAlign.left,
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    // Color(0xff8921aa),
                                    // Color(0xffDA44bb),
                                    Colors.grey[900]!,
                                    Colors.grey[900]!,
                                  ]
                              ),
                            ),
                            SizedBox(height: 2,),
                            Text(
                              prestazioneProvider.prestazioneList[selectedId].duration.toString() + ' min',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5
                              ),
                              // textAlign: TextAlign.left,
                              // gradient: LinearGradient(
                              //     begin: Alignment.bottomLeft,
                              //     end: Alignment.topRight,
                              //     colors: [
                              //       Color(0xff8921aa),
                              //       Color(0xffDA44bb),
                              //       // Color(0xffDA44bb)
                              //     ]
                              // ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         duration: const Duration(milliseconds: 500),
                            //         alignment: Alignment.center,
                            //         type: PageTransitionType.fade,
                            //         child: TimetableSettingsScreen()
                            //     )
                            // );
                            showAccountSelectorSheet(
                              context: context,
                              accountList: accountList,
                              isSheetDismissible: true, //Optional
                              // initiallySelectedIndex: 2, //Optional
                              initiallySelectedIndex: selectedId, //Optional
                              hideSheetOnItemTap: false, //Optional
                              // addAccountTitle: "Add User", //Optional
                              // showAddAccountOption: true, //Optional
                              // backgroundColor: Colors.blue[700], //Optional
                              backgroundColor: Colors.white, //Optional
                              // arrowColor: Colors.white, //Optional
                              arrowColor: Colors.grey, //Optional
                              // unselectedRadioColor: Colors.white, //Optional
                              unselectedRadioColor: Colors.grey, //Optional
                              // selectedRadioColor: Colors.amber, //Optional
                              selectedRadioColor: Colors.blue[500]!, //Optional
                              // unselectedTextColor: Colors.white, //Optional
                              unselectedTextColor: Colors.grey[900], //Optional
                              // selectedTextColor: Colors.amber, //Optional
                              unselectedSubtitleColor: Colors.grey[700],
                              unselectedDatetimeColor: Colors.green[600],
                              selectedTextColor: Colors.blue[500]!, //Optional
                              //Optional
                              tapCallback: (index) {
                                setState(() {
                                  resultText = "selected account is : ${accountList[index].title}";
                                  selectedId = index;
                                });
                                // print(resultText);
                              },
                              //Optional
                              addAccountTapCallback: () {
                                setState(() {
                                  resultText = "Add account clicked";
                                });
                                // print(resultText);
                              },
                            );
                          },
                          child: const Text(
                            "Seleziona",
                            style: TextStyle(
                                color: Colors.blue
                            ),
                          )
                      )
                      // SizedBox()
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  // endIndent: 15,
                  // indent: 15,
                ),
              ],
            ),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                  margin: EdgeInsets.all(0),
                  // height: 58.0,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // "Orario d'inizio",
                        "Orario",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      selectedId == -1 && widget.beginAt != null ? Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        child: /*Gradient*/Text(
                          DateFormat.MMMMEEEEd('it_IT').format(widget.beginAt!).capitalize! + ',\n' + widget.beginAt!.toString().substring(11, 16),
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13
                          ),
                          // textAlign: TextAlign.left,
                          // gradient: LinearGradient(
                          //     begin: Alignment.bottomLeft,
                          //     end: Alignment.topRight,
                          //     colors: [
                          //       Color(0xff8921aa),
                          //       Color(0xffDA44bb),
                          //       // Color(0xffDA44bb)
                          //     ]
                          // ),
                        ),
                      ) : Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        // margin: EdgeInsets.only(left: 33),
                        child: /*Gradient*/Text(
                          DateFormat.MMMMEEEEd('it_IT').format(selectedDateTime!).capitalize! + ',\n' + selectedDateTime.toString().substring(11, 16),
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13
                          ),
                          // textAlign: TextAlign.left,
                          // gradient: LinearGradient(
                          //     begin: Alignment.bottomLeft,
                          //     end: Alignment.topRight,
                          //     colors: [
                          //       Color(0xff8921aa),
                          //       Color(0xffDA44bb),
                          //       // Color(0xffDA44bb)
                          //     ]
                          // ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            // if(selectedId > -1 && selectedId <= prestazioneProvider.prestazioneList.length - 1){
                              bottomSheetOptions(context);
                            // }
                            // else {
                            //   Fluttertoast.showToast(
                            //     msg: "Selezionare prima la Prestazione",
                            //     backgroundColor: Colors.grey[700],
                            //   );
                            // }

                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         duration: const Duration(milliseconds: 500),
                            //         alignment: Alignment.center,
                            //         type: PageTransitionType.fade,
                            //         child: TimetableSettingsScreen()
                            //     )
                            // );
                          },
                          child: const Text(
                            "Seleziona",
                            style: TextStyle(
                                color: Colors.blue
                            ),
                          )
                      )
                      // SizedBox()
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  // endIndent: 15,
                  // indent: 15,
                ),
              ],
            ),

            // Visibility(
            //   visible: businessProvider.business.business_type_id == 1,
            //   child: Column(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            //         margin: EdgeInsets.all(0),
            //         height: 58.0,
            //         color: Colors.white,
            //         child: Row(
            //           children: [
            //             Text(
            //               'Limite di\nAppuntamenti',
            //               // textAlign: TextAlign.center,
            //               style: TextStyle(
            //                   color: Colors.blue,
            //                   fontWeight: FontWeight.w600
            //               ),
            //             ),
            //             SizedBox(
            //               width: 15,
            //             ),
            //             Expanded(
            //               child: CupertinoTextField(
            //                 // suffix: Icon(
            //                 //     Icons.keyboard_arrow_right
            //                 // ),
            //                 obscureText: false,
            //                 controller: _limitController,
            //                 clearButtonMode: _limitController.text != ''
            //                     ? OverlayVisibilityMode.always
            //                     : OverlayVisibilityMode.never,
            //                 enabled: true,
            //                 decoration: BoxDecoration(color: Colors.white),
            //                 textAlign: /*row.textAlign ??*/ TextAlign.left,
            //                 placeholder: /*row.placeholder ??*/ "Limite di appuntamenti in contemporanea",
            //                 placeholderStyle: TextStyle(
            //                     fontSize: 15,
            //                     color: CupertinoColors.placeholderText
            //                 ),
            //                 keyboardType: TextInputType.number,
            //                 // maxLength: 15,
            //                 style: TextStyle(
            //                   fontSize: 15,
            //                   color: Colors.grey[700],
            //                 ),
            //                 readOnly: false,
            //                 onChanged: (value) {
            //                   if(_limitController.text == ''){
            //                     setState(() {
            //                       editableLimit = false;
            //                     });
            //                   }
            //                   else{
            //                     setState(() {
            //                       editableLimit = true;
            //                     });
            //                   }
            //                 },
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Divider(
            //         color: Colors.grey[400],
            //         height: 1,
            //         // endIndent: 15,
            //         // indent: 15,
            //       ),
            //     ],
            //   ),
            // ),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  margin: EdgeInsets.all(0),
                  // height: 58.0,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        'Note',
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          // suffix: Icon(
                          //     Icons.keyboard_arrow_right
                          // ),
                          obscureText: false,
                          controller: _descriptionController,
                          clearButtonMode: _descriptionController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Inserire note aggiuntive",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.placeholderText
                          ),
                          keyboardType: TextInputType.text,
                          minLines: 1,
                          maxLines: 80,
                          // expands: true,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                          readOnly: false,
                          onChanged: (value) {
                            if(_descriptionController.text == ''){
                              setState(() {
                                editableDescription = false;
                              });
                            }
                            else{
                              setState(() {
                                editableDescription = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[400],
                  height: 1,
                  // endIndent: 15,
                  // indent: 15,
                ),
              ],
            ),

          ],
        ),
      ),

    );
  }
}
