import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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


class BookingInsertScreen2 extends StatefulWidget {
  final DateTime? beginAt;

  const BookingInsertScreen2({Key? key, this.beginAt});

  @override
  _BookingInsertScreen2State createState() => _BookingInsertScreen2State();
}

class _BookingInsertScreen2State extends State<BookingInsertScreen2> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // final TextEditingController _limitController = TextEditingController();
  bool? editableName;
  bool? editableEmail;
  bool? editablePhone;
  // bool editableLimit;
  // bool editablePhone;
  bool? editableDescription;
  File? _image;
  // final picker = ImagePicker();
  // bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  late PrestazioneProvider prestazioneProvider;
  late BookingProvider bookingProvider;
  late SocketProvider socketProvider;
  List bookingBusinessTimetable = [];
  NumberFormat? formatter;
  String resultText = "";
  int selectedId = -1;
  DateTime? selectedDateTime /*= DateTime.now()*/;
  List<Account> accountList = [];
  TimeOfDay orario = TimeOfDay(
    hour: DateTime.now().hour,
    minute: DateTime.now().minute
  );


  Future pickDateTime(/*BuildContext context*/) async {
    final date = await pickDate(/*context*/);
    if (date == null) return;

    final time = await pickTime(/*context*/);
    if (time == null) return;

    DateTime localDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();

    int conta = 0;
    // print(businessProvider.business!.bookingBusinessTimetable);
    for(int i = 0; i < businessProvider.business!.bookingBusinessTimetable!.length; i++){
      // print(businessProvider.business!.bookingBusinessTimetable![i]);

      if(localDateTime.weekday == businessProvider.business!.bookingBusinessTimetable![i]['weekday_id']){
        DateTime openAtDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours,
          int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute'])!,
        );
        DateTime closeAtDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours,
          int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])!,
        );

        // print(openAtDateTime);
        // print(closeAtDateTime);
        // print(localDateTime);
        // print('');

        if((openAtDateTime.isBefore(localDateTime) || openAtDateTime.isAtSameMomentAs(localDateTime)) &&
          (closeAtDateTime.isAfter(localDateTime.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration!))) || closeAtDateTime.isAtSameMomentAs(localDateTime.add(Duration(minutes: prestazioneProvider.prestazioneList[selectedId].duration!))))){
          conta++;
        }

      }
    }

    // print('conta');
    // print(conta);

    if(conta == 1){
      setState(() {
        selectedDateTime = localDateTime;
      });
    }
    else {
      Fluttertoast.showToast(
        msg: "Orario al di fuori dell'orario di apertura",
        backgroundColor: Colors.grey[700],
      );
    }

  }

  Future<DateTime?> pickDate(/*BuildContext context*/) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      // locale: const Locale('it_IT')
      // locale: const Locale('it')

    );

    if (newDate == null) return null;

    return newDate;
  }

  Future<TimeOfDay?> pickTime(/*BuildContext context*/) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: selectedDateTime != null
          ? TimeOfDay(hour: selectedDateTime!.hour, minute: selectedDateTime!.minute)
          : initialTime,
    );

    if (newTime == null) return null;

    return newTime;
  }

  Future updateDatetime(/*BuildContext context*/) async {
    TimeOfDay initialTime = TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
    );

    var newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      // onEntryModeChanged: (timePickerEntryMode){
      //   print(timePickerEntryMode);
      // },
    );

    if (newTime == null) return;

    // print(newTime);

    setState(() {
      orario = newTime;
    });

  }

  @override
  void initState() {
    super.initState();
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    bookingProvider = Provider.of<BookingProvider>(context, listen: false);
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

    // Future.wait([
    // //   getDateBusinessTimetable(),
    //   appointmentProvider.init(businessProvider.business!.id, socketProvider.socketAppointments, context)
    // ]);

  }

  @override
  void dispose() {
    super.dispose();
    // appointmentProvider.timetableDay!.clear();
    // // print('openingDates00');
    // // print(openingDates.toString());
    // appointmentProvider.openingDates.clear();
    // appointmentProvider.closingDates.clear();
    // appointmentProvider.intervalliDaMezzoraPerApertura.clear();
    // appointmentProvider.intervalliDaMezzoraPerAperturaBegin.clear();
    // appointmentProvider.intervalliDaMezzoraPerAperturaEnd.clear();
    // // occupiedDates.clear();
    // // appointments.clear();
    // appointmentProvider.appointmentsDefinitive.clear();
    // // setState(() {
    // appointmentProvider.selectedDate = DateTime.now();
    // // });
  }

  @override
  Widget build(BuildContext context) {
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    bookingProvider = Provider.of<BookingProvider>(context, listen: true);
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
                if(_nameController.text == ''){
                  Fluttertoast.showToast(
                    msg: "Inserire il nome",
                    backgroundColor: Colors.grey[700],
                  );
                  return;
                }
                else if(selectedId < 0){
                  Fluttertoast.showToast(
                    msg: "Selezionare la prestazione",
                    backgroundColor: Colors.grey[700],
                  );
                  return;
                }
                else if(selectedDateTime == null){
                  Fluttertoast.showToast(
                    msg: "Selezionare il giorno e l'orario",
                    backgroundColor: Colors.grey[700],
                  );
                  return;
                }
                else if(selectedDateTime!.isBefore(DateTime.now())){
                  Fluttertoast.showToast(
                    msg: "La data non è valida",
                    backgroundColor: Colors.grey[700],
                  );
                  return;
                }

                Response res = await bookingProvider.createGuestBooking(
                    Booking(
                      user: User(profile_image: 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                      // id: e['booking_id'],
                      // isCanceled: 0,
                      note: _descriptionController.text,
                      // user_id: myAppointments[index]['user_id'].toString(),
                      prestazione: prestazioneProvider.prestazioneList[selectedId],
                      business: businessProvider.business,
                      guestEmail: _emailController.text,
                      guestPhone: _phoneController.text,
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
                      created_at: DateTime.now()/*.toUtc()*//*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
                    ),
                    context
                );
                if(res.statusCode == 200){
                  Navigator.pop(context);
                  // Fluttertoast.showToast(
                  //   msg: 'Prenotazione inserita',
                  //   backgroundColor: Colors.grey[700],
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Prenotazione inserita',
                      ),
                      backgroundColor: Colors.green,
                    )
                  );

                  //todo: da rendere piu efficiente evitando di fare le get e modificando una lista in provider
                  bookingProvider.appointments!.clear();
                  socketProvider.myAppointments.clear();
                  Future.wait([
                    bookingProvider.getAppointmentsByDate(businessProvider.business!.id, context),
                    bookingProvider.getGuestAppointmentsByDate(businessProvider.business!.id, context),
                    socketProvider.getBusinessAppointments(),
                    socketProvider.getGuestBookings(),
                  ]);

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
                      SizedBox(width: 2,),
                      Text(
                        '*',
                        style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600,
                          fontSize: 9
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
                          placeholder: /*row.placeholder ??*/ "Nome del Cliente",
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
                        'Telefono',
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
                          controller: _phoneController,
                          clearButtonMode: _phoneController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Numero di Telefono",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.placeholderText
                          ),
                          keyboardType: TextInputType.phone,
                          // maxLength: 15,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                          readOnly: false,
                          onChanged: (value) {
                            if(_phoneController.text == ''){
                              setState(() {
                                editablePhone = false;
                              });
                            }
                            else{
                              setState(() {
                                editablePhone = true;
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
                        'Email',
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
                          controller: _emailController,
                          clearButtonMode: _emailController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Email",
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
                            if(_emailController.text == ''){
                              setState(() {
                                editableEmail = false;
                              });
                            }
                            else{
                              setState(() {
                                editableEmail = true;
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
                      Row(
                        children: [
                          Text(
                            'Prestazione',
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(width: 2,),
                          Text(
                            '*',
                            style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w600,
                                fontSize: 9
                            ),
                          ),
                        ],
                      ),
                      selectedId == -1 ? Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                      ) : Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                          right: 15,
                          left: 15,
                          top: 4
                        ),
                        // margin: EdgeInsets.only(left: 33),
                        child: Row(
                          children: [
                            Container(
                              height: 35,
                              width: 35,
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
                                  prestazioneProvider.prestazioneList[selectedId].image!,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // SizedBox(height: 5),
                                Container(
                                  width: MediaQuery.of(context).size.width * .3,
                                  child: Marquee(
                                    child: GradientText(
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
                                  ),
                                ),
                                SizedBox(height: 0.5,),
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
                      Row(
                        children: [
                          Text(
                            "Orario",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(width: 2,),
                          Text(
                            '*',
                            style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w600,
                                fontSize: 9
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15,
                          top: 4
                        ),
                        // margin: EdgeInsets.only(left: 33),
                        child: /*Gradient*/Center(
                          child: Text(
                            // DateFormat.MMMMEEEEd('it_IT').format(selectedDateTime!).capitalize! + ',\n' + selectedDateTime.toString().substring(11, 16),
                            selectedDateTime == null ? '' : DateFormat.MMMMEEEEd('it_IT').format(selectedDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).capitalize! + /*' ' + selectedDateTime!.year.toString() +*/ ',\n' + selectedDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                            // "${orario.hour.toString()}:${orario.minute.toString()}",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14
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
                      ),
                      TextButton(
                          onPressed: () async {
                            // await updateDatetime();
                            if(selectedId > -1 && selectedId <= prestazioneProvider.prestazioneList.length - 1) {
                              await pickDateTime();
                            }
                            else {
                              Fluttertoast.showToast(
                                msg: 'Seleziona prima la prestazione',
                                backgroundColor: Colors.grey[700],
                              );
                            }
                            // // if(selectedId > -1 && selectedId <= prestazioneProvider.prestazioneList.length - 1){
                            //   bottomSheetOptions(context);
                            // // }
                            // // else {
                            // //   Fluttertoast.showToast(
                            // //     msg: "Selezionare prima la Prestazione",
                            // //     backgroundColor: Colors.grey[700],
                            // //   );
                            // // }
                            //
                            // // Navigator.push(
                            // //     context,
                            // //     PageTransition(
                            // //         duration: const Duration(milliseconds: 500),
                            // //         alignment: Alignment.center,
                            // //         type: PageTransitionType.fade,
                            // //         child: TimetableSettingsScreen()
                            // //     )
                            // // );
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

            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 20),
              child: Text(
                "* = Obbligatorio",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  fontSize: 12
                ),
              ),
            ),

          ],
        ),
      ),

    );
  }
}
