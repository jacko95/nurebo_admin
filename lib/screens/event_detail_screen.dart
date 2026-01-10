import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/event.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/event_ticket.dart';
import 'package:nurebo_admin/provider/event_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/popover.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/src/media_type.dart';


class EventDetailScreen extends StatefulWidget {
  final Event? event;
  // final Business eventBusiness;
  final bool isNewEvent;

  const EventDetailScreen({Key? key, this.event, /*this.eventBusiness,*/ required this.isNewEvent});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  // final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ticketTitleController = TextEditingController();
  final TextEditingController _ticketAdditionalController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  bool? editableTitle;
  // bool editableDuration;
  bool? editableDescription;
  bool? editableTicketPrice;
  bool? editableTicketTitle;
  bool? editableTicketAdditional;
  // List ticketCategories;
  /*late*/ File? _image;
  final picker = ImagePicker();
  bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  late EventProvider eventProvider;
  late NumberFormat formatter;
  DateTime? selectedDateTime = DateTime.now();
  DateTime? beginAtDate = DateTime.now();
  DateTime? beginAtDateTime = DateTime.now();
  DateTime? endAtDateTime = DateTime.now();
  DateTime? beginAtDateTime1 = DateTime.now();
  DateTime? endAtDateTime1 = DateTime.now();
  List<EventTicket> eventTicketsList = [];
  List<DateTime?> _dialogCalendarPickerValue = [
    DateTime.now(),
    // DateTime(2021, 8, 10),
    // DateTime(2021, 8, 13),
  ];
  late CalendarDatePicker2WithActionButtonsConfig config;
  // DateTime? selectedDateTime = DateTime.now();
  // Future a = Future((){});


  getAllEventTicket() {
    for(EventTicket e in eventProvider.eventTicketList) {
      if(e.event!.id == widget.event!.id) {
        eventTicketsList.add(e);
      }
    }
  }

  bottomSheetOptions(BuildContext context) {
    /*_scaffoldKey.currentState.*/showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState2) {
            return Popover(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.4),
                        child: Text(
                          // widget.isNewEvent ? 'Crea' : 'Modifica',
                          'Biglietto',
                          style: TextStyle(
                            // color: Colors.blue,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 20
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: ElevatedButton(
                          onPressed: (){
                            print('inserisci');
                            if(double.tryParse(_ticketPriceController.text.replaceAll(',', '.')) != null){
                              if(_ticketTitleController.text != '' && !double.tryParse(_ticketPriceController.text.replaceAll(',', '.'))!.isNaN
                                && double.tryParse(_ticketPriceController.text.replaceAll(',', '.')) != 0.toDouble()){
                                setState(() {
                                  eventTicketsList.add(
                                    EventTicket(
                                      // event: Event()
                                      title: _ticketTitleController.text,
                                      additional: _ticketAdditionalController.text,
                                      price: double.tryParse(double.tryParse(_ticketPriceController.text.replaceAll(',', '.'))!.toStringAsFixed(2)) ?? 0,
                                    )
                                  );
                                });

                                // Navigator.pop(context);
                                Navigator.of(context).pop();

                                _ticketTitleController.text = '';
                                _ticketAdditionalController.text = '';
                                _ticketPriceController.text = '';
                              }
                            }
                            else {
                              Fluttertoast.showToast(
                                msg: 'Inserisci Titolo e Prezzo',
                                backgroundColor: Colors.grey[700],
                              );
                            }
                          },
                          child: Text(
                            'Inserisci',
                            style: TextStyle(
                              // color: Colors.blue
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
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
                              'Titolo',
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
                                controller: _ticketTitleController,
                                clearButtonMode: _ticketTitleController.text != ''
                                    ? OverlayVisibilityMode.always
                                    : OverlayVisibilityMode.never,
                                enabled: true,

                                decoration: BoxDecoration(color: Colors.white),
                                textAlign: /*row.textAlign ??*/ TextAlign.left,
                                placeholder: /*row.placeholder ??*/ "Inserire il nome del biglietto",
                                placeholderStyle: TextStyle(
                                    fontSize: 15,
                                    color: CupertinoColors.placeholderText
                                ),
                                keyboardType: TextInputType.text,
                                minLines: 1,
                                maxLines: 8,
                                // expands: true,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                readOnly: false,
                                onChanged: (value) {
                                  if(_ticketTitleController.text == ''){
                                    setState(() {
                                      editableTicketTitle = false;
                                    });
                                  }
                                  else{
                                    setState(() {
                                      editableTicketTitle = true;
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
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        margin: EdgeInsets.all(0),
                        // height: 58.0,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Text(
                              'Sottocategoria',
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
                                controller: _ticketAdditionalController,
                                clearButtonMode: _ticketAdditionalController.text != ''
                                    ? OverlayVisibilityMode.always
                                    : OverlayVisibilityMode.never,
                                enabled: true,

                                decoration: BoxDecoration(color: Colors.white),
                                textAlign: /*row.textAlign ??*/ TextAlign.left,
                                placeholder: /*row.placeholder ??*/ "Inserire la sottocategoria del biglietto",
                                placeholderStyle: TextStyle(
                                    fontSize: 15,
                                    color: CupertinoColors.placeholderText
                                ),
                                keyboardType: TextInputType.text,
                                minLines: 1,
                                maxLines: 8,
                                // expands: true,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                readOnly: false,
                                onChanged: (value) {
                                  if(_ticketAdditionalController.text == ''){
                                    setState(() {
                                      editableTicketAdditional = false;
                                    });
                                  }
                                  else{
                                    setState(() {
                                      editableTicketAdditional = true;
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
                              'Prezzo',
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
                                controller: _ticketPriceController,
                                clearButtonMode: _ticketPriceController.text != ''
                                    ? OverlayVisibilityMode.always
                                    : OverlayVisibilityMode.never,
                                enabled: true,
                                decoration: BoxDecoration(color: Colors.white),
                                textAlign: /*row.textAlign ??*/ TextAlign.left,
                                placeholder: /*row.placeholder ??*/ "Inserire il prezzo della prestazione",
                                placeholderStyle: TextStyle(
                                    fontSize: 15,
                                    color: CupertinoColors.placeholderText
                                ),
                                keyboardType: TextInputType.number,
                                // maxLength: 15,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                readOnly: false,
                                onChanged: (value) {
                                  // print(_priceController.text);
                                  // print(double.tryParse(_priceController.text.replaceAll(',','.')));
                                  if(_ticketPriceController.text == ''){
                                    setState(() {
                                      editableTicketPrice = false;
                                    });
                                  }
                                  else{
                                    setState(() {
                                      editableTicketPrice = true;
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45,)
                ],
              )
            );
          }
        );
      },
    );
  }

  Future choiceImage() async {
    // var pickedImage = await picker.getImage(source: ImageSource.gallery);
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    // PickedFile pickedImage = await picker.getVideo(source: ImageSource.gallery);

    // _video = File(pickedFile.path);
    setState(() {
      _image = File(pickedImage!.path);
      isSelectedImage = true;
    });
  }

  // Future getAllEventCategories() async {
  //   var url = Uri.parse(Constants.httpServerUrl + "single_event_ticket/single_event");
  //   // var ticketCategoryProvider = Provider.of<TicketProvider>(context/*, listen: false*/);
  //
  //   Map/*<String, String>*/ body = {
  //     'single_event_id': widget.singleEvent.id,
  //   };
  //
  //   var response = await http.post(
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
  //   print('response.statusCode');
  //   print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       ticketCategories = jsonData.toList();
  //     });
  //
  //     print(jsonData);
  //     print(ticketCategories);
  //     return jsonData;
  //   }
  // }

  void _showDeletingDialog(String module) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Cancellare prestazione',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Cancella',
            confirmCallback: () async {
              int statusCode = await eventProvider.deleteEvent(
                  businessProvider.business!.id,
                  widget.event!.id,
                  context
              );
              if(statusCode == 200){
                Navigator.pop(context);
                // Fluttertoast.showToast(
                //   msg: 'Prestazione cancellata',
                //   backgroundColor: Colors.grey[700],
                // );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Prestazione cancellata',
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
              }
            },

            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );
        }
    );
  }

  // Future<TimeOfDay?> pickTime(BuildContext context) async {
  //   const initialTime = TimeOfDay(hour: 9, minute: 0);
  //   final newTime = await showTimePicker(
  //     context: context,
  //     initialEntryMode: TimePickerEntryMode.input,
  //     initialTime: beginAt != null ? TimeOfDay(hour: beginAt!.hour, minute: beginAt!.minute) : initialTime,
  //   );
  //
  //
  //   // if (newTime == null) return null;
  //
  //   return newTime;
  // }

  Future<DateTime?> pickDateTime(/*BuildContext context*/) async {
    final date = await pickDate(/*context*/);
    if (date == null) return null;

    final time = await pickTime(/*context*/DateTime.now());
    if (time == null) return null;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour - DateTime.now().timeZoneOffset.inHours,
        time.minute,
      );
    });

    return selectedDateTime;
  }

  Future<DateTime?> pickDate(/*BuildContext context*/) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: beginAtDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)) ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      // locale: const Locale('it_IT')
      // locale: const Locale('it')

    );

    if (newDate == null) return null;

    return newDate;
  }

  Future<TimeOfDay?> pickTime(/*BuildContext context*/DateTime dateTime) async {
    // final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
    );

    if (newTime == null) return null;

    return newTime;
  }

  // _buildCalendarDialogButton() {
  //   var config = CalendarDatePicker2WithActionButtonsConfig(
  //     // calendarType: CalendarDatePicker2Type.range,
  //       calendarType: CalendarDatePicker2Type.single,
  //       selectedDayHighlightColor: Colors.purple[800],
  //       shouldCloseDialogAfterCancelTapped: true,
  //       openedFromDialog: true,
  //       okButton: InkWell(
  //         onTap: () async {
  //           Navigator.pop(context);
  //           await pickTime(context);
  //         },
  //         child: Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           child: Text(
  //             'OK',
  //             style: TextStyle(
  //                 color: Colors.purple[800],
  //                 fontWeight: FontWeight.w700,
  //                 fontSize: 15
  //             ),
  //           ),
  //         ),
  //       )
  //   );
  //   return Padding(
  //     padding: const EdgeInsets.all(15),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         ElevatedButton(
  //           onPressed: () async {
  //             var values = await showCalendarDatePicker2Dialog(
  //               context: context,
  //               config: config,
  //               dialogSize: const Size(325, 400),
  //               borderRadius: 15,
  //               initialValue: _dialogCalendarPickerValue,
  //               dialogBackgroundColor: Colors.white,
  //               selectableDayPredicate: (day) => !day
  //                   .difference(_dialogCalendarPickerValue[0]
  //                   .subtract(const Duration(days: 5)))
  //                   .isNegative,
  //             );
  //             if (values != null) {
  //               // ignore: avoid_print
  //               // print(_getValueText(
  //               //   config.calendarType,
  //               //   values,
  //               // ));
  //               setState(() {
  //                 _dialogCalendarPickerValue = values;
  //               });
  //             }
  //           },
  //           child: const Text('Open Calendar Dialog'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    eventProvider = Provider.of<EventProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    initializeDateFormatting();
    formatter = NumberFormat("00");

    if(widget.event!.title != null) {
      _titleController.text = widget.event!.title!;
    }
    if(widget.event!.description != null) {
      _descriptionController.text = widget.event!.description!;
    }
    if(widget.event!.begin_at != null) {
      beginAtDate = widget.event!.begin_at;
      beginAtDateTime = widget.event!.begin_at;
      beginAtDateTime1 = widget.event!.begin_at;
    }
    if(widget.event!.end_at != null) {
      endAtDateTime = widget.event!.end_at;
      endAtDateTime1 = widget.event!.end_at;
    }
    // if(widget.event.duration != null) {
    //   _durationController.text = widget.event.duration.toString();
    // }
    // if(widget.event.price != null) {
    //   _priceController.text = widget.event.price.toString();
    // }

    // config = CalendarDatePicker2WithActionButtonsConfig(
    //   // calendarType: CalendarDatePicker2Type.range,
    //     calendarType: CalendarDatePicker2Type.single,
    //     selectedDayHighlightColor: Colors.purple[800],
    //     closeDialogOnCancelTapped: true,
    //
    //     selectableDayPredicate: (day) {
    //       return !day.difference(DateTime.now().subtract(const Duration(days: 5))).isNegative;
    //     },
    //     // openedFromDialog: true,
    //     openedFromDialog: false,
    //     okButton: InkWell(
    //       onTap: () async {
    //         Navigator.pop(context);
    //         TimeOfDay? beginAtTime = await pickTime(context);
    //         print(beginAtTime);
    //         print(beginAtTime);
    //         print(_dialogCalendarPickerValue);
    //         // beginAtDateTime = DateTime(
    //         //
    //         // );
    //       },
    //       child: Padding(
    //         padding: const EdgeInsets.only(right: 8.0),
    //         child: Text(
    //           'OK',
    //           style: TextStyle(
    //               color: Colors.purple[800],
    //               fontWeight: FontWeight.w700,
    //               fontSize: 15
    //           ),
    //         ),
    //       ),
    //     )
    // );


    // Future.wait([
      getAllEventTicket();
    // ] as Iterable<Future>);

  }

  @override
  Widget build(BuildContext context) {
    eventProvider = Provider.of<EventProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

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
        // centerTitle: true,
        title: Text(
          widget.isNewEvent ? 'Crea' : 'Modifica',
          style: TextStyle(
              // color: Colors.blue,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 15
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
                  // if(!widget.isNewEvent && _priceController.text != '' && _durationController.text != '') {
                  //   // upbookingPrestazione();
                  //   int statusCode = await eventProvider.updatePrestazione(
                  //       prestazioneId: widget.event.id,
                  //       businessId: businessProvider.business.id,
                  //       title: _titleController.text,
                  //       description: _descriptionController.text,
                  //       duration: _durationController.text,
                  //       price: _priceController.text,
                  //       image: widget.event.image,
                  //       uploadImage: _image,
                  //       /*NumberFormat.currency(
                  //         // customPattern: '#,##',
                  //       decimalDigits: 2,
                  //         locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
                  //       context: this.context
                  //   );
                  //
                  //   if(statusCode == 200){
                  //     Navigator.pop(context);
                  //     // await Flushbar(
                  //     //   // title: "Hey",
                  //     //   // titleColor: Colors.white,
                  //     //   // message: "La prestazione è stata creata con successo",
                  //     //
                  //     //   flushbarPosition: FlushbarPosition.BOTTOM,
                  //     //   flushbarStyle: FlushbarStyle.GROUNDED,
                  //     //   reverseAnimationCurve: Curves.decelerate,
                  //     //   forwardAnimationCurve: Curves.easeIn,
                  //     //   backgroundColor: Colors.black,
                  //     //   // boxShadows: [
                  //     //   //   BoxShadow(
                  //     //   //       color: Colors.blue[800],
                  //     //   //       offset: Offset(0.0, 2.0),
                  //     //   //       blurRadius: 3.0
                  //     //   //   )
                  //     //   // ],
                  //     //   // backgroundGradient: LinearGradient(
                  //     //   //     colors: [
                  //     //   //       Colors.blueGrey,
                  //     //   //       Colors.black
                  //     //   //     ]
                  //     //   // ),
                  //     //   isDismissible: false,
                  //     //   duration: Duration(seconds: 4),
                  //     //   icon: Icon(
                  //     //     Icons.check,
                  //     //     color: Colors.blue[500],
                  //     //     size: 25,
                  //     //
                  //     //   ),
                  //     //   // mainButton: FlatButton(
                  //     //   //   onPressed: () {},
                  //     //   //   child: Text(
                  //     //   //     "CLAP",
                  //     //   //     style: TextStyle(color: Colors.amber),
                  //     //   //   ),
                  //     //   // ),
                  //     //   // showProgressIndicator: true,
                  //     //   // progressIndicatorBackgroundColor: Colors.blueGrey,
                  //     //   // titleText: Text(
                  //     //   //   "Hello Hero",
                  //     //   //   style: TextStyle(
                  //     //   //       fontWeight: FontWeight.bold,
                  //     //   //       fontSize: 20.0,
                  //     //   //       color: Colors.yellow[600],
                  //     //   //       fontFamily: "ShadowsIntoLightTwo"
                  //     //   //   ),
                  //     //   // ),
                  //     //
                  //     //   messageText: Text(
                  //     //     "La prestazione è stata aggiornata con successo",
                  //     //     style: TextStyle(
                  //     //       fontSize: 15.0,
                  //     //       color: Colors.white,
                  //     //       fontWeight: FontWeight.w600,
                  //     //       // fontFamily: "ShadowsIntoLightTwo"
                  //     //     ),
                  //     //   ),
                  //     // ).show(context)/*.then((value) => Navigator.pop(context))*/;
                  //     Fluttertoast.showToast(
                  //       msg: 'Prestazione aggiornata',
                  //       backgroundColor: Colors.grey[700],
                  //     );
                  //   }
                  //
                  // }
                  // else if(widget.isNewEvent && _priceController.text != '' && _durationController.text != '') {
                  //   // createPrestazione();
                  //   int statusCode = await eventProvider.createPrestazione(
                  //       title: _titleController.text,
                  //       // businessId: widget.eventBusiness.id,
                  //       businessId: businessProvider.business.id,
                  //       description: _descriptionController.text,
                  //       duration: _durationController.text,
                  //       price: _priceController.text,
                  //       uploadImage: _image,
                  //       /*NumberFormat.currency(
                  //       // customPattern: '#,##',
                  //     decimalDigits: 2,
                  //       locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
                  //       context: this.context
                  //   );
                  //
                  //   print(statusCode);
                  //
                  //   if(statusCode == 200){
                  //     Navigator.pop(context);
                  //     // await Flushbar(
                  //     //   // title: "Hey",
                  //     //   // titleColor: Colors.white,
                  //     //   // message: "La prestazione è stata creata con successo",
                  //     //
                  //     //   flushbarPosition: FlushbarPosition.BOTTOM,
                  //     //   flushbarStyle: FlushbarStyle.GROUNDED,
                  //     //   reverseAnimationCurve: Curves.decelerate,
                  //     //   forwardAnimationCurve: Curves.easeIn,
                  //     //   backgroundColor: Colors.black,
                  //     //   // boxShadows: [
                  //     //   //   BoxShadow(
                  //     //   //       color: Colors.blue[800],
                  //     //   //       offset: Offset(0.0, 2.0),
                  //     //   //       blurRadius: 3.0
                  //     //   //   )
                  //     //   // ],
                  //     //   // backgroundGradient: LinearGradient(
                  //     //   //     colors: [
                  //     //   //       Colors.blueGrey,
                  //     //   //       Colors.black
                  //     //   //     ]
                  //     //   // ),
                  //     //   isDismissible: false,
                  //     //   duration: Duration(seconds: 4),
                  //     //   icon: Icon(
                  //     //     Icons.check,
                  //     //     color: Colors.blue[500],
                  //     //     size: 25,
                  //     //
                  //     //   ),
                  //     //   // mainButton: FlatButton(
                  //     //   //   onPressed: () {},
                  //     //   //   child: Text(
                  //     //   //     "CLAP",
                  //     //   //     style: TextStyle(color: Colors.amber),
                  //     //   //   ),
                  //     //   // ),
                  //     //   // showProgressIndicator: true,
                  //     //   // progressIndicatorBackgroundColor: Colors.blueGrey,
                  //     //   // titleText: Text(
                  //     //   //   "Hello Hero",
                  //     //   //   style: TextStyle(
                  //     //   //       fontWeight: FontWeight.bold,
                  //     //   //       fontSize: 20.0,
                  //     //   //       color: Colors.yellow[600],
                  //     //   //       fontFamily: "ShadowsIntoLightTwo"
                  //     //   //   ),
                  //     //   // ),
                  //     //   messageText: Text(
                  //     //     "La prestazione è stata creata con successo",
                  //     //     style: TextStyle(
                  //     //       fontSize: 15.0,
                  //     //       color: Colors.white,
                  //     //       fontWeight: FontWeight.w600,
                  //     //       // fontFamily: "ShadowsIntoLightTwo"
                  //     //     ),
                  //     //   ),
                  //     // ).show(context);
                  //     Fluttertoast.showToast(
                  //       msg: 'Prestazione inserita',
                  //       backgroundColor: Colors.grey[700],
                  //     );
                  //     print('prestazioneProvider.prestazioneList');
                  //     for(var e in eventProvider.prestazioneList){
                  //       print(e);
                  //
                  //     }
                  //   }
                  // }
                  // else if(_durationController.text == '' && _priceController.text != ''){
                  //   Fluttertoast.showToast(
                  //     msg: 'Inserire Durata',
                  //     backgroundColor: Colors.grey[700],
                  //   );
                  // }
                  // else if(_priceController.text == '' && _durationController.text != ''){
                  //   Fluttertoast.showToast(
                  //     msg: 'Inserire Prezzo',
                  //     backgroundColor: Colors.grey[700],
                  //   );
                  // }
                  // else if(_priceController.text == '' && _priceController.text == ''){
                  //   Fluttertoast.showToast(
                  //     msg: 'Inserire Prezzo e Durata',
                  //     backgroundColor: Colors.grey[700],
                  //   );
                  // }
                  // // uploadCoverEventImage();

                  print(jsonEncode(eventTicketsList));
                  print(beginAtDateTime1.toString());

                  // await createEvent(uploadImage: _image);

                  if(widget.isNewEvent){
                    await eventProvider.createEvent(
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      beginAtDateTime1: beginAtDateTime1!,
                      endAtDateTime1: endAtDateTime1!,
                      eventTicketsList: eventTicketsList,
                      uploadImage: _image,
                      context: context
                    );
                  }
                  else {
                    await eventProvider.updateEvent(
                      eventId: widget.event!.id!,
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      beginAtDateTime1: beginAtDateTime1!,
                      endAtDateTime1: endAtDateTime1!,
                      eventTicketsList: eventTicketsList,
                      uploadImage: _image,
                      context: context,
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
          // shrinkWrap: true,
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
                        'Titolo',
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
                          controller: _titleController,
                          clearButtonMode: _titleController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Inserire il titolo dell'evento",
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
                            if(_titleController.text == ''){
                              setState(() {
                                editableTitle = false;
                              });
                            }
                            else{
                              setState(() {
                                editableTitle = true;
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
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                      child: Text(
                        "Immagine dell'evento",
                        // "Immagine di copertina",
                        // 'Immagini',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    Container(
                      // height: 100,
                      height: MediaQuery.of(context).size.height * 0.2,
                      //wrapparlo con futurebuilder per creare l image file dall' image network
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        // itemCount: (row.state as List).length,
                        // itemCount: widget.numImages,
                        // itemCount: widget.images.length,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          // _image = images[index];
                          // print(widget.images.length);
                          return InkWell(
                            onTap: () async {
                              // print('ciao');
                              await choiceImage();
                              // print('_image.path');
                              // print(_image.path);
                              // return SelectImageView(
                              //   selected: (image /*= FileImage().images[index]*/) async {
                              //     // images[index];
                              //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                              //     // row.state[index]["picurl"] = image.path;
                              //   },
                              // );
                            },
                            child: isSelectedImage == false && widget.event!.image != null && widget.event!.image != '' ? FutureImage(
                              widget.event!.image!,
                              width: MediaQuery.of(context).size.width,
                              // colorBlendMode: BlendMode.darken,
                              // colorBlendMode: BlendMode.hardLight,
                              // width: 45,
                              // height: 45,
                              // filterQuality: FilterQuality.high,
                              // placeholder: (context, url) => Center(
                              //     child: CircularProgressIndicator()
                              // ),
                            ) : isSelectedImage == true ? Image.file(_image!) : Container(
                                  // width: 110,
                                  width: MediaQuery.of(context).size.width,
                                  // height: 100,
                                  // height: MediaQuery.of(context).size.height * 0.3,
                                  // margin: EdgeInsets.all(5),
                                  color: Colors.grey[200],
                                ),
                              );

                          // return SelectImageView(
                          //   selected: (image) async {
                          //     final response = await http.get(images[index]);
                          //     final documentDirectory = await getApplicationDocumentsDirectory();
                          //     final file = File(join(documentDirectory.path, images[index].toString().substring(15)));
                          //     file.writeAsBytesSync(response.bodyBytes);
                          //     image = file;
                          //     // Directory dir = await getApplicationDocumentsDirectory();
                          //     // String pathName = p.join(dir.path, filename);
                          //     // var myImageFile = File(pathName);
                          //     // images[index];
                          //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                          //     // row.state[index]["picurl"] = image.path;
                          //   },
                          // );
                        },
                      ),
                    ),
                    SizedBox(height: 15,),
                  ],
                ),
              ),
            ),
            // Column(
            //   children: [
            //     EventImagesWidget(
            //       text: "Immagine di copertina dell'evento",
            //       numImages: 1,
            //       images: [
            //         widget.singleEvent.image
            //       ],
            //     ),
            //     Divider(
            //       color: Colors.grey[400],
            //       height: 1,
            //       // endIndent: 20,
            //       // indent: 20,
            //     ),
            //   ],
            // ),
            Divider(
              color: Colors.grey[400],
              height: 1,
              // endIndent: 20,
              // indent: 20,
            ),
            // Column(
            //   children: [
            //     EventImagesWidget(
            //       text: "Immagini dell'evento",
            //       // numImages: 5,
            //       images: [],
            //     ),
            //     Divider(
            //       color: Colors.grey[400],
            //       height: 1,
            //       // endIndent: 20,
            //       // indent: 20,
            //     ),
            //   ],
            // ),
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
            //             'Prezzo',
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
            //               controller: _priceController,
            //               clearButtonMode: _priceController.text != ''
            //                   ? OverlayVisibilityMode.always
            //                   : OverlayVisibilityMode.never,
            //               enabled: true,
            //               decoration: BoxDecoration(color: Colors.white),
            //               textAlign: /*row.textAlign ??*/ TextAlign.left,
            //               placeholder: /*row.placeholder ??*/ "Inserire il prezzo della prestazione",
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
            //                 if(_priceController.text == ''){
            //                   setState(() {
            //                     editablePrice = false;
            //                   });
            //                 }
            //                 else{
            //                   setState(() {
            //                     editablePrice = true;
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
            //             'Durata',
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
            //               controller: _durationController,
            //               clearButtonMode: _durationController.text != ''
            //                   ? OverlayVisibilityMode.always
            //                   : OverlayVisibilityMode.never,
            //               enabled: true,
            //               decoration: BoxDecoration(color: Colors.white),
            //               textAlign: /*row.textAlign ??*/ TextAlign.left,
            //               placeholder: /*row.placeholder ??*/ "Inserire la durata in minuti della prestazione",
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
            //                 if(_durationController.text == ''){
            //                   setState(() {
            //                     editableDuration = false;
            //                   });
            //                 }
            //                 else{
            //                   setState(() {
            //                     editableDuration = true;
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
                        // 'Orari di Apertura',
                        'Data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .5,
                        // height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                        height: 70,
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 20,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  DateFormat.yMMMMd('it_IT').format(beginAtDate!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         duration: const Duration(milliseconds: 500),
                            //         alignment: Alignment.center,
                            //         type: PageTransitionType.fade,
                            //         child: TimetableSettingsScreen()
                            //     )
                            // );
                            // var values = await showCalendarDatePicker2Dialog(
                            //   context: context,
                            //   config: config,
                            //   dialogSize: const Size(325, 400),
                            //   // borderRadius: 15,
                            //
                            //   // initialValue: _dialogCalendarPickerValue,
                            //   value: _dialogCalendarPickerValue,
                            //   dialogBackgroundColor: Colors.white,
                            // );
                            // if (values != null) {
                            //   // ignore: avoid_print
                            //   // print(_getValueText(
                            //   //   config.calendarType,
                            //   //   values,
                            //   // ));
                            //   setState(() {
                            //     _dialogCalendarPickerValue = values;
                            //   });
                            //
                            // }

                            // setState(() async {
                            beginAtDate = await pickDate();
                            // });
                            // beginAtDateTime = await pickDateTime();

                            beginAtDateTime1 = DateTime(
                              beginAtDate!.year,
                              beginAtDate!.month,
                              beginAtDate!.day,
                              // endTime!.hour,
                              // endTime.minute,
                            );
                            endAtDateTime1 = DateTime(
                              beginAtDate!.year,
                              beginAtDate!.month,
                              beginAtDate!.day,
                              // endTime!.hour,
                              // endTime.minute,
                            );

                            print(beginAtDate);

                            // print(_dialogCalendarPickerValue);
                            // print(values);
                              setState(() {});
                          },
                          child: Text(
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
                        // 'Orari di Apertura',
                        'Inizio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .5,
                        // height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                        height: 70,
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 20,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  DateFormat.yMMMMd('it_IT').format(beginAtDateTime1!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  beginAtDateTime1!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         duration: const Duration(milliseconds: 500),
                            //         alignment: Alignment.center,
                            //         type: PageTransitionType.fade,
                            //         child: TimetableSettingsScreen()
                            //     )
                            // );
                            // var values = await showCalendarDatePicker2Dialog(
                            //   context: context,
                            //   config: config,
                            //   dialogSize: const Size(325, 400),
                            //   // borderRadius: 15,
                            //
                            //   // initialValue: _dialogCalendarPickerValue,
                            //   value: _dialogCalendarPickerValue,
                            //   dialogBackgroundColor: Colors.white,
                            // );
                            // if (values != null) {
                            //   // ignore: avoid_print
                            //   // print(_getValueText(
                            //   //   config.calendarType,
                            //   //   values,
                            //   // ));
                            //   setState(() {
                            //     _dialogCalendarPickerValue = values;
                            //   });
                            //
                            // }

                            // setState(() async {
                            TimeOfDay? beginTime = await pickTime(beginAtDateTime1!);
                            // });
                            // beginAtDateTime = await pickDateTime();
                            print(beginTime);

                            beginAtDateTime1 = DateTime(
                              beginAtDate!.year,
                              beginAtDate!.month,
                              beginAtDate!.day,
                              beginTime!.hour,
                              beginTime.minute,
                            );

                            print(beginAtDateTime1);

                            if(endAtDateTime1!.isBefore(beginAtDateTime1!)){
                              print('yes');
                              // endAtDateTime1!.add(const Duration(hours: 24));
                              endAtDateTime1 = DateTime(
                                beginAtDate!.year,
                                beginAtDate!.month,
                                beginAtDate!.day + 1,
                                endAtDateTime1!.hour,
                                endAtDateTime1!.minute,
                              );
                            }

                            setState(() {});
                          },
                          child: Text(
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
                        // 'Orari di Apertura',
                        'Fine',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .5,
                        // height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                        height: 70,
                        padding: EdgeInsets.only(
                          right: 15,
                          left: 15
                        ),
                        margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 20,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  DateFormat.yMMMMd('it_IT').format(endAtDateTime1!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                                SizedBox(width: 5,),
                                Text(
                                  endAtDateTime1!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         duration: const Duration(milliseconds: 500),
                            //         alignment: Alignment.center,
                            //         type: PageTransitionType.fade,
                            //         child: TimetableSettingsScreen()
                            //     )
                            // );
                            // var values = await showCalendarDatePicker2Dialog(
                            //   context: context,
                            //   config: config,
                            //   dialogSize: const Size(325, 400),
                            //   // borderRadius: 15,
                            //
                            //   // initialValue: _dialogCalendarPickerValue,
                            //   value: _dialogCalendarPickerValue,
                            //   dialogBackgroundColor: Colors.white,
                            // );
                            // if (values != null) {
                            //   // ignore: avoid_print
                            //   // print(_getValueText(
                            //   //   config.calendarType,
                            //   //   values,
                            //   // ));
                            //   setState(() {
                            //     _dialogCalendarPickerValue = values;
                            //   });
                            //
                            // }

                            // setState(() async {
                            TimeOfDay? endTime = await pickTime(endAtDateTime1!);
                            // });
                            // beginAtDateTime = await pickDateTime();
                            print(endTime);

                            endAtDateTime1 = DateTime(
                              beginAtDate!.year,
                              beginAtDate!.month,
                              beginAtDate!.day,
                              endTime!.hour,
                              endTime.minute,
                            );

                            print('endAtDateTime154545');
                            print(endAtDateTime1);

                            if(endAtDateTime1!.isBefore(beginAtDateTime1!)){
                              print('yes');
                              // endAtDateTime1!.add(const Duration(hours: 24));
                              endAtDateTime1 = DateTime(
                                beginAtDate!.year,
                                beginAtDate!.month,
                                beginAtDate!.day + 1,
                                endAtDateTime1!.hour,
                                endAtDateTime1!.minute,
                              );
                            }

                            print('endAtDateTime155256');
                            print(endAtDateTime1);

                            setState(() {});
                          },
                          child: Text(
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
            Visibility(
              visible: false,
              child: Column(
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
                          // 'Orari di Apertura',
                          'Inizio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue[500],
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          // height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                          height: 70,
                          padding: EdgeInsets.only(
                              right: 15,
                              left: 15
                          ),
                          margin: EdgeInsets.only(left: 33),
                          // color: Colors.red,
                          // clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 20,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    DateFormat.yMMMMd('it_IT').format(beginAtDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Colors.grey[700],
                                    size: 20,
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    beginAtDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        TextButton(
                            onPressed: () async {

                              // setState(() async {
                                beginAtDateTime = await pickDateTime();
                              // });
                              // beginAtDateTime = await pickDateTime();

                              setState(() {});

                              print(beginAtDateTime);

                              // print(_dialogCalendarPickerValue);
                              // print(values);
                            },
                            child: Text(
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
            ),
            Visibility(
              visible: false,
              child: Column(
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
                          // 'Orari di Apertura',
                          'Fine',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue[500],
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          // height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                          height: 70,
                          padding: EdgeInsets.only(
                              right: 15,
                              left: 15
                          ),
                          margin: EdgeInsets.only(left: 33),
                          // color: Colors.red,
                          // clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 20,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    DateFormat.yMMMMd('it_IT').format(endAtDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Colors.grey[700],
                                    size: 20,
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    endAtDateTime!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              // Navigator.push(
                              //     context,
                              //     PageTransition(
                              //         duration: const Duration(milliseconds: 500),
                              //         alignment: Alignment.center,
                              //         type: PageTransitionType.fade,
                              //         child: TimetableSettingsScreen()
                              //     )
                              // );
                              // var values = await showCalendarDatePicker2Dialog(
                              //   context: context,
                              //   config: config,
                              //   dialogSize: const Size(325, 400),
                              //   // borderRadius: 15,
                              //
                              //   // initialValue: _dialogCalendarPickerValue,
                              //   value: _dialogCalendarPickerValue,
                              //   dialogBackgroundColor: Colors.white,
                              // );
                              // if (values != null) {
                              //   // ignore: avoid_print
                              //   // print(_getValueText(
                              //   //   config.calendarType,
                              //   //   values,
                              //   // ));
                              //   setState(() {
                              //     _dialogCalendarPickerValue = values;
                              //   });
                              //
                              // }

                              // setState(() async {
                              endAtDateTime = await pickDateTime();
                              // });
                              // beginAtDateTime = await pickDateTime();

                              setState(() {});

                              print(endAtDateTime);
                            },
                            child: Text(
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
                        'Descrizione',
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
                          placeholder: /*row.placeholder ??*/ "Inserire la descrizione dell'evento",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.placeholderText
                          ),
                          keyboardType: TextInputType.text,
                          minLines: 1,
                          maxLines: 8,
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
                  // endIndent: 20,
                  // indent: 20,
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
                        // 'Orari di Apertura',
                        'Biglietti',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .48,
                        // height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                        height: (eventTicketsList.length * MediaQuery.of(context).size.height*0.12 + (20)).toDouble(),
                        // height: (eventProvider.eventTicketList.length * MediaQuery.of(context).size.height*0.12 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState2) {
                                return ListView.builder(
                                  itemCount: eventTicketsList.length,
                                  // itemCount: eventProvider.eventTicketList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, i) {
                                    return Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      elevation: 3,
                                      color: Colors.grey[700],
                                      // color: Colors.blue[300],
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10.0, top: 8),
                                            child: Text(
                                              eventTicketsList[i].title! ?? '',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10.0, top: 4),
                                            child: Text(
                                              eventTicketsList[i].additional! ?? '',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10.0, top: 14, bottom: 8),
                                            child: Text(
                                                eventTicketsList[i].price != 0.toDouble() ? '€ ${NumberFormat.currency(
                                                // customPattern: '#,##',
                                                  decimalDigits: 2,
                                                  symbol: '',
                                                  locale: 'IT_it'
                                              ).format(eventTicketsList[i].price ?? 0)}' : '',
                                              style: TextStyle(
                                                color: Colors.pink[50],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                );
                              }
                            )
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         duration: const Duration(milliseconds: 500),
                            //         alignment: Alignment.center,
                            //         type: PageTransitionType.fade,
                            //         child: TimetableSettingsScreen()
                            //     )
                            // );
                            // var config = CalendarDatePicker2WithActionButtonsConfig(
                            //   // calendarType: CalendarDatePicker2Type.range,
                            //     calendarType: CalendarDatePicker2Type.single,
                            //     selectedDayHighlightColor: Colors.purple[800],
                            //     closeDialogOnCancelTapped: true,
                            //     selectableDayPredicate: (day) => !day
                            //         .difference(_dialogCalendarPickerValue[0]!
                            //         .subtract(const Duration(days: 5)))
                            //         .isNegative,
                            //     // openedFromDialog: true,
                            //     openedFromDialog: false,
                            //     okButton: InkWell(
                            //       onTap: () async {
                            //         Navigator.pop(context);
                            //         await pickTime(context);
                            //       },
                            //       child: Padding(
                            //         padding: const EdgeInsets.only(right: 8.0),
                            //         child: Text(
                            //           'OK',
                            //           style: TextStyle(
                            //               color: Colors.purple[800],
                            //               fontWeight: FontWeight.w700,
                            //               fontSize: 15
                            //           ),
                            //         ),
                            //       ),
                            //     )
                            // );
                            // var values = await showCalendarDatePicker2Dialog(
                            //   context: context,
                            //   config: config,
                            //   dialogSize: const Size(325, 400),
                            //   // borderRadius: 15,
                            //
                            //   // initialValue: _dialogCalendarPickerValue,
                            //   value: _dialogCalendarPickerValue,
                            //   dialogBackgroundColor: Colors.white,
                            // );
                            // if (values != null) {
                            //   // ignore: avoid_print
                            //   // print(_getValueText(
                            //   //   config.calendarType,
                            //   //   values,
                            //   // ));
                            //   setState(() {
                            //     _dialogCalendarPickerValue = values;
                            //   });
                            // }

                            // await showModalBottomSheet(
                            // await showBottomSheet(
                            //   context: context,
                            //   backgroundColor: Colors.transparent,
                            //   isScrollControlled: true,
                            //   builder: (BuildContext context) {
                            //     return Container(height: 100, color: Colors.grey,);
                            //   },
                            // );
                            await bottomSheetOptions(context);
                          },
                          child: Text(
                            "Aggiungi",
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

            Visibility(
              visible: !widget.isNewEvent!,
              child: Container(
                // height: MediaQuery.of(context).size.width * 0.1,
                // width: MediaQuery.of(context).size.width * 0.4,
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.2,
                    right: MediaQuery.of(context).size.width * 0.2,
                    top: 45,
                    bottom: 35
                ),
                child: ElevatedButton(
                // child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.red[500],
                        // backgroundColor: Colors.white,
                        // minimumSize: Size(50, 30),
                        alignment: Alignment.center
                    ),
                    onPressed: () async {
                      _showDeletingDialog(
                          "Premere su 'Cancella' se si vuole cancellare definitivamente la prestazione"
                      );
                    },
                    child: Text(
                      'Cancella',
                      style: TextStyle(
                        // color: Colors.blue[500],
                        // color: Colors.red[500],
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    )
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}
