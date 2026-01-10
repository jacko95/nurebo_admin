import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/login_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class BookingProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.tryParse(DateTime.now().toString())!;
  List<Booking>? appointments = [];
  DateTime openingDate = DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/;
  DateTime closingDate = DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/;
  List openingDates = [];
  List closingDates = [];
  List? timetableDay = [];
  DateTime? timeOfTheDate;
  int contaIntervalliDaMezzora = 0;
  List<int> intervalliDaMezzoraPerApertura = [];
  List<String> intervalliDaMezzoraPerApertura1 = [];
  List occupiedDates = [];
  int isOccupied = 0;
  bool isUserAppointment = false;
  List<DateTime> intervalliDaMezzoraPerAperturaBegin = [];
  List<DateTime> intervalliDaMezzoraPerAperturaEnd = [];
  List<Booking> appointmentsDefinitive = [];
  // DatePickerController bookingPickerController = new DatePickerController();

  Future tasks1 = Future(() {});
  Future tasks0 = Future(() {});
  Future slots = Future(() {});


  // String businessId;
  //
  // AppointmentProvider(){
  //   getTimetableDay(_selectedDate.weekday);
  //
  //   (_tasks0 = getDateBusinessAppointments()).then((value) =>
  //       (_tasks1 = getOccupiedDates()).then((value) async {
  //         _slots = await createSlots(
  //             occupiedDates,
  //             appointments,
  //             _selectedDate.day,
  //             _selectedDate.month,
  //             _selectedDate.year
  //         );
  //       }));
  //
  //   openingDates.clear();
  //   closingDates.clear();
  // }

  // Future logout(context, {bool? isManual/*, Business business*/}) async {
  //   BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
  //   // print('BusinessPreferences.getUserToken()');
  //   // print(BusinessPreferences.getBusinessToken());
  //
  //   var splitToken = BusinessPreferences.getBusinessToken()!.split('.');
  //   // print(splitToken);
  //   String decodedHeader = utf8.fuse(base64).decode(base64.normalize(splitToken[0]));
  //   String decodedPayload = utf8.fuse(base64).decode(base64.normalize(splitToken[1]));
  //   // String decodedSignature = utf8.fuse(base64).decode(splitToken[2]);
  //   // print(decodedHeader);
  //   // print(decodedPayload);
  //   // print(decodedSignature);
  //   Map authId = jsonDecode(utf8.fuse(base64).decode(base64.normalize(splitToken[1])));
  //   // print(authId['id']);
  //
  //   // var url = Uri.parse(Utils.httpServerUrl + "business_authentication/logout");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/authentication/${authId['id']}/logout");
  //
  //   Map body = {
  //     "auth_id": authId['id'],
  //     "business_id": businessProvider.business!.id,
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
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!,
  //       }
  //   );
  //
  //   // print("response.statusCode:");
  //   // print(response.statusCode);
  //
  //   // if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
  //   //   // if (!mounted) return;
  //   //   // await businessProvider.logout(context);
  //   //
  //   //   Fluttertoast.showToast(
  //   //     msg: 'Autenticazione scaduta',
  //   //     backgroundColor: Colors.grey[700],
  //   //   );
  //   // }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     // Scaffold.of(context).openEndDrawer();
  //     // if(socketProvider.socket != null){
  //     //   if(socketProvider.socket.connected){
  //     //     // socketProvider.socket.disconnect();
  //     //     // socketProvider.socket.close();
  //     //     socketProvider.socket.destroy();
  //     //   }
  //     // }
  //
  //     // print('socketProvider.socket.id');
  //     // print(socketProvider.socket.id);
  //     // print('businessProvider.business.id');
  //     // print(businessProvider.business!.id);
  //
  //     // socketProvider.removeUserSocket(
  //     //     businessProvider.user.id,
  //     //     socketProvider.socket.id
  //     // );
  //
  //     // await BusinessPreferences.init();
  //     await BusinessPreferences.setIsLogged(false);
  //     await BusinessPreferences.setBusinessId('');
  //     await BusinessPreferences.setBusinessToken('');
  //
  //     // businessProvider.setUser(null);
  //     businessProvider.emptyBusiness();
  //
  //     // FlutterBackgroundService().sendData({"action": "stopService"},);
  //     // if((await FlutterBackgroundService().isServiceRunning()) == true){
  //     // if((await FlutterBackgroundService().isRunning()) == true){
  //     //   // FlutterBackgroundService().sendData({"action": "stopService"},);
  //     //   FlutterBackgroundService().invoke("stopService");
  //     // }
  //
  //     if(isManual == null || isManual == false) {
  //       Fluttertoast.showToast(
  //         msg: 'Autenticazione scaduta',
  //         backgroundColor: Colors.grey[700],
  //       );
  //     }
  //
  //     await Navigator.pushAndRemoveUntil(
  //         context,
  //         PageTransition(
  //           child: LoginScreen(),
  //           type: PageTransitionType.fade,
  //           duration: Duration(milliseconds: 500),
  //         ),
  //             (route) => false
  //       // (route) => true
  //     );
  //     // return exit(0);
  //     // await SystemChannels.platform.invokeMethod('SystemNavigator.pop')/*.then((value) => Phoenix.rebirth(context))*/;
  //     // Phoenix.rebirth(context);
  //   }
  // }

  Future init(String? businessId, List socketAppointments, BuildContext context) async {
    await getTimetableDay(businessId, selectedDate.weekday);

    (tasks0 = getDateBusinessAppointments(businessId, context)).then((value) async {
      (tasks1 = getOccupiedDates(businessId,)).then((value) async {
        slots = /*await*/ createSlots(
          occupiedDates,
          appointments,
          selectedDate.day,
          selectedDate.month,
          selectedDate.year,
          socketAppointments,
          context
        );
      });
    });

    openingDates.clear();
    closingDates.clear();

    notifyListeners();
  }

  cancelSlot(String appointmentId){
    for(var e in appointmentsDefinitive){
      if(appointmentId == e.id){
        appointmentsDefinitive.remove(e);
      }
    }
    notifyListeners();
  }

  Future getUserByID(String userID) async {
    var url = Uri.parse(Utils.httpServerUrl + "user/");

    Map/*<String, String>*/ body = {
      'id': userID,
    };

    var response = await http.post(
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
        }
    );

    // print('getuserid');
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print(jsonData);
      // print(appointments.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getPrestazioneByID(String? prestazioneID) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/id");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/$prestazioneID");

    Map/*<String, String>*/ body = {
      'id': prestazioneID,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
        }
    );

    // print('restazioneid');
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // Prestazione prestazione = new Prestazione(
      //   duration: jsonData['duration'],
      //   price: jsonData['price'],
      //   image: jsonData['image'],
      //   id: jsonData['id'],
      //   title: jsonData['title'],
      //   description: jsonData['description'],
      //   business_id: jsonData['business_id'],
      // );
      //
      // // print(jsonData);
      // print('prestazione.title');
      // print(prestazione.title);
      // print(appointments.toString());
      notifyListeners();
      return jsonData;
      // return prestazione;
    }
    notifyListeners();
  }

  Future getDateBusinessAppointments(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/booking");
    // var ticketCategoryProvider = Provider.of<TicketProvider>(context/*, listen: false*/);

    Map/*<String, String>*/ body = {
      // 'business_id': widget.business.id,
      'business_id': businessId,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // print('getAppointmentsByDate.statusCode');
    // print(response.statusCode);
    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
      // Fluttertoast.showToast(
      //   msg: 'Autenticazione scaduta',
      //   backgroundColor: Colors.grey[700],
      // );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // appointments = jsonData;

      appointments!.clear();

      for (var e in jsonData) {
        // Map<String, dynamic> value = {
        //   'booking_id': e['booking_id'],
        //   'guest_name': e['guest_name'],
        //   'guest_contact': e['guest_contact'],
        //   'is_canceled': e['is_canceled'],
        //   // note: myAppointments[index]['note'],
        //   // user_id: myAppointments[index]['user_id'].toString(),
        //   'prestazione_duration': e['prestazione_duration'],
        //   'prestazione_id': e['prestazione_id'],
        //   'prestazione_image': e['prestazione_image'],
        //   'prestazione_price': e['prestazione_price']/*.toDouble()*/,
        //   'prestazione_title': e['prestazione_title'],
        //   'prestazione_description': e['prestazione_description'],
        //   'prestazione_business_id': e['prestazione_business_id'],
        //   'user_id': e['user_id'],
        //   'user_email': e['user_email'],
        //   'user_username': e['user_username'],
        //   'user_name': e['user_name'],
        //   'user_phone_number': e['user_phone_number'],
        //   'user_profile_image': e['user_profile_image'],
        //   // description: appointments[i]['user_description'],
        //   'begin_at': DateTime.tryParse(e['begin_at'])!.toLocal().toString(),
        //   'end_at': DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration'].toInt())).toLocal().toString(),
        //   'created_at': DateTime.tryParse(e['created_at'])!.toLocal() /*.add(Duration(hours: 2))*/.toString(),
        // };
        Booking booking = Booking(
            id: e['booking_id'],
            isCanceled: e['is_canceled'],
            // guestName: e['guest_name'],
            // guestEmail: e['guest_contact'],
            is_guest: 0,
            type: 2,
            // note: myAppointments[index]['note'],
            // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              duration: e['prestazione_duration'],
              id: e['prestazione_id'],
              image: e['prestazione_image'],
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
              price: e['prestazione_price']?.toDouble(),
              price_min: e['prestazione_price_min']?.toDouble(),
              price_max: e['prestazione_price_max']?.toDouble(),
              title: e['prestazione_title'],
              description: e['prestazione_description'],
              business_id: e['prestazione_business_id'],
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              phone: e['user_phone'],
              profile_image: e['user_profile_image'] ?? '',
              // description: appointments[i]['user_description'],
            ),
            begin_at: DateTime.tryParse(e['begin_at'])/*.toLocal()*/,
            end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration']?.toInt()))/*.toLocal()*/,
            created_at: DateTime.tryParse(e['created_at'])/*.toLocal()*//*.add(Duration(hours: 2))*/,
            note: e['note']
        );
        // appointments!.add(value);
        appointments!.add(booking);
      }

      // print(jsonData);
      // print('appointments.length');
      // print(appointments!.length.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future createDate(Booking e, BuildContext context) async {
    SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    var url = Uri.parse(Utils.httpServerUrl + "business/booking");
    // final socketProvider = Provider.of<SocketProvider>(context, listen: true);
    // final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    // Map<String, dynamic> body = {
    //   // 'user_id': widget.user.id,
    //   'user_id': userProvider.user.id,
    //   'business_id': e.prestazione.business.id,
    //   'prestazione_id': e.prestazione_id,
    //   'begin_at': e.begin_at./*toUtc().*/toString(),
    //   'note': e.note,
    //   //bookingtime.now()
    // };

    // print('e.begin_at.toIso8601String() hhhh');
    // print(e.begin_at.toIso8601String());
    // print('e.begin_at.toUtc().toString() uuuuu');
    // print(e.begin_at.toUtc().toString());

    Map<String, dynamic> body = {
      "prestazione_id": e.prestazione!.id,
      "note": e.note,
      "guest_contact": e.guestEmail,
      "guest_name": e.guestName,
      "begin_at": e.begin_at!/*.toUtc()*/.toString(),
      // "begin_at": e.begin_at.toIso8601String(),
      'business_id': e.business!.id,
      // 'is_booking_business': e.business.business_type_id,
      // 'max_contemporary_appointments': e.business.max_contemporary_appointments,
      'created_at': DateTime.now()/*.toIso8601String()*/.toString(),
      // 'is_canceled': 0,
    };

    // print('body56565665');
    // print(body);

    // notificationProvider.showFlushbar(context);

    // Fluttertoast.showToast(
    //   msg: "Appuntamento prenotato correttamente",
    //   backgroundColor: Colors.grey[700],
    // );

    var response = await http.post(
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

    // print("jjjj l response.statusCode:");
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      // await logout(context);
      await businessProvider.logout(context);
    }
    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('dghhf jsonData');
      // print(jsonData);

      // Map<String, dynamic> value = {
      //   'booking_id': jsonData,
      //   'is_canceled': 0,
      //   'note': e.note,
      //   "guest_contact": e.guestEmail,
      //   "guest_name": e.guestName,
      //   // user_id: myAppointments[index]['user_id'].toString(),
      //   'prestazione_duration': e.prestazione!.duration,
      //   'prestazione_id': e.prestazione!.id,
      //   'prestazione_image': e.prestazione!.image,
      //   'prestazione_price': e.prestazione!.price,
      //   'prestazione_title': e.prestazione!.title,
      //   'prestazione_description': e.prestazione!.description,
      //   'prestazione_business_id': e.prestazione!.business!.id,
      //   'begin_at': e.begin_at!.toLocal().toString(),
      //   'end_at': e.begin_at!.add(Duration(minutes: e.prestazione!.duration!.toInt())).toLocal().toString(),
      //   'created_at': e.created_at!.toLocal() /*.add(Duration(hours: 2))*/.toString(),
      // };
      Booking booking = Booking(
          id: jsonData,
          isCanceled: 0,
          // guestName: e['guest_name'],
          // guestEmail: e['guest_contact'],
          is_guest: 0,
          type: 2,
          // note: myAppointments[index]['note'],
          // user_id: myAppointments[index]['user_id'].toString(),
          prestazione: Prestazione(
            duration: e.prestazione!.duration,
            id: e.prestazione!.id,
            image: e.prestazione!.image,
            is_price_range: e.prestazione!.is_price_range,
            price: e.prestazione!.price,
            price_min: e.prestazione!.price_min,
            price_max: e.prestazione!.price_max,
            title: e.prestazione!.title,
            description: e.prestazione!.description,
            business_id: e.prestazione!.business_id,
          ),
          user: User(
            // id: e['user_id'],
            // email: e['user_email'],
            // username: e['user_username'],
            // name: e['user_name'],
            // phone_number: e['user_phone_number'],
            profile_image: e.user.profile_image,
            // description: appointments[i]['user_description'],
          ),
          begin_at: e.begin_at!/*.toLocal()*/,
          end_at: e.begin_at!.add(Duration(minutes: e.prestazione!.duration!.toInt()))/*.toLocal()*/,
          created_at: e.created_at!/*.toLocal()*/,
          note: e.note
      );

      // print('appointments.length.toString()0');
      // print(appointments!.length.toString());
      // print('socketProvider.myAppointments.toString()0');
      // print(socketProvider.myAppointments.length.toString());
      // appointments!.add(value);
      appointments!.add(booking);
      socketProvider.myAppointments.add(
          Booking(
            user: User(profile_image: ''),
            id: jsonData,
            isCanceled: e.isCanceled,
            type: 2,
            // note: myAppointments[index]['note'],
            // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              duration: e.prestazione!.duration,
              id: e.prestazione!.id,
              image: e.prestazione!.image,
              is_price_range: e.prestazione!.is_price_range,
              price: e.prestazione!.price!.toDouble(),
              price_max: e.prestazione!.price_max!.toDouble(),
              price_min: e.prestazione!.price_min!.toDouble(),
              title: e.prestazione!.title,
              description: e.prestazione!.description,
              business: e.prestazione!.business,
            ),
            begin_at: e.begin_at!/*.toLocal()*/,
            end_at: e.end_at!/*.toLocal()*/,
            created_at: e.created_at!/*.toLocal()*/,
          )
      );
      // print('appointments.length.toString()1');
      // print(appointments!.length.toString());
      // print('socketProvider.myAppointments.toString()1');
      // print(socketProvider.myAppointments.length.toString());

      // Map<String, dynamic> values = {
      //   "booking_id": jsonData,
      //   'booking_price': e.prestazione.price,
      //   "booking_begin_at": e.begin_at.toString()/*.toIso8601String()*/,
      //   "prestazione_id": e.prestazione.id,
      //   'prestazione_image': e.prestazione.image != null && e.prestazione.image != '' ?  e.prestazione.image : e.business.profile_image,
      //   'prestazione_title': e.prestazione.title,
      //   'is_canceled': 0,
      //   'user_id': '',
      //   'business_id': e.business.id,
      //   'business_name': e.business.name,
      //   'sent_at': DateTime.now().toIso8601String(),
      // };
      //
      // await socketProvider.insertLocalNotification(
      //   'appointment_notification',
      //   values
      // );
      // return response.statusCode;
      notifyListeners();
    }

    notifyListeners();
    return response;
  }

  Future createGuestBooking(Booking e, BuildContext context) async {
    SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "business/booking/guest");
    var url = Uri.parse("${Utils.httpServerUrl}business/${e.business!.id}/booking/guest");

    Map<String, dynamic> body = {
      "prestazione_id": e.prestazione!.id,
      "note": e.note,
      "guest_email": e.guestEmail,
      "guest_phone": e.guestPhone,
      "guest_name": e.guestName,
      "begin_at": e.begin_at!/*.toUtc()*/.toString(),
      // "begin_at": e.begin_at!.toIso8601String(),
      // 'business_id': e.business!.id,
      // 'is_booking_business': e.business.business_type_id,
      // 'max_contemporary_appointments': e.business.max_contemporary_appointments,
      'created_at': DateTime.now()/*.toIso8601String()*/.toString(),
      // 'is_canceled': 0,
    };

    var response = await http.post(
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
      // await logout(context);
      await businessProvider.logout(context);
      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDatafdgg5g5g5g');
      // print(jsonData);

      Booking booking = Booking(
          id: jsonData,
          isCanceled: 0,
          guestName: e.guestName,
          guestPhone: e.guestPhone,
          guestEmail: e.guestEmail,
          is_guest: 1,
          type: 2,
          // note: myAppointments[index]['note'],
          // user_id: myAppointments[index]['user_id'].toString(),
          prestazione: Prestazione(
            duration: e.prestazione!.duration,
            id: e.prestazione!.id,
            image: e.prestazione!.image,
            is_price_range: e.prestazione!.is_price_range,
            price: e.prestazione!.price,
            price_min: e.prestazione!.price_min,
            price_max: e.prestazione!.price_max,
            title: e.prestazione!.title,
            description: e.prestazione!.description,
            business_id: e.prestazione!.business_id,
          ),
          user: User(
            // id: e['user_id'],
            // email: e['user_email'],
            // username: e['user_username'],
            // name: e['user_name'],
            // phone_number: e['user_phone_number'],
            profile_image: e.user.profile_image,
            // description: appointments[i]['user_description'],
          ),
          begin_at: e.begin_at!/*.toLocal()*/,
          end_at: e.begin_at!.add(Duration(minutes: e.prestazione!.duration!.toInt()))/*.toLocal()*/,
          created_at: e.created_at!/*.toLocal()*/,
          note: e.note
      );

      if(booking.begin_at!.day == DateTime.now().day && booking.begin_at!.month == DateTime.now().month
          && booking.begin_at!.year == DateTime.now().year){
        appointments!.add(booking);
      }
      socketProvider.myAppointments.add(
          Booking(
            user: User(profile_image: ''),
            id: jsonData,
            isCanceled: e.isCanceled,
            // note: myAppointments[index]['note'],
            // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              duration: e.prestazione!.duration,
              id: e.prestazione!.id,
              image: e.prestazione!.image,
              is_price_range: e.prestazione!.is_price_range,
              price: e.prestazione!.price!.toDouble(),
              price_max: e.prestazione!.price_max!.toDouble(),
              price_min: e.prestazione!.price_min!.toDouble(),
              title: e.prestazione!.title,
              description: e.prestazione!.description,
              business: e.prestazione!.business,
            ),
            begin_at: e.begin_at!/*.toLocal()*/,
            end_at: e.end_at!/*.toLocal()*/,
            created_at: e.created_at!/*.toLocal()*/,
          )
      );
      // print('appointments.length.toString()1');
      // print(appointments!.length.toString());
      // print('socketProvider.myAppointments.toString()1');
      // print(socketProvider.myAppointments.length.toString());

      notifyListeners();
    }

    notifyListeners();
    return response;
  }

  Future editGuestBooking(Booking e, BuildContext context) async {
    SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "booking/guest_booking");
    var url = Uri.parse("${Utils.httpServerUrl}business/${e.prestazione!.business!.id}/booking/guest/${e.id}");

    Map<String, dynamic> body = {
      'id': e.id,
      "prestazione_id": e.prestazione!.id,
      "note": e.note,
      "email": e.guestEmail,
      "phone": e.guestPhone,
      "name": e.guestName,
      "begin_at": e.begin_at!/*.toUtc()*/.toString(),
      // "begin_at": e.begin_at!.toIso8601String(),
      'business_id': e.prestazione!.business!.id,
    };

    var response = await http.put(
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
      // await logout(context);
      await businessProvider.logout(context);

      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.grey[700],
      );
    }
    else if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDatafdgg5g5g5g');
      // print(jsonData);

      // Booking booking = Booking(
      //     id: jsonData,
      //     isCanceled: 0,
      //     guestName: e.guestName,
      //     guestPhone: e.guestPhone,
      //     guestEmail: e.guestEmail,
      //     bookingType: 1,
      //     // note: myAppointments[index]['note'],
      //     // user_id: myAppointments[index]['user_id'].toString(),
      //     prestazione: Prestazione(
      //       duration: e.prestazione!.duration,
      //       id: e.prestazione!.id,
      //       image: e.prestazione!.image,
      //       price: e.prestazione!.price,
      //       title: e.prestazione!.title,
      //       description: e.prestazione!.description,
      //       business_id: e.prestazione!.business_id,
      //     ),
      //     user: User(
      //       // id: e['user_id'],
      //       // email: e['user_email'],
      //       // username: e['user_username'],
      //       // name: e['user_name'],
      //       // phone_number: e['user_phone_number'],
      //       profile_image: e.user.profile_image,
      //       // description: appointments[i]['user_description'],
      //     ),
      //     begin_at: e.begin_at!.toLocal(),
      //     end_at: e.begin_at!.add(Duration(minutes: e.prestazione!.duration!.toInt())).toLocal(),
      //     created_at: e.created_at!.toLocal(),
      //     note: e.note
      // );
      //
      // if(booking.begin_at!.day == DateTime.now().day && booking.begin_at!.month == DateTime.now().month
      //     && booking.begin_at!.year == DateTime.now().year){
      //   appointments!.add(booking);
      // }
      // socketProvider.myAppointments.add(
      //   Booking(
      //     user: User(profile_image: ''),
      //     id: jsonData,
      //     isCanceled: e.isCanceled,
      //     // note: myAppointments[index]['note'],
      //     // user_id: myAppointments[index]['user_id'].toString(),
      //     prestazione: Prestazione(
      //       duration: e.prestazione!.duration,
      //       id: e.prestazione!.id,
      //       image: e.prestazione!.image,
      //       price: e.prestazione!.price!.toDouble(),
      //       title: e.prestazione!.title,
      //       description: e.prestazione!.description,
      //       business: e.prestazione!.business,
      //     ),
      //     begin_at: e.begin_at!.toLocal(),
      //     end_at: e.end_at!.toLocal(),
      //     created_at: e.created_at!.toLocal(),
      //   )
      // );
      // print('appointments.length.toString()1');
      // print(appointments!.length.toString());
      // print('socketProvider.myAppointments.toString()1');
      // print(socketProvider.myAppointments.length.toString());

      notifyListeners();
    }

    notifyListeners();
    return response;
  }

  Future cancelGuestBooking(Booking booking, Business business, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/guest");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/booking/guest/${booking.id}");

    Map/*<String, String>*/ body = {
      'booking_id': booking.id,
      'business_id': business.id,
    };

    var response = await http.delete(
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

    // print('getAppointmentsByDate.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      // await logout(context);
      await businessProvider.logout(context);
      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   appointments = jsonData;
      // });

      for(var e in appointments!){
        if(e.id == booking.id){
          // print('appuntamento da cancellare:::::' + e.id.toString());
          e.isCanceled = 1;
          notifyListeners();
        }
      }

      notifyListeners();
      return 1;
    }
    return 0;
  }

  Future getAppointmentsByDate(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/begin_at");
    var url = Uri.parse(
        "${Utils.httpServerUrl}business/$businessId/booking/begin_at?day=${selectedDate.day}&month=${selectedDate.month}&year=${selectedDate.year}"
    );

    Map/*<String, String>*/ body = {
      // 'business_id': widget.business.id,
      'business_id': businessId,
      'begin_at_day': selectedDate.day,
      'begin_at_month': selectedDate.month,
      'begin_at_year': selectedDate.year,
    };

    // print('bodyfdggfsf');
    // print(body);

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // print('getAppointmentsByDate.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
      // Fluttertoast.showToast(
      //   msg: 'Autenticazione scaduta',
      //   backgroundColor: Colors.grey[700],
      // );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      for(var e in jsonData){
        Booking booking = Booking(
            id: e['booking_id'],
            isCanceled: e['is_canceled'],
            // guestName: e['guest_name'],
            // guestEmail: e['guest_contact'],
            is_guest: 0,
            type: 2,
            // note: myAppointments[index]['note'],
            // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              duration: e['prestazione_duration'],
              id: e['prestazione_id'],
              image: e['prestazione_image'],
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
              price: e['prestazione_price']?.toDouble(),
              price_min: e['prestazione_price_min']?.toDouble(),
              price_max: e['prestazione_price_max']?.toDouble(),
              title: e['prestazione_title'],
              description: e['prestazione_description'],
              business_id: e['prestazione_business_id'],
            ),
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              phone: e['user_phone'],
              profile_image: e['user_profile_image'] ?? '',
              // description: appointments[i]['user_description'],
            ),
            begin_at: DateTime.tryParse(e['begin_at'])/*.tolocal()*/,
            end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration'].toInt()))/*.toLocal()*/,
            created_at: DateTime.tryParse(e['created_at'])/*.tolocal()*//*.add(Duration(hours: 2))*/,
            note: e['note']
        );

        appointments!.add(booking);
      }

      // appointments!.addAll(jsonData);

      // appointments!.sort((a, b) {
      //   if(DateTime.tryParse(a['begin_at']) == DateTime.tryParse(b['begin_at'])) {
      //     return DateTime.tryParse(a['begin_at']).add(Duration(minutes: a['prestazione_duration'])).compareTo(DateTime.tryParse(b['begin_at']).add(Duration(minutes: a['prestazione_duration'])));
      //   }
      //   return a['begin_at'].compareTo(b['begin_at']);
      // });

      appointments!.sort((a, b) {
        if(a.begin_at!.isAtSameMomentAs(b.begin_at!)) {
          // if(a.begin_at!.toString() == b.begin_at!.toString()) {
          return a.begin_at!.add(Duration(minutes: a.prestazione!.duration!)).compareTo(b.begin_at!.add(Duration(minutes: b.prestazione!.duration!)));
        }
        return a.begin_at!.compareTo(b.begin_at!);
      });

      // print('ffdd5d5d5d5ff5667890');
      // print(jsonData.length);
      // print(appointments.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getGuestAppointmentsByDate(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/begin_at/guest");
    var url = Uri.parse(
        "${Utils.httpServerUrl}business/$businessId/booking/guest/begin_at?day=${selectedDate.day}&month=${selectedDate.month}&year=${selectedDate.year}"
    );

    Map/*<String, String>*/ body = {
      // 'business_id': widget.business.id,
      'business_id': businessId,
      'begin_at_day': selectedDate.day,
      'begin_at_month': selectedDate.month,
      'begin_at_year': selectedDate.year,
    };

    // print('bodyfdggfsf');
    // print(body);

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // print('getAppointmentsByDate.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
      // Fluttertoast.showToast(
      //   msg: 'Autenticazione scaduta',
      //   backgroundColor: Colors.grey[700],
      // );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      for(var e in jsonData){
        Booking booking = Booking(
            id: e['booking_id'],
            isCanceled: e['is_canceled'],
            guestName: e['name'],
            guestEmail: e['email'],
            guestPhone: e['phone'],
            is_guest: 1,
            type: 2,
            // note: myAppointments[index]['note'],
            // user_id: myAppointments[index]['user_id'].toString(),
            prestazione: Prestazione(
              duration: e['prestazione_duration'],
              id: e['prestazione_id'],
              image: e['prestazione_image'],
              is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
              price: e['prestazione_price']?.toDouble(),
              price_min: e['prestazione_price_min']?.toDouble(),
              price_max: e['prestazione_price_max']?.toDouble(),
              title: e['prestazione_title'],
              description: e['prestazione_description'],
              business_id: e['prestazione_business_id'],
            ),
            user: User(
              // id: e['user_id'],
              // email: e['user_email'],
              // username: e['user_username'],
              // name: e['user_name'],
              // phone_number: e['user_phone_number'],
              profile_image: e['user_profile_image'] ?? '',
              // description: appointments[i]['user_description'],
            ),
            begin_at: DateTime.tryParse(e['begin_at'])/*.toLocal()*/,
            end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration'].toInt()))/*.toLocal()*/,
            created_at: DateTime.tryParse(e['created_at'])/*.toLocal()*//*.add(Duration(hours: 2))*/,
            note: e['note']
        );

        appointments!.add(booking);
      }
      // appointments!.addAll(jsonData);

      // appointments!.sort((a, b) {
      //   if(DateTime.tryParse(a['begin_at']) == DateTime.tryParse(b['begin_at'])) {
      //     return DateTime.tryParse(a['begin_at']).add(Duration(minutes: a['prestazione_duration'])).compareTo(DateTime.tryParse(b['begin_at']).add(Duration(minutes: a['prestazione_duration'])));
      //   }
      //   return a['begin_at'].compareTo(b['begin_at']);
      // });

      appointments!.sort((a, b) {
        if(a.begin_at!.isAtSameMomentAs(b.begin_at!)) {
          // if(a.begin_at!.toString() == b.begin_at!.toString()) {
          return a.begin_at!.add(Duration(minutes: a.prestazione!.duration!)).compareTo(b.begin_at!.add(Duration(minutes: b.prestazione!.duration!)));
        }
        return a.begin_at!.compareTo(b.begin_at!);
      });

      // print('dfdfdfbb4dbb4ddf5');
      // print(jsonData.length);
      // print(appointments.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getTimetableDay(String? businessId, int weekday) async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable/weekday");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/timetable/weekday/${weekday.toString()}");

    Map/*<String, String>*/ body = {
      'weekday': weekday.toString(),
      // 'business_id': widget.business.id,
      'business_id': businessId,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // print('response.statusCode');
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      timetableDay = jsonData;
      // });

      // print(jsonData);
      // print('timetableDay.toString()11');
      // print(timetableDay.toString());

      if(timetableDay!.isNotEmpty){
        for(var e in timetableDay!) {
          // setState(() {
          openingDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            int.tryParse(e['open_at_hour'])! /*+ DateTime.now().timeZoneOffset.inHours*/,
            int.tryParse(e['open_at_minute'])!,
          )/*.toLocal()*//*.add(Duration(hours: 2))*//*.toUtc()*/;
          openingDates.add(openingDate);

          closingDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            int.tryParse(e['close_at_hour'])! /*+ DateTime.now().timeZoneOffset.inHours*/,
            int.tryParse(e['close_at_minute'])!,
          )/*.toLocal()*//*.add(Duration(hours: 2))*//*.toUtc()*/;
          closingDates.add(closingDate);
          // });

          // print('openingDates');
          // print(openingDates.toString());
          // print('closingDates');
          // print(closingDates.toString());

          DateTime newDate = openingDate;
          // DateTime newDate0 = closingDate;
          // print('newDate0');
          // print(newDate.toString());

          contaIntervalliDaMezzora = 0;
          // intervalliDaMezzoraPerApertura.clear();
          while(newDate.isBefore(closingDate)) {
            intervalliDaMezzoraPerAperturaBegin.add(newDate);
            intervalliDaMezzoraPerAperturaEnd.add(newDate.add(Duration(minutes: 30)));
            newDate = newDate.add(Duration(minutes: 30));
            contaIntervalliDaMezzora++;
            // if(newDate.add(Duration(minutes: 30)).isAfter(newDate.add(Duration(minutes: widget.prestazione.duration))))
            if(newDate.add(Duration(minutes: 30)).isAfter(closingDate)) {
              intervalliDaMezzoraPerApertura.add(contaIntervalliDaMezzora);
              // intervalliDaMezzoraPerAperturaBegin.removeAt(intervalliDaMezzoraPerAperturaBegin.length-1);
              // intervalliDaMezzoraPerAperturaEnd.removeAt(intervalliDaMezzoraPerAperturaEnd.length-1);
              break;
            }
          }

          // print('contaIntervalliDaMezzora');
          // print(contaIntervalliDaMezzora);
          // print('intervalliDaMezzoraPerApertura');
          // print(intervalliDaMezzoraPerApertura);
          // print('intervalliDaMezzoraPerApertura1');
          // print(intervalliDaMezzoraPerApertura1);
          //
          // print('intervalliDaMezzoraPerAperturaBegin');
          // print(intervalliDaMezzoraPerAperturaBegin);
          // print('intervalliDaMezzoraPerAperturaEnd');
          // print(intervalliDaMezzoraPerAperturaEnd);
          //
          // print('contaIntervalliDaMezzora');
          // print(contaIntervalliDaMezzora.toString());
          // print('newDate1');
          // print(newDate.toString());
        }

        notifyListeners();
        return jsonData;
      }
    }
    notifyListeners();
  }

  Future setOccupiedDates(String? businessId, DateTime occupiedFrom, DateTime occupiedUntil, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse("${Utils.httpServerUrl}occupied_booking");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/booking/occupied");

    Map/*<String, String>*/ body = {
      // 'business_id': widget.business.id,
      'business_id': businessId,
      'occupied_from': occupiedFrom.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toUtc()*/.toString()/*.toIso8601String()*/,
      'occupied_until': occupiedUntil.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toUtc().*/.toString()/*.toIso8601String()*/,
    };

    var response = await http.post(
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

    print('response.statusCode');
    print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   appointments = jsonData;
      // });

      print('jsonData');
      print(jsonData);
      // print(appointments.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future deleteOccupiedDates(String? businessId, DateTime occupiedFrom, DateTime occupiedUntil, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse("${Utils.httpServerUrl}occupied_booking");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/booking/occupied");

    Map/*<String, String>*/ body = {
      // 'business_id': widget.business.id,
      'business_id': businessId,
      'occupied_from': occupiedFrom.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toUtc()*/.toString()/*.toIso8601String()*/,
      'occupied_until': occupiedUntil.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toUtc()*/.toString()/*.toIso8601String()*/,
    };

    var response = await http.delete(
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

    print('response.statusCodeAAAAAAAAAAAAA');
    print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
      // Fluttertoast.showToast(
      //   msg: 'Autenticazione scaduta',
      //   backgroundColor: Colors.grey[700],
      // );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   appointments = jsonData;
      // });

      // print('jsonData');
      // print(jsonData);
      // print(appointments.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future getOccupiedDates(String? businessId,) async {
    // var url = Uri.parse("${Utils.httpServerUrl}occupied_booking/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/booking/occupied");

    Map/*<String, String>*/ body = {
      // 'business_id': widget.business.id,
      'business_id': businessId,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // print('response.statusCode');
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonData9gfgg6gf6');
      // print(jsonData);

      occupiedDates.clear();

      for(var e in jsonData){
        Map<String, dynamic> value = {
          'id': e['id'],
          'business_id': e['business_id'],
          'occupied_from': DateTime.tryParse(e['occupied_from'].replaceAll('Z', ''))!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*//*.toLocal()*/.toString(),
          'occupied_until': DateTime.tryParse(e['occupied_until'].replaceAll('Z', ''))!/*.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))*//*.toLocal()*/.toString(),
          // 'occupied_at': DateTime.tryParse(e['occupied_at']).toLocal().toString(),
          'created_at': DateTime.tryParse(e['created_at'].replaceAll('Z', ''))!/*.toLocal()*/.toString(),
        };
        occupiedDates.add(value);
      }

      // occupiedDates = jsonData;

      // print('occupiedDates');
      // print(jsonData);
      // print(occupiedDates.toString());
      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future createSlots(List occupiedDates, List<Booking>? appointments, int day, month, int year, List socketAppointments, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    appointmentsDefinitive.clear();

    if(selectedDate.day == day && selectedDate.month == month && selectedDate.year == year) {
      // print('fffffffff\n' + occupiedDates.toString() + '\n' + appointments.toString());
      // print('length');
      // print(intervalliDaMezzoraPerAperturaBegin.length);
      // print(intervalliDaMezzoraPerAperturaEnd.length);

      // // print('intervalliDaMezzoraPerAperturaBeginEnd');
      // for (int i = 0; i < intervalliDaMezzoraPerAperturaBegin.length; i++) {
      //   if(intervalliDaMezzoraPerAperturaBegin[i].day == day &&
      //       intervalliDaMezzoraPerAperturaBegin[i].month == month &&
      //       intervalliDaMezzoraPerAperturaBegin[i].year == year) {
      //     // print(
      //     //     DateTime.tryParse(
      //     //         intervalliDaMezzoraPerAperturaBegin[i].toString())!/*.tolocal()*/.toString().substring(11, 16)
      //     //         + ' - ' +
      //     //         DateTime.tryParse(
      //     //             intervalliDaMezzoraPerAperturaEnd[i].toString())!/*.tolocal()*/.toString().substring(11, 16)
      //     // );
      //   }
      // }

      // // print('occupiedbookings11111');
      // for (var e in occupiedDates) {
      //   // if(e.day == day &&
      //   //     e.month == month &&
      //   //     e.year == year) {
      //   if (selectedDate.year == DateTime.tryParse(e['occupied_from'])!/*.tolocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).year &&
      //       selectedDate.month == DateTime.tryParse(e['occupied_from'])!/*.tolocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).month &&
      //       selectedDate.day == DateTime.tryParse(e['occupied_from'])!/*.tolocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).day) {
      //     // print(
      //     //     DateTime.tryParse(e['occupied_from'])!/*.tolocal()*/.toString() /*.substring(11, 16)*/
      //     //     + ' - ' + DateTime.tryParse(e['occupied_until'])!/*.tolocal()*/.toString() /*.substring(11, 16)*/
      //     // );
      //   }
      //   // }
      // }

      // print('apppointments11111');
      // for (var e in appointments!) {
      //   if (selectedDate.year == DateTime.tryParse(e['begin_at'])!/*.tolocal()*/.year &&
      //       selectedDate.month == DateTime.tryParse(e['begin_at'])!/*.tolocal()*/.month &&
      //       selectedDate.day == DateTime.tryParse(e['begin_at'])!/*.tolocal()*/.day) {
      //     // print(
      //     //   DateTime.tryParse(e['begin_at'])!/*.tolocal()*/.toString().substring(11, 16)
      //     //   + ' - ' +
      //     //   DateTime.tryParse(e['begin_at'])!/*.tolocal()*/.add(Duration(minutes: e['prestazione_duration'].toInt())).toString().substring(11, 16)
      //     // );
      //   }
      //   // }
      // }

      for (int i = 0; i < intervalliDaMezzoraPerAperturaBegin.length; i++) {
        if(intervalliDaMezzoraPerAperturaBegin[i].day == day &&
            intervalliDaMezzoraPerAperturaBegin[i].month == month &&
            intervalliDaMezzoraPerAperturaBegin[i].year == year) {
          appointmentsDefinitive.add(
              Booking(
                  user: User(profile_image: 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                  begin_at: intervalliDaMezzoraPerAperturaBegin[i].add(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*/,
                  end_at: intervalliDaMezzoraPerAperturaEnd[i].add(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*/,
                  type: 0
              )
          );
        }
      }

      for (int i = 0; i < occupiedDates.length; i++) {
        if(DateTime.tryParse(occupiedDates[i]['occupied_from'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.day == day &&
            DateTime.tryParse(occupiedDates[i]['occupied_from'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.month == month &&
            DateTime.tryParse(occupiedDates[i]['occupied_from'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.year == year) {
          appointmentsDefinitive.add(
              Booking(
                user: User(profile_image: 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                begin_at: DateTime.tryParse(occupiedDates[i]['occupied_from'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*/,
                end_at: DateTime.tryParse(occupiedDates[i]['occupied_until'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*/,
                type: 1
              )
          );
        }
      }

      // print('appointmentsf5f5ff5');
      // print(appointments![0].begin_at.toString());

      for(int i = 0; i < appointments!.length; i++) {
        // if(DateTime.tryParse(appointments[i]['begin_at'])!.day == day &&
        //     DateTime.tryParse(appointments[i]['begin_at'])!.month == month &&
        //     DateTime.tryParse(appointments[i]['begin_at'])!.year == year) {
        if(appointments[i].begin_at!.day == day && appointments[i].begin_at!.month == month && appointments[i].begin_at!.year == year) {
          // Prestazione prestazione = Prestazione(
          //   id: appointments[i]['prestazione_id'],
          //   description: appointments[i]['prestazione_description'],
          //   image: appointments[i]['prestazione_image'],
          //   price: appointments[i]['prestazione_price'].toDouble(),
          //   title: appointments[i]['prestazione_title'],
          //   duration: appointments[i]['prestazione_duration'].toInt(),
          // );
          Prestazione prestazione = appointments[i].prestazione!;

          // User user = User(
          //   email: appointments[i]['user_email'],
          //   username: appointments[i]['user_username'],
          //   name: appointments[i]['user_name'],
          //   phone_number: appointments[i]['user_phone_number'],
          //   profile_image: appointments[i]['user_profile_image'] ?? 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          //   description: appointments[i]['user_description'],
          //   id: appointments[i]['user_id'],
          // );
          User user = appointments[i].user;
          Booking appointment = Booking(
            // id: appointments[i]['booking_id'],
            id: appointments[i].id,
            is_guest: 0,
            // isCanceled: appointments[i]['is_canceled'],
            isCanceled: appointments[i].isCanceled,
            // begin_at: DateTime.tryParse(appointments[i]['begin_at'])!.subtract(Duration(hours: 2))/*.tolocal()*//*.toUtc()*/,
            begin_at: DateTime.tryParse(appointments[i].begin_at!.toString().replaceAll('Z', ''))!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*//*.toUtc()*/,
            // end_at: appointments[i].begin_at!.subtract(Duration(hours: 2))/*.tolocal()*//*.toUtc()*/.add(Duration(minutes: appointments[i]['prestazione_duration'].toInt())),
            end_at: DateTime.tryParse(appointments[i].begin_at!.toString().replaceAll('Z', ''))!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*//*.toUtc()*/.add(Duration(minutes: appointments[i].prestazione!.duration!.toInt())),
            type: 2,
            // guestName: appointments[i]['guest_name'],
            // guestEmail: appointments[i]['guest_contact'],
            // created_at: DateTime.tryParse(appointments[i]['created_at'])!/*.tolocal()*/,
            created_at: appointments[i].created_at!/*.tolocal()*/,
            prestazione: prestazione,
            user: user,
          );
          // Booking appointment = appointments[i];

          // print(appointment.begin_at.toString());
          // appointments[i].begin_at = DateTime.tryParse(appointments[i].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().replaceAll('Z', ''));
          // appointments[i].end_at = DateTime.tryParse(appointments[i].end_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().replaceAll('Z', ''));
          // print(appointment.begin_at.toString());

          if(appointment.isCanceled == 0){
            appointmentsDefinitive.add(appointment);
          }
        }
      }

      // print('appointmentsDefinitive00');
      // for (var e in appointmentsDefinitive) {
      // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' +
      //     e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      // for (int i = 0; i < socketAppointments.length; i++) {
      //   if(DateTime.tryParse(socketAppointments[i]['begin_at'])!.day == day &&
      //       DateTime.tryParse(socketAppointments[i]['begin_at'])!.month == month &&
      //       DateTime.tryParse(socketAppointments[i]['begin_at'])!.year == year) {
      //
      //     /*await */FutureBuilder(
      //         future: Future.wait([
      //           getPrestazioneByID(socketAppointments[i]['prestazione_id']),
      //           getUserByID(socketAppointments[i]['user_id'].toString()),
      //         ]),
      //         builder: (context, snapshot){
      //           Prestazione prestazione = Prestazione(
      //             duration: snapshot.data[0]['prestazione_duration'],
      //             price: snapshot.data[0]['prestazione_price'].toDouble(),
      //             image: snapshot.data[0]['prestazione_image'],
      //             id: snapshot.data[0]['prestazione_id'],
      //             title: snapshot.data[0]['prestazione_title'],
      //             description: snapshot.data[0]['prestazione_description'],
      //             business_id: snapshot.data[0]['business_id'],
      //           );
      //
      //           // print('prestazione.title');
      //           // print(prestazione.title);
      //           // print(appointments.toString());
      //
      //           User user = User(
      //             email: snapshot.data[1]['user_email'],
      //             username: snapshot.data[1]['user_username'],
      //             name: snapshot.data[1]['user_name'],
      //             phone_number: snapshot.data[1]['user_phone_number'],
      //             profile_image: snapshot.data[1]['user_profile_image'],
      //             description: snapshot.data[1]['user_description'],
      //             id: snapshot.data[1]['user_id'],
      //           );
      //
      //           Booking appointment = Booking(
      //             begin_at: DateTime.tryParse(socketAppointments[i]['begin_at'])/*.toLocal()*/,
      //             end_at: DateTime.tryParse(socketAppointments[i]['begin_at'])!/*.toLocal()*/.add(Duration(minutes: socketAppointments[i]['prestazione_duration'].toInt())),
      //             type: 2,
      //             guestName: socketAppointments[i]['guest_name'],
      //             guestEmail: socketAppointments[i]['guest_contact'],
      //             created_at: DateTime.tryParse(socketAppointments[i]['created_at'])!/*.tolocal()*/,
      //             prestazione: prestazione,
      //             user: user,
      //           );
      //           appointmentsDefinitive.add(
      //               appointment
      //           );
      //         } as Widget Function(BuildContext, AsyncSnapshot)
      //     );
      //
      //   }
      // }

      // print('appointmentsDefinitive con socket');
      // for (var e in appointmentsDefinitive) {
      // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' +
      //     e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      // appointmentsDefinitive.sort((a, b) => a.begin_at!.compareTo(b.begin_at!));

      for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
        // print(appointmentsDefinitive[i].begin_at.toString());
        // print(appointmentsDefinitive[i].type.toString());
        for (int j = 1; j < appointmentsDefinitive.length; j++) {
          if (appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[j].begin_at!)) {
            if (appointmentsDefinitive[i].type == 0 && appointmentsDefinitive[j].type == 1) {
              appointmentsDefinitive.removeAt(i);
            }
            else if (appointmentsDefinitive[i].type == 1 && appointmentsDefinitive[j].type == 0) {
              appointmentsDefinitive.removeAt(j);
            }
            // else if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }

            // else if (appointmentsDefinitive[i].type == 0 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(j);
            // }

          }
        }
      }
      // print('appointmentsDefinitive11');
      // for (var e in appointmentsDefinitive) {
      // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' + e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
        for (int j = 1; j < appointmentsDefinitive.length; j++) {
          // print(appointmentsDefinitive[i].begin_at!);
          // print(appointmentsDefinitive[i].type);
          // print(appointmentsDefinitive[j].begin_at!);
          // print(appointmentsDefinitive[j].type);
          // print(appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[j].begin_at!) && i != j);
          // print('\n');
          if (appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[j].begin_at!) && i != j) {
          // if (appointmentsDefinitive[i].begin_at!.toString() == appointmentsDefinitive[j].begin_at!.toString() && i != j) {
            if (appointmentsDefinitive[i].type == 0 && appointmentsDefinitive[j].type == 2 && i != j) {
              appointmentsDefinitive.removeAt(i);
            }
            else if (appointmentsDefinitive[i].type == 2 && appointmentsDefinitive[j].type == 0 && i != j) {
              appointmentsDefinitive.removeAt(j);
            }
            else if (appointmentsDefinitive[i].type == 1 && appointmentsDefinitive[j].type == 2 && i != j) {
              // appointmentsDefinitive.removeAt(i);
            }
            else if (appointmentsDefinitive[i].type == 2 && appointmentsDefinitive[j].type == 1 && i != j) {
              // appointmentsDefinitive.removeAt(j);
            }
            // else if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 0 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(j);
            // }
          }
        }
      }
      // print('appointmentsDefinitive22');
      // for (var e in appointmentsDefinitive) {
      // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' + e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
        for (int j = 1; j < appointmentsDefinitive.length; j++) {
          if ((appointmentsDefinitive[i].begin_at!.isBefore(appointmentsDefinitive[j].begin_at!))
            && (appointmentsDefinitive[i].end_at!.isAtSameMomentAs(appointmentsDefinitive[j].end_at!)) && i != j) {
            if (appointmentsDefinitive[i].type == 2 && (appointmentsDefinitive[j].type == 0 || appointmentsDefinitive[j].type == 1)) {
              appointmentsDefinitive.removeAt(j);
            }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(i);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 0 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(j);
            // }
          }
        }
      }
      // print('appointmentsDefinitive33');
      // for (var e in appointmentsDefinitive) {
      // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' + e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      // for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
      //   for (int j = 1; j < appointmentsDefinitive.length; j++) {
      //     if (appointmentsDefinitive[i].begin_at
      //         .isAtSameMomentAs(appointmentsDefinitive[j].begin_at)) {
      //       if (appointmentsDefinitive[i].type == 2 &&
      //           appointmentsDefinitive[j].type == 2 &&
      //           i != j) {
      //         appointmentsDefinitive.removeAt(j);
      //       }
      //     }
      //   }
      // }
      // print('appointmentsDefinitive44');
      // for (var e in appointmentsDefinitive) {
      //   print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' +
      //       e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      // for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
      //   if (appointmentsDefinitive[i].end_at!.isAfter(appointmentsDefinitive[i + 1].begin_at!)) {
      //     if ((appointmentsDefinitive[i + 1].type == 0 || appointmentsDefinitive[i + 1].type == 1)) {
      //       appointmentsDefinitive.removeAt(i + 1);
      //     }
      //   }
      // }

      // print('appointmentsDefinitive55');
      // for (var e in appointmentsDefinitive) {
      // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' + e.type.toString());
      // }
      // print(appointmentsDefinitive.length);

      // for(int i = 0; i < appointmentsDefinitive.length-1; i++){
      //   if(appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[i+1].begin_at!)){
      //     if(appointmentsDefinitive[i].type == 0 && appointmentsDefinitive[i+1].type == 1){
      //       appointmentsDefinitive.removeAt(i);
      //     }
      //     else if(appointmentsDefinitive[i].type == 1 && appointmentsDefinitive[i+1].type == 0){
      //       appointmentsDefinitive.removeAt(i+1);
      //     }
      //     else if(appointmentsDefinitive[i].type == 1 && appointmentsDefinitive[i+1].type == 1){
      //       appointmentsDefinitive.removeAt(i+1);
      //     }
      //     else if(appointmentsDefinitive[i].type == 0 && appointmentsDefinitive[i+1].type == 0){
      //       appointmentsDefinitive.removeAt(i+1);
      //     }
      //   }
      // }

      //ripetuti due volte altrimenti non va. non so perche?
      for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
        // print(appointmentsDefinitive[i].begin_at.toString());
        // print(appointmentsDefinitive[i].type.toString());
        for (int j = 1; j < appointmentsDefinitive.length; j++) {
          if (appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[j].begin_at!)) {
            if (appointmentsDefinitive[i].type == 0 && appointmentsDefinitive[j].type == 1) {
              appointmentsDefinitive.removeAt(i);
            }
            else if (appointmentsDefinitive[i].type == 1 && appointmentsDefinitive[j].type == 0) {
              appointmentsDefinitive.removeAt(j);
            }
            // else if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }

            // else if (appointmentsDefinitive[i].type == 0 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(j);
            // }

          }
        }
      }
      for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
        for (int j = 1; j < appointmentsDefinitive.length; j++) {
          // print(appointmentsDefinitive[i].begin_at!);
          // print(appointmentsDefinitive[i].type);
          // print(appointmentsDefinitive[j].begin_at!);
          // print(appointmentsDefinitive[j].type);
          // print(appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[j].begin_at!) && i != j);
          // print('\n');
          if (appointmentsDefinitive[i].begin_at!.isAtSameMomentAs(appointmentsDefinitive[j].begin_at!) && i != j) {
            // if (appointmentsDefinitive[i].begin_at!.toString() == appointmentsDefinitive[j].begin_at!.toString() && i != j) {
            if (appointmentsDefinitive[i].type == 0 && appointmentsDefinitive[j].type == 2 && i != j) {
              appointmentsDefinitive.removeAt(i);
            }
            else if (appointmentsDefinitive[i].type == 2 && appointmentsDefinitive[j].type == 0 && i != j) {
              appointmentsDefinitive.removeAt(j);
            }
            else if (appointmentsDefinitive[i].type == 1 && appointmentsDefinitive[j].type == 2 && i != j) {
              // appointmentsDefinitive.removeAt(i);
            }
            else if (appointmentsDefinitive[i].type == 2 && appointmentsDefinitive[j].type == 1 && i != j) {
              // appointmentsDefinitive.removeAt(j);
            }
            // else if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 0 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(j);
            // }
          }
        }
      }
      for (int i = 0; i < appointmentsDefinitive.length - 1; i++) {
        for (int j = 1; j < appointmentsDefinitive.length; j++) {
          if ((appointmentsDefinitive[i].begin_at!.isBefore(appointmentsDefinitive[j].begin_at!))
              && (appointmentsDefinitive[i].end_at!.isAtSameMomentAs(appointmentsDefinitive[j].end_at!)) && i != j) {
            if (appointmentsDefinitive[i].type == 2 && (appointmentsDefinitive[j].type == 0 || appointmentsDefinitive[j].type == 1)) {
              appointmentsDefinitive.removeAt(j);
            }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(i);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 1 &&
            //     appointmentsDefinitive[j].type == 1) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 0 &&
            //     appointmentsDefinitive[j].type == 0) {
            //   appointmentsDefinitive.removeAt(j);
            // }
            // else if (appointmentsDefinitive[i].type == 2 &&
            //     appointmentsDefinitive[j].type == 2) {
            //   appointmentsDefinitive.removeAt(j);
            // }
          }
        }
      }
      
      // appointmentsDefinitive.sort((a, b) => a.begin_at!.compareTo(b.begin_at!));

      // print('businessProvider.business!.max_contemporary_appointments');
      // print(businessProvider.business!.max_contemporary_appointments);

      Map</*String*/DateTime, int> startHourCounts = {};

      for (int i = 0; i < appointmentsDefinitive.length; i++) {
        if (appointmentsDefinitive[i].type == 2) {
          final startTime = appointmentsDefinitive[i].begin_at;
          startHourCounts[startTime!] = (startHourCounts[startTime] ?? 0) + 1;
        }
      }
      // print('startHourCounts');
      // print(startHourCounts);

      startHourCounts.forEach((key, value) {
        if (value < businessProvider.business!.max_contemporary_appointments!
            && !appointmentsDefinitive.any((booking) => booking.begin_at!.isAtSameMomentAs(key) && booking.type == 1)) {
          appointmentsDefinitive.add(
            Booking(
              user: User(profile_image: 'https://images.pexels.com/photos/1081685/pexels-photo-1081685.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
              begin_at: key,
              end_at: key.add(const Duration(minutes: 30)),
              type: 0
            )
          );
        }
      });

      // appointmentsDefinitive.sort((a, b) => a.begin_at!.compareTo(b.begin_at!));

      // appointmentsDefinitive.sort((a, b) {
      //   if (a.begin_at! == b.begin_at!) {
      //     // Se gli orari sono uguali, metti prima i tipo 1
      //     if (a.type == 2) {
      //       return -1;
      //     } else {
      //       return 1;
      //     }
      //   }
      //   return a.begin_at!.compareTo(b.begin_at!);
      // });

      appointmentsDefinitive.sort((a, b) {
        if (a.begin_at! == b.begin_at!) {
          if ((a.type == 0 || a.type == 1) && (b.type != 0 && b.type != 1)) {
            return 1; // Metti il tipo 0 o 1 in fondo
          } else if ((b.type == 0 || b.type == 1) && (a.type != 0 && a.type != 1)) {
            return -1; // Mantieni l'ordinamento degli altri tipi
          }
          return a.end_at!.compareTo(b.end_at!); // Ordina per end_at
        }
        return a.begin_at!.compareTo(b.begin_at!); // Ordina per begin_at
      });

      // for(var e in appointmentsDefinitive){
        // print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' + e.type.toString());
      // }

      print('appointmentsDefinitive22');
      for(var e in appointmentsDefinitive){
        print(e.begin_at.toString() + ' - ' + e.end_at.toString() + ' - ' + e.type.toString());
      }
      print(appointmentsDefinitive.length);

      notifyListeners();
    }

    notifyListeners();
  }

}
