import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:in_app_notification/in_app_notification.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/home_screen.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/main.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class PrestazioneDetailScreen extends StatefulWidget {
  final Prestazione? prestazione;
  // final Business eventBusiness;
  final bool? isNewPrestazione;

  const PrestazioneDetailScreen({super.key, this.prestazione, /*this.eventBusiness,*/ this.isNewPrestazione});

  @override
  _PrestazioneDetailScreenState createState() => _PrestazioneDetailScreenState();
}

class _PrestazioneDetailScreenState extends State<PrestazioneDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool? editableTitle;
  bool? editablePrice;
  bool? editablePriceMin;
  bool? editablePriceMax;
  bool? editableDuration;
  bool? editableDescription;
  // List ticketCategories;
  File? _image;
  final picker = ImagePicker();
  bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  late PrestazioneProvider prestazioneProvider;
  bool isSaved = false;
  bool isPriceRange = false;


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
              int statusCode = await prestazioneProvider.deletePrestazione(businessProvider.business!.id, widget.prestazione!.id, context);
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

  @override
  void initState() {
    super.initState();
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // if(widget.prestazione!.is_price_range != null) {
      isPriceRange = widget.prestazione!.is_price_range/*!*/;
    // }
    if(widget.prestazione!.title != null) {
      _titleController.text = widget.prestazione!.title!;
    }
    if(widget.prestazione!.description != null) {
      _descriptionController.text = widget.prestazione!.description!;
    }
    if(widget.prestazione!.duration != null) {
      _durationController.text = widget.prestazione!.duration.toString();
    }
    if(widget.prestazione!.price != null) {
      _priceController.text = widget.prestazione!.price.toString();
    }
    if(widget.prestazione!.price_min != null) {
      _priceMinController.text = widget.prestazione!.price_min.toString();
    }
    if(widget.prestazione!.price_max != null) {
      _priceMaxController.text = widget.prestazione!.price_max.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue[500])
          ),
          child: isSaved ? Transform.scale(scale: 0.6, child: const CircularProgressIndicator(color: Colors.white, ),) : Text(
            "Salva",
            // "Avvia campagna",
            // 'Continua',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700
            ),
          ),
          onPressed: () async {
            if(!widget.isNewPrestazione! && ((!isPriceRange && double.tryParse(_priceController.text) != null) || (isPriceRange && (double.tryParse(_priceMinController.text) != null && double.tryParse(_priceMaxController.text) != null) && (double.tryParse(_priceMinController.text)! < double.tryParse(_priceMaxController.text)!)))/*!= ''*/ && int.tryParse(_durationController.text) != null /*!= ''*/) {
              // upbookingPrestazione();

              setState(() {
                isSaved = true;
              });

              http.StreamedResponse response = await prestazioneProvider.updatePrestazione(
                  prestazioneId: widget.prestazione!.id!,
                  businessId: businessProvider.business!.id!,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text,
                  duration: _durationController.text,
                  price: !isPriceRange ? _priceController.text.replaceAll(',', '.') : null,
                  priceMin: isPriceRange ? _priceMinController.text.replaceAll(',', '.') : null,
                  priceMax: isPriceRange ? _priceMaxController.text.replaceAll(',', '.') : null,
                  isPriceRange: isPriceRange,
                  image: widget.prestazione!.image,
                  uploadImage: _image,
                  /*NumberFormat.currency(
                    // customPattern: '#,##',
                  decimalDigits: 2,
                    locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
                  context: this.context
              );
              // Navigator.pop(context);
              Get.offAll(() => const HomeScreen());
              if(response.statusCode >= 200 && response.statusCode < 400){
                // Navigator.pop(context);
                // await Flushbar(
                //   // title: "Hey",
                //   // titleColor: Colors.white,
                //   // message: "La prestazione è stata creata con successo",
                //
                //   flushbarPosition: FlushbarPosition.BOTTOM,
                //   flushbarStyle: FlushbarStyle.GROUNDED,
                //   reverseAnimationCurve: Curves.decelerate,
                //   forwardAnimationCurve: Curves.easeIn,
                //   backgroundColor: Colors.black,
                //   // boxShadows: [
                //   //   BoxShadow(
                //   //       color: Colors.blue[800],
                //   //       offset: Offset(0.0, 2.0),
                //   //       blurRadius: 3.0
                //   //   )
                //   // ],
                //   // backgroundGradient: LinearGradient(
                //   //     colors: [
                //   //       Colors.blueGrey,
                //   //       Colors.black
                //   //     ]
                //   // ),
                //   isDismissible: false,
                //   duration: Duration(seconds: 4),
                //   icon: Icon(
                //     Icons.check,
                //     color: Colors.blue[500],
                //     size: 25,
                //
                //   ),
                //   // mainButton: FlatButton(
                //   //   onPressed: () {},
                //   //   child: Text(
                //   //     "CLAP",
                //   //     style: TextStyle(color: Colors.amber),
                //   //   ),
                //   // ),
                //   // showProgressIndicator: true,
                //   // progressIndicatorBackgroundColor: Colors.blueGrey,
                //   // titleText: Text(
                //   //   "Hello Hero",
                //   //   style: TextStyle(
                //   //       fontWeight: FontWeight.bold,
                //   //       fontSize: 20.0,
                //   //       color: Colors.yellow[600],
                //   //       fontFamily: "ShadowsIntoLightTwo"
                //   //   ),
                //   // ),
                //
                //   messageText: Text(
                //     "La prestazione è stata aggiornata con successo",
                //     style: TextStyle(
                //       fontSize: 15.0,
                //       color: Colors.white,
                //       fontWeight: FontWeight.w600,
                //       // fontFamily: "ShadowsIntoLightTwo"
                //     ),
                //   ),
                // ).show(context)/*.then((value) => Navigator.pop(context))*/;
                // Fluttertoast.showToast(
                //   msg: 'Prestazione aggiornata',
                //   backgroundColor: Colors.grey[700],
                // );
                // InAppNotification.show(
                //   child: ConstrainedBox(
                //     constraints: BoxConstraints(minHeight: 100),
                //     child: Padding(
                //       padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                //       child: DecoratedBox(
                //         decoration: BoxDecoration(
                //           boxShadow: [
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.1),
                //               spreadRadius: 12,
                //               blurRadius: 16,
                //             ),
                //           ],
                //         ),
                //         child: ClipRRect(
                //           borderRadius: BorderRadius.circular(16),
                //           child: BackdropFilter(
                //             filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                //             child: DecoratedBox(
                //               decoration: BoxDecoration(
                //                 color: Colors.lightGreen.withOpacity(0.4),
                //                 borderRadius: BorderRadius.circular(16.0),
                //                 border: Border.all(
                //                   width: 1.4,
                //                   color: Colors.lightGreen.withOpacity(0.2),
                //                 ),
                //               ),
                //               child: Padding(
                //                 padding: const EdgeInsets.all(16.0),
                //                 child: Center(
                //                   child: Text(
                //                     'Count: ',
                //                     style: Theme.of(context)
                //                         .textTheme
                //                         .headline4!
                //                         .copyWith(color: Colors.white),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                //   context: context,
                //   onTap: () => print('Notification tapped!'),
                //   duration: Duration(milliseconds: 2500),
                // );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Prestazione aggiornata',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.green,
                ));
              }
            }
            else if(widget.isNewPrestazione! && ((!isPriceRange && double.tryParse(_priceController.text) != null) || (isPriceRange && (double.tryParse(_priceMinController.text) != null && double.tryParse(_priceMaxController.text) != null) && (double.tryParse(_priceMinController.text)! < double.tryParse(_priceMaxController.text)!))) /*!= ''*/ && int.tryParse(_durationController.text) != null /*!= ''*/) {
              // createPrestazione();

              setState(() {
                isSaved = true;
              });

              int statusCode = await prestazioneProvider.createPrestazione(
                  title: _titleController.text,
                  // businessId: widget.eventBusiness.id,
                  businessId: businessProvider.business!.id!,
                  description: _descriptionController.text,
                  duration: _durationController.text,
                  isPriceRange: isPriceRange,
                  price: !isPriceRange ? _priceController.text : null,
                  priceMin: isPriceRange ? _priceMinController.text : null,
                  priceMax: isPriceRange ? _priceMaxController.text : null,
                  uploadImage: _image,
                  /*NumberFormat.currency(
                        // customPattern: '#,##',
                      decimalDigits: 2,
                        locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
                  context: this.context
              );

              // print(statusCode);

              Navigator.pop(context);
              if(statusCode == 200){
                // Navigator.pop(context);
                // await Flushbar(
                //   // title: "Hey",
                //   // titleColor: Colors.white,
                //   // message: "La prestazione è stata creata con successo",
                //
                //   flushbarPosition: FlushbarPosition.BOTTOM,
                //   flushbarStyle: FlushbarStyle.GROUNDED,
                //   reverseAnimationCurve: Curves.decelerate,
                //   forwardAnimationCurve: Curves.easeIn,
                //   backgroundColor: Colors.black,
                //   // boxShadows: [
                //   //   BoxShadow(
                //   //       color: Colors.blue[800],
                //   //       offset: Offset(0.0, 2.0),
                //   //       blurRadius: 3.0
                //   //   )
                //   // ],
                //   // backgroundGradient: LinearGradient(
                //   //     colors: [
                //   //       Colors.blueGrey,
                //   //       Colors.black
                //   //     ]
                //   // ),
                //   isDismissible: false,
                //   duration: Duration(seconds: 4),
                //   icon: Icon(
                //     Icons.check,
                //     color: Colors.blue[500],
                //     size: 25,
                //
                //   ),
                //   // mainButton: FlatButton(
                //   //   onPressed: () {},
                //   //   child: Text(
                //   //     "CLAP",
                //   //     style: TextStyle(color: Colors.amber),
                //   //   ),
                //   // ),
                //   // showProgressIndicator: true,
                //   // progressIndicatorBackgroundColor: Colors.blueGrey,
                //   // titleText: Text(
                //   //   "Hello Hero",
                //   //   style: TextStyle(
                //   //       fontWeight: FontWeight.bold,
                //   //       fontSize: 20.0,
                //   //       color: Colors.yellow[600],
                //   //       fontFamily: "ShadowsIntoLightTwo"
                //   //   ),
                //   // ),
                //   messageText: Text(
                //     "La prestazione è stata creata con successo",
                //     style: TextStyle(
                //       fontSize: 15.0,
                //       color: Colors.white,
                //       fontWeight: FontWeight.w600,
                //       // fontFamily: "ShadowsIntoLightTwo"
                //     ),
                //   ),
                // ).show(context);
                // Fluttertoast.showToast(
                //   msg: 'Prestazione inserita',
                //   backgroundColor: Colors.grey[700],
                // );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Prestazione inserita',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.green,
                ));
                // print('prestazioneProvider.prestazioneList');
                for(var e in prestazioneProvider.prestazioneList){
                  // print(e);
                }
              }
            }
            else if(double.tryParse(_priceController.text) != null && int.tryParse(_durationController.text) == null){
              Fluttertoast.showToast(
                msg: 'Inserire Durata',
                backgroundColor: Colors.grey[700],
              );
            }
            else if(!isPriceRange && double.tryParse(_priceController.text) == null && int.tryParse(_durationController.text) != null){
              Fluttertoast.showToast(
                msg: 'Inserire Prezzo',
                backgroundColor: Colors.grey[700],
              );
            }
            else if((double.tryParse(_priceController.text) != null || (double.tryParse(_priceMinController.text)! < double.tryParse(_priceMaxController.text)!)) && int.tryParse(_durationController.text) == null){
              Fluttertoast.showToast(
                msg: 'Inserire Prezzo e Durata',
                backgroundColor: Colors.grey[700],
              );
            }
            else if((isPriceRange && double.tryParse(_priceMinController.text)! >= double.tryParse(_priceMaxController.text)!) && int.tryParse(_durationController.text) != null){
              Fluttertoast.showToast(
                msg: 'Il prezzo minimo deve essere inferiore al prezzo massimo',
                backgroundColor: Colors.grey[700],
              );
            }
            else if((double.tryParse(_priceMinController.text)! >= double.tryParse(_priceMaxController.text)!) && int.tryParse(_durationController.text) == null){
              Fluttertoast.showToast(
                msg: 'Il prezzo minimo deve essere inferiore al prezzo massimo e la durata',
                backgroundColor: Colors.grey[700],
              );
            }
            else {
              Fluttertoast.showToast(
                msg: 'errore',
                backgroundColor: Colors.grey[700],
              );
            }
          },
        ),
      ),
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
          widget.isNewPrestazione! ? 'Inserisci Prestazione' : 'Modifica Prestazione',
          style: TextStyle(
              color: Colors.blue,
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: isSaved ? Transform.scale(scale: 0.8, child: const CircularProgressIndicator(),) : OutlinedButton(
          //       style: ButtonStyle(
          //         backgroundColor: MaterialStateProperty.all(Colors.white),
          //       ),
          //       onPressed: () async {
          //         if(!widget.isNewPrestazione! && _priceController.text != '' && _durationController.text != '') {
          //           // upbookingPrestazione();
          //           setState(() {
          //             isSaved = true;
          //           });
          //
          //           http.StreamedResponse response = await prestazioneProvider.updatePrestazione(
          //               prestazioneId: widget.prestazione!.id!,
          //               businessId: businessProvider.business!.id!,
          //               title: _titleController.text,
          //               description: _descriptionController.text,
          //               duration: _durationController.text,
          //               price: _priceController.text.replaceAll(',', '.'),
          //               image: widget.prestazione!.image,
          //               uploadImage: _image,
          //               /*NumberFormat.currency(
          //                 // customPattern: '#,##',
          //               decimalDigits: 2,
          //                 locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
          //               context: this.context
          //           );
          //           Navigator.pop(context);
          //           if(response.statusCode >= 200 && response.statusCode < 400){
          //             // Navigator.pop(context);
          //             // await Flushbar(
          //             //   // title: "Hey",
          //             //   // titleColor: Colors.white,
          //             //   // message: "La prestazione è stata creata con successo",
          //             //
          //             //   flushbarPosition: FlushbarPosition.BOTTOM,
          //             //   flushbarStyle: FlushbarStyle.GROUNDED,
          //             //   reverseAnimationCurve: Curves.decelerate,
          //             //   forwardAnimationCurve: Curves.easeIn,
          //             //   backgroundColor: Colors.black,
          //             //   // boxShadows: [
          //             //   //   BoxShadow(
          //             //   //       color: Colors.blue[800],
          //             //   //       offset: Offset(0.0, 2.0),
          //             //   //       blurRadius: 3.0
          //             //   //   )
          //             //   // ],
          //             //   // backgroundGradient: LinearGradient(
          //             //   //     colors: [
          //             //   //       Colors.blueGrey,
          //             //   //       Colors.black
          //             //   //     ]
          //             //   // ),
          //             //   isDismissible: false,
          //             //   duration: Duration(seconds: 4),
          //             //   icon: Icon(
          //             //     Icons.check,
          //             //     color: Colors.blue[500],
          //             //     size: 25,
          //             //
          //             //   ),
          //             //   // mainButton: FlatButton(
          //             //   //   onPressed: () {},
          //             //   //   child: Text(
          //             //   //     "CLAP",
          //             //   //     style: TextStyle(color: Colors.amber),
          //             //   //   ),
          //             //   // ),
          //             //   // showProgressIndicator: true,
          //             //   // progressIndicatorBackgroundColor: Colors.blueGrey,
          //             //   // titleText: Text(
          //             //   //   "Hello Hero",
          //             //   //   style: TextStyle(
          //             //   //       fontWeight: FontWeight.bold,
          //             //   //       fontSize: 20.0,
          //             //   //       color: Colors.yellow[600],
          //             //   //       fontFamily: "ShadowsIntoLightTwo"
          //             //   //   ),
          //             //   // ),
          //             //
          //             //   messageText: Text(
          //             //     "La prestazione è stata aggiornata con successo",
          //             //     style: TextStyle(
          //             //       fontSize: 15.0,
          //             //       color: Colors.white,
          //             //       fontWeight: FontWeight.w600,
          //             //       // fontFamily: "ShadowsIntoLightTwo"
          //             //     ),
          //             //   ),
          //             // ).show(context)/*.then((value) => Navigator.pop(context))*/;
          //             // Fluttertoast.showToast(
          //             //   msg: 'Prestazione aggiornata',
          //             //   backgroundColor: Colors.grey[700],
          //             // );
          //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //               content: Text(
          //                 'Prestazione aggiornata',
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.w600,
          //                   color: Colors.white,
          //                 ),
          //               ),
          //               backgroundColor: Colors.green,
          //             ));
          //           }
          //         }
          //         else if(widget.isNewPrestazione! && _priceController.text != '' && _durationController.text != '') {
          //           // createPrestazione();
          //
          //           setState(() {
          //             isSaved = true;
          //           });
          //
          //           int statusCode = await prestazioneProvider.createPrestazione(
          //               title: _titleController.text,
          //               // businessId: widget.eventBusiness.id,
          //               businessId: businessProvider.business!.id!,
          //               description: _descriptionController.text,
          //               duration: _durationController.text,
          //               price: _priceController.text,
          //               uploadImage: _image,
          //               /*NumberFormat.currency(
          //               // customPattern: '#,##',
          //             decimalDigits: 2,
          //               locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
          //               context: this.context
          //           );
          //
          //           // print(statusCode);
          //
          //           Navigator.pop(context);
          //           if(statusCode == 200){
          //             // Navigator.pop(context);
          //             // await Flushbar(
          //             //   // title: "Hey",
          //             //   // titleColor: Colors.white,
          //             //   // message: "La prestazione è stata creata con successo",
          //             //
          //             //   flushbarPosition: FlushbarPosition.BOTTOM,
          //             //   flushbarStyle: FlushbarStyle.GROUNDED,
          //             //   reverseAnimationCurve: Curves.decelerate,
          //             //   forwardAnimationCurve: Curves.easeIn,
          //             //   backgroundColor: Colors.black,
          //             //   // boxShadows: [
          //             //   //   BoxShadow(
          //             //   //       color: Colors.blue[800],
          //             //   //       offset: Offset(0.0, 2.0),
          //             //   //       blurRadius: 3.0
          //             //   //   )
          //             //   // ],
          //             //   // backgroundGradient: LinearGradient(
          //             //   //     colors: [
          //             //   //       Colors.blueGrey,
          //             //   //       Colors.black
          //             //   //     ]
          //             //   // ),
          //             //   isDismissible: false,
          //             //   duration: Duration(seconds: 4),
          //             //   icon: Icon(
          //             //     Icons.check,
          //             //     color: Colors.blue[500],
          //             //     size: 25,
          //             //
          //             //   ),
          //             //   // mainButton: FlatButton(
          //             //   //   onPressed: () {},
          //             //   //   child: Text(
          //             //   //     "CLAP",
          //             //   //     style: TextStyle(color: Colors.amber),
          //             //   //   ),
          //             //   // ),
          //             //   // showProgressIndicator: true,
          //             //   // progressIndicatorBackgroundColor: Colors.blueGrey,
          //             //   // titleText: Text(
          //             //   //   "Hello Hero",
          //             //   //   style: TextStyle(
          //             //   //       fontWeight: FontWeight.bold,
          //             //   //       fontSize: 20.0,
          //             //   //       color: Colors.yellow[600],
          //             //   //       fontFamily: "ShadowsIntoLightTwo"
          //             //   //   ),
          //             //   // ),
          //             //   messageText: Text(
          //             //     "La prestazione è stata creata con successo",
          //             //     style: TextStyle(
          //             //       fontSize: 15.0,
          //             //       color: Colors.white,
          //             //       fontWeight: FontWeight.w600,
          //             //       // fontFamily: "ShadowsIntoLightTwo"
          //             //     ),
          //             //   ),
          //             // ).show(context);
          //             // Fluttertoast.showToast(
          //             //   msg: 'Prestazione inserita',
          //             //   backgroundColor: Colors.grey[700],
          //             // );
          //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //               content: Text(
          //                 'Prestazione inserita',
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.w600,
          //                   color: Colors.white,
          //                 ),
          //               ),
          //               backgroundColor: Colors.green,
          //             ));
          //             // print('prestazioneProvider.prestazioneList');
          //             for(var e in prestazioneProvider.prestazioneList){
          //               // print(e);
          //             }
          //           }
          //         }
          //         else if(_durationController.text == '' && _priceController.text != ''){
          //           Fluttertoast.showToast(
          //             msg: 'Inserire Durata',
          //             backgroundColor: Colors.grey[700],
          //           );
          //         }
          //         else if(_priceController.text == '' && _durationController.text != ''){
          //           Fluttertoast.showToast(
          //             msg: 'Inserire Prezzo',
          //             backgroundColor: Colors.grey[700],
          //           );
          //         }
          //         else if(_priceController.text == '' && _priceController.text == ''){
          //           Fluttertoast.showToast(
          //             msg: 'Inserire Prezzo e Durata',
          //             backgroundColor: Colors.grey[700],
          //           );
          //         }
          //         // uploadCoverEventImage();
          //       },
          //       child: Text(
          //         'Salva',
          //         style: TextStyle(
          //             color: Colors.blue
          //         ),
          //       )
          //     // child: Icon(
          //     //   Icons.add,
          //     //   color: Colors.blue,
          //     // ),
          //   ),
          // )
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          physics: ClampingScrollPhysics(),
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
                          placeholder: /*row.placeholder ??*/ "Inserire il titolo della prestazione",
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
                        "Immagine della prestazione",
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
                      height: MediaQuery.of(context).size.width/2,
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
                              // print(_image!.path);
                              // return SelectImageView(
                              //   selected: (image /*= FileImage().images[index]*/) async {
                              //     // images[index];
                              //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                              //     // row.state[index]["picurl"] = image.path;
                              //   },
                              // );
                            },
                            child: isSelectedImage == false && widget.prestazione!.image != null && widget.prestazione!.image != '' ? FutureImage(
                              widget.prestazione!.image!,
                              // colorBlendMode: BlendMode.darken,
                              // colorBlendMode: BlendMode.hardLight,
                              // width: 45,
                              // height: 45,
                              // filterQuality: FilterQuality.high,
                              // placeholder: (context, url) => Center(
                              //     child: CircularProgressIndicator()
                              // ),

                              // width: 110,
                              // height: 100,
                              width: MediaQuery.of(context).size.width,
                                // margin: EdgeInsets.all(5),
                            ) : isSelectedImage == true ? Image.file(_image!) : Container(
                                  // width: 110,
                                  // height: 100,
                              width: MediaQuery.of(context).size.width,
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
            Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              margin: EdgeInsets.all(0),
              height: 58.0,
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    'Tipo Prezzo',
                    style: TextStyle(
                        color: Colors.blue[500],
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              isPriceRange = false;
                            });
                            print(isPriceRange);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Radio<bool>(
                                value: false,
                                groupValue: isPriceRange,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isPriceRange = value!;
                                  });
                                  print(isPriceRange);
                                },
                              ),
                              Text(
                                'Fisso',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 30,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isPriceRange = true;
                            });
                            print(isPriceRange);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Radio<bool>(
                                value: true,
                                groupValue: isPriceRange,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isPriceRange = value!;
                                  });
                                  print(isPriceRange);
                                },
                              ),
                              Text(
                                'Variabile',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !isPriceRange,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    margin: EdgeInsets.all(0),
                    height: 58.0,
                    color: Colors.white,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
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
                          // width: 50,
                        ),
                        Expanded(
                          child: CupertinoTextField(
                            // suffix: Icon(
                            //     Icons.keyboard_arrow_right
                            // ),
                            obscureText: false,
                            controller: _priceController,
                            clearButtonMode: _priceController.text != ''
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
                              if(_priceController.text == ''){
                                setState(() {
                                  editablePrice = false;
                                });
                              }
                              else{
                                setState(() {
                                  editablePrice = true;
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
            ),
            Visibility(
              visible: isPriceRange,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    margin: EdgeInsets.all(0),
                    height: 58.0,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text(
                          'Prezzo Minimo',
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
                            controller: _priceMinController,
                            clearButtonMode: _priceMinController.text != ''
                                ? OverlayVisibilityMode.always
                                : OverlayVisibilityMode.never,
                            enabled: true,
                            decoration: BoxDecoration(color: Colors.white),
                            textAlign: /*row.textAlign ??*/ TextAlign.left,
                            placeholder: /*row.placeholder ??*/ "Inserire il prezzo minimo",
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
                              if(_priceMinController.text == ''){
                                setState(() {
                                  editablePriceMin = false;
                                });
                              }
                              else{
                                setState(() {
                                  editablePriceMin = true;
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
                    endIndent: 10,
                    indent: 10,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isPriceRange,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    margin: EdgeInsets.all(0),
                    height: 58.0,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text(
                          'Prezzo Massimo',
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
                            controller: _priceMaxController,
                            clearButtonMode: _priceMaxController.text != ''
                                ? OverlayVisibilityMode.always
                                : OverlayVisibilityMode.never,
                            enabled: true,
                            decoration: BoxDecoration(color: Colors.white),
                            textAlign: /*row.textAlign ??*/ TextAlign.left,
                            placeholder: /*row.placeholder ??*/ "Inserire il prezzo massimo",
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
                              if(_priceMaxController.text == ''){
                                setState(() {
                                  editablePriceMax = false;
                                });
                              }
                              else{
                                setState(() {
                                  editablePriceMax = true;
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
                        'Durata',
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
                          controller: _durationController,
                          clearButtonMode: _durationController.text != ''
                              ? OverlayVisibilityMode.always
                              : OverlayVisibilityMode.never,
                          enabled: true,
                          decoration: BoxDecoration(color: Colors.white),
                          textAlign: /*row.textAlign ??*/ TextAlign.left,
                          placeholder: /*row.placeholder ??*/ "Inserire la durata in minuti della prestazione",
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
                            if(_durationController.text == ''){
                              setState(() {
                                editableDuration = false;
                              });
                            }
                            else{
                              setState(() {
                                editableDuration = true;
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

            Visibility(
              visible: !widget.isNewPrestazione!,
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
            ),
            SizedBox(height: 90,)
          ],
        ),
      ),

    );
  }
}
