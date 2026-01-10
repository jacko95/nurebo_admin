import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/num_extensions.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/business_room_message.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/reservation.dart';
import 'package:nurebo_admin/models/reservation_proposal.dart';
import 'package:nurebo_admin/models/reservation_proposal_datetime.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/utils/notification_helper.dart';
import 'package:nurebo_admin/utils/sqflite_db.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:socket_io_client/socket_io_client.dart';


class SocketProvider extends ChangeNotifier {
  late IO.Socket socket;
  List socketAppointments = [];
  // final player = AudioPlayer();
  List<Booking> myAppointments = [];
  List notificationList = [];
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String? businessChatRoomOpen = '';
  // String? businessChatRoomId = '';
  List<BusinessChatRoomMessage> businessRoomMessages = [];
  bool isBusinessRoomOpen = false;
  // List? bookingList = [];
  List<Booking>? bookingList = [];
  List<int> bookingFrequencyList = [];
  List<Reservation> businessReservationList = [];
  // List<ReservationProposalDatetime> reservationProposalDatetimeList = [];


  SocketProvider(){
    initializeDateFormatting();

    broadcastStream.listen(
      (appointment) async {
        // print('event lllllkkkkkeeeret');
        // print(appointment);

        // setIsCanceledAppointment(appointment.toString());

        // print("appointment['business_id']");
        // print(appointment['business_id']);

        Map<String, dynamic> values = {
          "booking_id": appointment['booking_id'],
          'booking_price': appointment['prestazione_price'],
          "booking_begin_at": DateTime.tryParse(appointment['begin_at'])!/*.tolocal()*//*.add(Duration(hours: 2))*/.toString(),
          "prestazione_id": appointment['prestazione_id'],
          'prestazione_image': appointment['prestazione_image'] != null && appointment['prestazione_image'] != '' ? appointment['prestazione_image'] : appointment['business_profile_image'] ?? '',
          'prestazione_title': appointment['prestazione_title'],
          'is_canceled': appointment['is_canceled'],
          'user_id': appointment['user_id'],
          'user_username': appointment['user_username'],
          'user_profile_image': appointment['user_profile_image'],
          'user_name': appointment['user_name'],
          'business_id': appointment['business_id'],
          'business_name': appointment['business_name'],
          'sent_at': DateTime.now().toString(),
        };

        await insertLocalNotification(
            'appointment_notification',
            values
        );

        // Phoenix.rebirth(context);

        notifyListeners();
      },
      cancelOnError: false,
      // onDone: (){
      //   notifyListeners();
      // }
    );
  }

  setOpenBusinessRoom(){
    isBusinessRoomOpen = true;
    notifyListeners();
  }

  setCloseBusinessRoom(){
    isBusinessRoomOpen = false;
    notifyListeners();
  }

  void addChatRoomMessage(BusinessChatRoomMessage message) {
    // for(var e in messages) {
    //   if (e. == message.ticketCategoryId) {
    //     // e.quantity += ticket.quantity;
    //     notifyListeners();
    //     return;
    //   }
    // }
    businessRoomMessages.add(message);
    // for(var e in items) {
    //   //print(e.toString());
    // }
    notifyListeners();
  }

  Future getBusinessChatRoom(/*String? userId,*/ BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Constants.serverUrl + "single_event_room/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/room");

    // Map/*<String, String>*/ body = {
    //   "event_id": event.id.toString()
    // };

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
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('fv4vv4v4bv1b19999**');
      // print(jsonData.length);
      // print(jsonData);

      // print('businessRoomMessages.length');
      // print(businessRoomMessages.length);

      // chatRooms = jsonData;
      notifyListeners();
      return jsonData;
    }
  }

  Future getAllChatRoomMessages(/*String? userId,*/ BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Constants.serverUrl + "single_event_room/user_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/room/${businessProvider.business!.room_id}/message");

    // Map/*<String, String>*/ body = {
    //   "event_id": event.id.toString()
    // };

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
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('singlezccz5v4cv5');
      // print(jsonData.length);
      // print(jsonData);

      // for(var e in chatRooms){
      //   if(e.event!.id.toString() == event.id.toString()){
      //     // e.chatRoomMessages = [];
      //     for(var e1 in jsonData){
      //       e.chatRoomMessages!.add(
      //           ChatRoomMessage(
      //             id: e1['event_room_id'],
      //             text: e1['event_room_text'],
      //             sent_at: DateTime.tryParse(e1['event_room_sent_at'])/*.toLocal()*/,
      //             is_visible: e1['event_room_is_visible'],
      //             sender: User(
      //               id: e1['user_id'],
      //               name: e1['user_name'],
      //               email: e1['user_email'],
      //               username: e1['username'],
      //               description: e1['user_description'],
      //               phone_number: e1['user_phone_number'],
      //               profile_image: e1['user_profile_image'],
      //             ),
      //             event: Event(
      //               id: e1['event_id'],
      //               image: e1['event_image'],
      //               title: e1['event_title'],
      //               begin_at: DateTime.tryParse(e1['event_begin_at']),
      //               end_at: DateTime.tryParse(e1['event_end_at']),
      //               description: e1['event_description'],
      //               is_visible: e1['event_is_visible'],
      //             ),
      //           )
      //       );
      //     }
      //   }
      // }

      for(var e1 in jsonData){
        businessRoomMessages.add(
          BusinessChatRoomMessage(
            id: e1['business_room_message_id'],
            text: e1['business_room_message_text'],
            sent_at: DateTime.tryParse(e1['business_room_message_sent_at'] ?? '')/*.toLocal()*/,
            is_deleted: e1['business_room_message_is_deleted'],
            user: User(
              id: e1['user_id'],
              name: e1['user_name'],
              email: e1['user_email'],
              username: e1['user_username'],
              description: e1['user_description'],
              phone: e1['user_phone'],
              profile_image: e1['user_profile_image'] ?? '',
            ),
            business: Business(
              id: e1['business_id'],
              description: e1['business_description'],
              name: e1['business_name'],
              email: e1['business_email'],
              email_notification: e1['business_email_notification'],
              max_contemporary_appointments: e1['max_contemporary_appointments'],
              address: e1['business_address'],
              room_id: e1['business_room_id'],
              phone: e1['business_phone'],
              // is_booking_business: e1['is_booking_business'],
              profile_image: e1['business_profile_image'] ?? '',
              type_id: e1['business_type_id'],
              latitude: e1['business_latitude'],
              longitude: e1['business_longitude'],
              category: Category(
                id: e1['category_id'],
                image: e1['category_image'],
                name: e1['category_name'],
              )
            ),
            // event: Event(
            //   id: e1['event_id'],
            //   image: e1['event_image'],
            //   title: e1['event_title'],
            //   begin_at: DateTime.tryParse(e1['event_begin_at']),
            //   end_at: DateTime.tryParse(e1['event_end_at']),
            //   description: e1['event_description'],
            //   is_visible: e1['event_is_visible'],
            // ),
          )
        );
      }

      // print('businessRoomMessages.length');
      // print(businessRoomMessages.length);

      // chatRooms = jsonData;
      notifyListeners();
      return jsonData;
    }
  }

  Future cancelBooking(Booking booking, Business business, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "booking/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/booking/${booking.id}");

    // Map/*<String, String>*/ body = {
    //   'booking_id': appointment.id,
    //   "begin_at": appointment.begin_at.toString(),
    //   "user_id": user.id,
    //   "username": user.username,
    //   "user_profile_image": user.profile_image,
    //   "prestazione_title": appointment.prestazione.title,
    //   "business_id": appointment.business.id,
    // };

    Map/*<String, String>*/ body = {
      'booking_id': booking.id,
      'user_id': booking.user!.id,
      'business_id': business.id,
      'prestazione_title': booking.prestazione!.title,
      'prestazione_image': booking.prestazione!.image,
    }
    ..addAll(business.toJson())
    /*..addAll(booking.toJson())*/;

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

      for(var e in myAppointments){
        if(e.id == booking.id){
          // print('appuntamento da cancellare:::::' + e.id.toString());
          e.isCanceled = 1;
        }
      }

      // for(var e in bookingList!){
      //   if(e.id == booking.id){
      //     // print('appuntamento da cancellare:::::' + e.id.toString());
      //     e.isCanceled = 1;
      //   }
      // }

      // print('ullaaaa');
      // print(booking.prestazione!.id);

      // print('Appuntamento cancellato');
      //todo: invio cancellazione notifica con socketio e ordinare le mie prenotazioni per ordine di creazione
      //todo:da fare serverside in nodejs
      // socket.emit(
      //     "cancel_business_appointment_notification",
      //     {
      //       "appointment_id": booking.id,
      //       "begin_at": booking.begin_at.toString(),
      //       "user_id": booking.user!.id,
      //       "business_id": business.id,
      //       "business_name": business.name,
      //       "business_profile_image": business.profile_image,
      //       "prestazione_title": booking.prestazione!.title,
      //       "prestazione_id": booking.prestazione!.id,
      //       "prestazione_price": booking.prestazione!.price,
      //       "prestazione_image": booking.prestazione!.image,
      //       "created_at": DateTime.now()/*.toIso8601String()*/.toString(),
      //     }
      // );

      await getBusinessFrequencyReservationPerDay(business, context);

      Map<String, dynamic> values = {
        // 'id': 'rem',
        'booking_id': booking.id,
        // 'booking_begin_at': DateTime.tryParse(e['begin_at'])/*.tolocal()*/.toString(),
        'booking_begin_at': booking.begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString(),
        'prestazione_id': booking.prestazione!.id,
        'user_id': booking.user.id,
        // 'sender_username': e['username'],
        // 'sender_name': e['user_name'],
        // 'is_canceled': int.tryParse(e['type']) == 0 ? 0 : 1,
        'is_canceled': booking.type == 0 ? 0 : 1,
        'business_id': business.id,
        'business_name': business.name,
        'user_name': booking.user.name,
        'user_username': booking.user.username,
        'prestazione_title': booking.prestazione!.title,
        'prestazione_image': booking.prestazione!.image != null && booking.prestazione!.image != '' ? booking.prestazione!.image :/*??*/ booking.business?.profile_image,
        'booking_price': booking.prestazione!.price,
        // 'sent_at': DateTime.tryParse(e['sent_at'])/*.add(const Duration(hours: 2))*//*toLocal().*/.toString(),
        'sent_at': DateTime.now().toString(),
        'user_profile_image': booking.user.profile_image,
      };

      //todo: da attivare se si vogliono mostrare le notifiche all'avvio dell'app
      // showNotification(
      //   subText: int.tryParse(e['type']) == 1 ? 'Cancellazione' : 'Prenotazione',
      //   body: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(values['booking_begin_at'])).toString()
      //       + ' alle ' + values['booking_begin_at'].substring(11, 16),
      //   title: values['prestazione_title'],
      //   largeIconPath: values['prestazione_image'],
      // );

      await insertLocalNotification(
          'appointment_notification',
          values
      );

      // Map<String, dynamic> values1 = {
      //   // 'id': 'rem',
      //   'booking_id': e['booking_id'],
      //   'prestazione_id': e['prestazione_id'],
      //   'sender_id': e['sender_id'],
      //   'sender_username': e['username'],
      //   'sender_name': e['user_name'],
      //   'business_name': e['business_name'],
      //   'prestazione_title': e['prestazione_title'],
      //   'prestazione_image': e['prestazione_image'],
      //   'price': e['prestazione_price'],
      //   'sent_at': e['sent_at'],
      // };
      // await insertNotification(
      //   'booking_notification',
      //   values1
      // );

      notificationList.sort((b, a) {
        // return a.sent_at.compareTo(b.sent_at);
        // return a['created_at'].compareTo(b['created_at']);
        return DateTime.tryParse(a['sent_at'])!.compareTo(DateTime.tryParse(b['sent_at'])!);
      });

      // print(jsonData);
      // print('appointments');
      // print(appointments.toString());
      // return jsonData;
      notifyListeners();
      return 1;
    }
    return 0;
  }

  Future insertDevice(Business business, Map<String, dynamic> deviceData) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business/device");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/device");

    Map<String, dynamic> body = {
      'business_id': business.id,
      'fcm_token': deviceToken,
      'manufacturer': deviceData['manufacturer'],
      'model': deviceData['model'],
      'sdk_version': deviceData['version.sdkInt'],
      'release_version': deviceData['version.release'],
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('jsonDatauiiggyguyguyguuhiguigu');
      // print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  Future updateFcmToken(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business/fcm_token");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/fcm_token");

    Map<String, dynamic> body = {
      'business_id': business.id,
      'fcm_token': deviceToken,
    };

    // var response = await http.post(
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('fcm token');
      // print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  Future getGuestBookings() async {
    // var url = Uri.parse("${Utils.httpServerUrl}booking/booking_business/guest");
    var url = Uri.parse("${Utils.httpServerUrl}business/${BusinessPreferences.getBusinessId()}/booking/guest");

    Map<String, dynamic> body = {
      // 'business_id': widget.bookingBusiness.id,
      'business_id': BusinessPreferences.getBusinessId(),
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

      // myAppointments.addAll(jsonData);

      for(var e in jsonData){
        myAppointments.add(
            Booking(
              id: e['booking_id'],
              is_guest: 1,
              isCanceled: e['is_canceled'],
              guestName: e['name'],
              guestEmail: e['email'],
              guestPhone: e['phone'],
              note: e['note'],
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
              user: User(profile_image: ''),
              begin_at: DateTime.tryParse(e['begin_at'])/*.toLocal()*/,
              end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration']?.toInt()))/*.toLocal()*/,
              created_at: DateTime.tryParse(e['created_at'])/*.toLocal()*//*.add(Duration(hours: 2))*/,
            )
        );
      }

      // print('dskmfvkmfsfskfmk');
      // print(jsonData.length);
      // for(var e in jsonData){
      //   print(e);
      //   print(DateTime.tryParse(e['begin_at']).toLocal());
      //   e['begin_at'] = DateTime.tryParse(e['begin_at']).subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toLocal()*//*.toUtc()*//*.toIso8601String()*/.toString();
      //   // e['begin_at'] = "DateTime.tryParse(e['begin_at'])/*.toLocal()*/.toUtc()/*.toIso8601String()*/.toString()";
      // }

      myAppointments.sort((b, a) => a.created_at!.compareTo(b.created_at!));


      notifyListeners();
      return jsonData;
    }
    notifyListeners();
  }

  Future startSession(Business business, Map<String, dynamic> businessSession) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/device");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/session");

    Map<String, dynamic> body = {
      'business_id': business.id,
      // 'authentication_id': UserPreferences.getUserToken()!,
      'ip_addr': businessSession['query'],
      'city': businessSession['city'],
      'zip': businessSession['zip'],
      'latitude': businessSession['lat'],
      'longitude': businessSession['lon'],
      'begin_at': DateTime.now()/*.toIso8601String()*/.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
    };

    var response = await http.post(
      // var response = await http.put(
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
      },
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      //print('ujdujjfvjufvjfvju');
      //print(jsonData);

      await BusinessPreferences.setSessionId(jsonData.toString());

      notifyListeners();
      return jsonData;
    }
  }

  Future closeSession(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "user/device");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/session/${BusinessPreferences.getSessionId()!}/close");

    Map<String, dynamic> body = {
      // 'session_id': BusinessPreferences.getSessionId()!,
      'end_at': DateTime.now()/*.toIso8601String()*/.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
    };

    // var response = await http.delete(
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
      },
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // //print('jsonDatauiiguhiguigu');
      // //print(jsonData);

      await BusinessPreferences.setSessionId('');

      notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessAppointments(/*Business? business*/) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/payments");
    var url = Uri.parse("${Utils.httpServerUrl}business/${BusinessPreferences.getBusinessId()}/booking");

    // Map/*<String, String>*/ body = {
    //   'business_id': widget.bookingBusiness.id,
    //   'now_bookingtime': now.toString(),
    // };
    Map/*<String, String>*/ body = {
      // 'business_id': business.id,
      'business_id': BusinessPreferences.getBusinessId(),
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
          // 'Authorization': BusinessPreferences.getUserToken()
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print("ooooooooooo response.statusCode:");
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      // await businessProvider.logout(context);
      Fluttertoast.showToast(
        msg: 'Autenticazione scaduta',
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('hereeff5fgg6g66eee');
      print(jsonData);

      int cccc = 0;
      for(var e in jsonData){
        cccc++;
        // if(DateTime.tryParse(e['begin_at']).isBefore(now)){
        // setState(() {
        //   myAppointments.add(e);
          myAppointments.add(
              Booking(
                id: e['booking_id'],
                is_guest: 0,
                isCanceled: e['is_canceled'],
                guestName: e['guest_name'],
                guestEmail: e['guest_contact'],
                // note: myAppointments[index]['note'],
                // user_id: myAppointments[index]['user_id'].toString(),
                prestazione: Prestazione(
                  duration: e['prestazione_duration'],
                  id: e['prestazione_id'],
                  image: e['prestazione_image'],
                  // is_price_range: int.tryParse(e['prestazione_is_price_range'] ?? '0') == 1 ? true : false,
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
                begin_at: DateTime.tryParse(e['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: e['prestazione_duration'].toInt()))/*.toLocal()*/,
                created_at: DateTime.tryParse(e['created_at'])/*.toLocal()*//*.add(Duration(hours: 2))*/,
              )
          );
        // });
        // }
      }

      myAppointments.sort((b, a) => a.created_at!.compareTo(b.created_at!));

      // setState(() {
      //   myAppointments = jsonData;
      //   // results.addAll(jsonData);
      //   // results.shuffle();
      // });
      // print("singleEventTicketCategories: ");
      // print(singleEventTicketCategories);
      // print('searchUserByUsername results.toString()');
      // print(results.toString());
      // print('cccc');
      // print(cccc.toString());
      // print('myAppointments.length');
      // print(myAppointments.length);
      notifyListeners();
      return jsonData;
    }
  }

  // Future getBusinessReservationProposals(Reservation reservation) async {
  //   var url = Uri.parse("${Utils.httpServerUrl}reservation/${reservation?.id}/proposal/latest");
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'business_id': business.id,
  //   //   'business_id': BusinessPreferences.getBusinessId(),
  //   // };
  //
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //         // 'Authorization': BusinessPreferences.getUserToken()
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
  //       }
  //   );
  //
  //   // print("ooooooooooo response.statusCode:");
  //   // print(response.statusCode);
  //
  //   if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
  //     Fluttertoast.showToast(
  //       msg: 'Autenticazione scaduta',
  //       backgroundColor: Colors.grey[700],
  //     );
  //   }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('ff5f5f5gg5');
  //     print(jsonData);
  //     print(jsonData.length);
  //
  //     reservationProposalDatetimeList.clear();
  //     for(var e in jsonData){
  //       reservationProposalDatetimeList.add(
  //           ReservationProposalDatetime.fromJson(e)
  //       );
  //     }
  //
  //     // print(reservationProposalDatetimeList);
  //
  //     notifyListeners();
  //     return jsonData;
  //   }
  // }

  Future deleteReservation(Reservation reservation, /*ReservationProposal reservationProposal, ReservationProposalDatetime reservationProposalDatetime*/) async {
    // BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    var url = Uri.parse("${Utils.httpServerUrl}reservation/${reservation.id}");

    Map<String, dynamic> body = {
      ...reservation.toJson(),
      // ...reservationProposal.toJson(),
      // ...reservationProposalDatetime.toJson(),
      "user_type_id": 1,
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

    // print('response.statusCode');
    // print(response.statusCode);

    // if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
    //   // if (!mounted) return;
    //   await businessProvider.logout(context);
    // }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      for(var e in businessReservationList){
        if(e.id == reservation.id){
          // businessReservationList.remove(e);

          e.is_canceled = true;
          e.is_canceled_at = DateTime.now();
          e.last_edit_at = DateTime.now();

          businessReservationList.sort((b, a) => a.last_edit_at!.compareTo(b.last_edit_at!));
        }
      }

      notifyListeners();
      // return jsonData;
    }
    return response.statusCode;
  }

  Future confirmReservationProposal(Reservation reservation, ReservationProposal reservationProposal, ReservationProposalDatetime reservationProposalDatetime) async {
    var url = Uri.parse("${Utils.httpServerUrl}reservation/${reservation.id}/proposal/${reservationProposal.id}/confirm");

    Map<String, dynamic> body = {
      ...reservation.toJson(),
      ...reservationProposal.toJson(),
      ...reservationProposalDatetime.toJson(),
      "user_type_id": 1,
    };

    print('body44444');
    print(body);

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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      for(var e in businessReservationList){
        if(e.id == reservation.id){
          if(/*!e.is_validated == false || */e.validated_at == null){
              e.validated_at = DateTime.now();
              // e.is_validated = true;
          }
          e.datetime = reservationProposalDatetime.datetime;
          e.last_edit_at = DateTime.now();
          e.proposal = null;
        }
      }

      Fluttertoast.showToast(
        msg: "Prenotazione confermata",
        backgroundColor: Colors.grey[700],
      );

      // return jsonData;
      notifyListeners();
      return response.statusCode;
    }
    notifyListeners();
    return response.statusCode;
  }

  Future sendReservationProposal(Reservation reservation, List<DateTime> proposalDatetimes/*ReservationProposal reservationProposal, ReservationProposalDatetime reservationProposalDatetime*/) async {
    var url = Uri.parse("${Utils.httpServerUrl}reservation/${reservation.id}/proposal");

    Map<String, dynamic> body = {
      ...reservation.toJson(),
      // "reservation_proposal_datetime":  proposalDatetimes.map((e) => e.toIso8601String()).toList(),
      "reservation_proposal_datetime": proposalDatetimes
          .map((e) => {"datetime": e.toIso8601String()}) // Crea una mappa per ogni datetime
          .toList(),
      // ...reservationProposal.toJson(),
      // ...reservationProposalDatetime.toJson(),
      "user_type_id": 1,
    };

    print('body455224456');
    print(body);

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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('jsonData456811mm');
      print(jsonData);

      for(var e in businessReservationList){
        if(e.id == reservation.id){
          // if(/*!e.is_validated == false || */e.validated_at == null){
          //     e.validated_at = DateTime.now();
          //     // e.is_validated = true;
          // }
          // e.datetime = reservationProposalDatetime.datetime;
          e.last_edit_at = DateTime.now();
          e.proposal = ReservationProposal(
            reservation: reservation,
            id: jsonData,
            user_type_id: 1,
            created_at: DateTime.now(),
          );
        }
      }

      Fluttertoast.showToast(
        msg: "Proposta inviata",
        backgroundColor: Colors.grey[700],
      );

      // return jsonData;
      notifyListeners();
      return response.statusCode;
    }
    notifyListeners();
    return response.statusCode;
  }

  Future getBusinessReservations(/*Business? business*/) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/payments");
    var url = Uri.parse("${Utils.httpServerUrl}business/${BusinessPreferences.getBusinessId()}/reservation");

    // Map/*<String, String>*/ body = {
    //   'business_id': widget.bookingBusiness.id,
    //   'now_bookingtime': now.toString(),
    // };
    Map/*<String, String>*/ body = {
      // 'business_id': business.id,
      'business_id': BusinessPreferences.getBusinessId(),
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
          // 'Authorization': BusinessPreferences.getUserToken()
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print("ooooooooooo response.statusCode:");
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      // await businessProvider.logout(context);
      Fluttertoast.showToast(
        msg: 'Autenticazione scaduta',
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('f51bvbbbbb1gg');
      print(jsonData);
      print(jsonData.length);

      // int cccc = 0;
      for(var e in jsonData){
        // cccc++;
        // if(DateTime.tryParse(e['begin_at']).isBefore(now)){
        // setState(() {
        //   myAppointments.add(e);
        businessReservationList.add(
          Reservation(
            id: e['reservation_id']?.toString(),
            business: Business(
              id: e['business_id']?.toString(),
              name: e['business_name']?.toString(),
              profile_image: e['business_image_url']?.toString(),
              phone: e['business_phone']?.toString(),
              email: e['business_email']?.toString(),
              address: e['business_address']?.toString(),
            ),
            name: e['reservation_name']?.toString(),
            datetime: e['reservation_datetime_datetime']?.toString() != null
                ? DateTime.tryParse(e['reservation_datetime_datetime']!.toString())?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))
                : null,
            last_edit_at: e['sort_timestamp']?.toString() != null
                ? DateTime.tryParse(e['sort_timestamp']!.toString())?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))
                : null,
            created_at: e['reservation_created_at']?.toString() != null
                ? DateTime.tryParse(e['reservation_created_at']!.toString())?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))
                : null,
            validated_at: e['reservation_validation_created_at']?.toString() != null
                ? DateTime.tryParse(e['reservation_validation_created_at']!.toString())?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))
                : null,
            proposal: (e['reservation_proposal_id'] != null) ? ReservationProposal(
              id: e['reservation_proposal_id']?.toString(),
              user_type_id: (e['reservation_proposal_user_type_id'] as int?) ?? 0,
              created_at: e['reservation_proposal_created_at']?.toString() != null
                  ? DateTime.tryParse(e['reservation_proposal_created_at']!.toString())?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))
                  : null,
            ) : null,
            quantity: (e['reservation_quantity'] as int?) ?? 0,
            email: e['reservation_email']?.toString(),
            user_url: e['reservation_user_url']?.toString(),
            business_url: e['reservation_business_url']?.toString(),
            phone: e['reservation_phone']?.toString(),
            info: e['business_info']?.toString(),
            is_canceled: (e['reservation_cancel_created_at']) != null ? true : false,
            is_canceled_at: e['reservation_cancel_created_at']?.toString() != null
                ? DateTime.tryParse(e['reservation_cancel_created_at']!.toString())?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))
                : null,
          ),
        );
        // });
        // }
      }

      // businessReservationList.sort((b, a) => a.created_at!.compareTo(b.created_at!));

      // setState(() {
      //   myAppointments = jsonData;
      //   // results.addAll(jsonData);
      //   // results.shuffle();
      // });
      // print("singleEventTicketCategories: ");
      // print(singleEventTicketCategories);
      // print('searchUserByUsername results.toString()');
      // print(results.toString());
      // print('cccc');
      // print(cccc.toString());
      // print('myAppointments.length');
      // print(myAppointments.length);
      notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessFrequencyReservationPerDay(Business business, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/appointments");
    var url = Uri.parse("${Utils.httpServerUrl}business/${/*businessProvider.*/business!.id}/booking/is_visible");

    Map/*<String, String>*/ body = {
      'business_id': /*businessProvider.*/business!.id,
      // 'business_id': BusinessPreferences.getBusinessId(),
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
          'Authorization': BusinessPreferences.getBusinessToken()!
        }
    );

    // print("fgggggi response.statusCode:");
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // bookingList = jsonData;
      print('bookingList465569');
      // print(jsonData);
      // print(jsonData[0]);
      print(bookingList);
      print(bookingList!.length);

      // bookingList = jsonData;

      bookingList!.clear();
      for(var e in jsonData){
        bookingList!.add(
            Booking(
              id: e['booking_id'],
              isCanceled: e['is_canceled'],
              // note: myAppointments[index]['note'],
              // user_id: myAppointments[index]['user_id'].toString(),
              prestazione: Prestazione(
                duration: e['prestazione_duration'],
                image: e['prestazione_image'],
                id: e['prestazione_id'],
                // is_price_range: int.tryParse(e['prestazione_is_price_range'] ?? '0') == 1 ? true : false,
                is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                title: e['prestazione_title'],
                description: e['prestazione_description'],
                // business_id: socketBody['business_id'],
                business: Business(
                    id: e['business_id'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    type_id: e['business_type_id'],
                    // profile_image: e['business_image'],
                    profile_image: e['business_profile_image'] ?? '',
                    description: e['business_description'],
                    address: e['business_address'],
                    room_id: e['business_room_id'],
                    phone: e['business_phone'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                phone: e['user_phone'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              business: Business(
                id: e['business_id'],
                name: e['business_name'],
                room_id: e['business_room_id'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                type_id: e['business_type_id'],
                // profile_image: e['business_image'],
                profile_image: e['business_profile_image'] ?? '',
                description: e['business_description'],
                address: e['business_address'],
                phone: e['business_phone'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
              ),
              begin_at: DateTime.tryParse(e['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration']?.toInt())).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              created_at: DateTime.tryParse(e['created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            )
        );
      }


      int daysToSubtract = 0;
      // print('bookingFrequency');
      for(int i = 13; i > 0; i--){
        int bookingFrequency = 0;
        for(int i = bookingList!.length-1; i >= 0; i--){
          // if(DateTime.tryParse(bookingList![i]['created_at'])!.day.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).day)
          //     && DateTime.tryParse(bookingList![i]['created_at'])!.month.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).month)
          //     && DateTime.tryParse(bookingList![i]['created_at'])!.year.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).year)){
          if(bookingList![i].created_at!.day.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).day)
              && bookingList![i].created_at!.month.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).month)
              && bookingList![i].created_at!.year.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).year)){
            bookingFrequency++;
          }
        }
        // if(mounted){
        //   setState(() {
            bookingFrequencyList.add(bookingFrequency);
          // });
        // }

        // print(i.toString() + " $bookingFrequency");
        daysToSubtract++;
      }

      // print('jsonData');
      // print(jsonData);
      // print('bookingList');
      // print(bookingList);

      notifyListeners();
      return jsonData;
    }
  }

  deleteAllBookings(){
    myAppointments.clear();
    notifyListeners();
  }

  // Future initialize() async {
  //   // await audioPlayer.open(
  //   //   // Audio('assets/audio/Life Could Be A Dream (Chill TRAP REMIX).mp3'),
  //   //   Audio('assets/audio/piece-of-cake-611.ogg'),
  //   //   autoStart: false,
  //   //   // showNotification: true
  //   // );
  //   var notificationAudio = await player.setAsset('assets/audio/piece-of-cake-611.ogg');
  //
  //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //   FlutterLocalNotificationsPlugin();
  //   final AndroidInitializationSettings androidInitializationSettings =
  //   AndroidInitializationSettings('ic_launcher'); //Add Icon in android->app->src->main->res->drawable
  //   final IOSInitializationSettings iosInitializationSettings =
  //   IOSInitializationSettings(); //check AppDelegate.swift in Runner Folder
  //   final InitializationSettings initializationSettings =
  //   InitializationSettings(
  //       android: androidInitializationSettings,
  //       iOS: iosInitializationSettings
  //   );
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  Future<void> tryConnectSocket(String? businessId, BuildContext context, {int maxRetries = 50}) async {
    // /*late*/ Socket? sock;
    // do {
    //   sock = await connect(businessId, context);
    // } while(sock != null);
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      // print(url);
      try {
        Socket? sock = await connect(businessId, context);
        if (sock != null) {
          return;
        }
      } catch (e) {
        // Gestisci l'errore, se necessario
      }
    }
  }

  Future<Socket?> connect(String? businessId, BuildContext context) async {
    await BusinessPreferences.init();
    // await initialize();
    // var notificationProvider = Provider.of<NotificationProvider>(context, listen: true);
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    socket = IO.io(
        Utils.httpServerUrl,
        // <String, dynamic> {
        //   "transports": ["websocket"],
        //   "autoConnect": false,
        // }
        IO.OptionBuilder()
            .setTransports(["websocket", "polling"])
            .enableForceNewConnection()
        // .disableForceNewConnection()
        // .enableAutoConnect()
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(20)
            .setReconnectionDelay(500)
        // .disableReconnection()
            .enableForceNew()
        // .disableForceNew()
            .enableMultiplex()
        // .disableMultiplex()
            .build()
    );

    // print('socketProvider.socket.ids');
    // print(socket.ids);

    socket.onConnect((data) {
      // print('socket.id');
      // print(socket.id);
      // print('socket.id');
      // print(socket.id);
      // print('socket.ids');
      // print(socket.ids);
      // print('socket.opts');
      // print(socket.opts);
      // print('socket.flags');
      // print(socket.flags);
      // print('socket.connected');
      // print(socket.connected);
      // print('data');
      // print(data);

      /*await*/ socket.onReconnectFailed((data) {
        // print('onReconnectFailed');
      });

      /*await*/ socket.onConnectError((data) {
        // print('onConnectError');
      });

      /*await*/ socket.onConnectError((data) {
        // print('onConnectTimeout');
      });

      /*await*/ socket.onReconnectAttempt((data) {
        // print('onReconnectAttempt');
      });

      /*await*/ socket.onReconnectError((data) {
        // print('onReconnectError');
      });

      /*await*/ socket.onReconnect((data) {
        // print('onReconnect');
      });

      /*await*/ socket.onConnect((data) {
        // print('onConnecting');
      });

      /*await*/ socket.onReconnect((data) {
        // print('onReconnecting');
      });

      /*await*/ socket.onError((data) {
        // print('onError');
      });

      /*await*/ socket.onDisconnect((data) {
        // socket.destroy();
        // socket.disconnect();
        // socket.close();
        // socket.dispose();
        // print('onDisconnect');
      });

      // print('socket.connected rovider');
      // print(socket.connected);

      socket.emit(
          "join_booking_business_appointments",
          {
            'id': businessId,
            'type': 'provider'
          }
      );

      socket!.emit(
          "join-business_room",
          {
            "id": /*businessChatRoomId*/businessProvider.business!.room_id
          }
      );

      socket.emit(
          "join-business",
          {
            "id": businessProvider.business?.id
          }
      );

      socket.on(
        "update-business_reservations", (msg) async {
          businessReservationList.clear();
          Future.wait([
            getBusinessReservations(),
          ]);
          // await getBusinessReservations();

          // notifyListeners();
        },
      );

      socket!.on(
        // "receive_business-business_room_message",
        "receive-business_room_message",
        (msg) async {
          // await showNotification(title: 'allah', body: 'akbar');
          // print('porcamladonn');
          // print(msg);

          // addChatRoomMessage(
          // // businessRoomMessages.add(
          //   BusinessChatRoomMessage(
          //     id: msg['business_room_message_id'],
          //     text: msg['business_room_message_text'],
          //     sent_at: DateTime.tryParse(msg['business_room_message_sent_at'] ?? '')/*.toLocal()*/,
          //     is_deleted: msg['business_room_message_is_deleted'],
          //     user: User(
          //       id: msg['user_id'],
          //       name: msg['user_name'],
          //       email: msg['user_email'],
          //       username: msg['user_username'],
          //       description: msg['user_description'],
          //       phone_number: msg['user_phone_number'],
          //       profile_image: msg['user_profile_image'] ?? '',
          //     ),
          //     business: Business(
          //       id: msg['business_id'],
          //       description: msg['business_description'],
          //       name: msg['business_name'],
          //       email: msg['business_email'],
          //       email_notification: msg['business_email_notification'],
          //       max_contemporary_appointments: msg['max_contemporary_appointments'],
          //       address: msg['business_address'],
          //       phone_number: msg['business_phone_number'],
          //       // is_booking_business: e1['is_booking_business'],
          //       profile_image: msge['business_profile_image'] ?? '',
          //       type_id: msg['business_type_id'],
          //       latitude: msg['business_latitude'],
          //       room_id: msg['business_room_id'],
          //       longitude: msg['business_longitude'],
          //       category: Category(
          //         id: msg['category_id'],
          //         image: msg['category_image'],
          //         name: msg['category_name'],
          //       )
          //     ),
          //     // event: Event(
          //     //   id: e1['event_id'],
          //     //   image: e1['event_image'],
          //     //   title: e1['event_title'],
          //     //   begin_at: DateTime.tryParse(e1['event_begin_at']),
          //     //   end_at: DateTime.tryParse(e1['event_end_at']),
          //     //   description: e1['event_description'],
          //     //   is_visible: e1['event_is_visible'],
          //     // ),
          //   )
          // );

          // if(isBusinessRoomOpen == true){
            businessRoomMessages.clear();
            await getAllChatRoomMessages(/*widget.business! ,*//*Utils.business!*/context);
          // }

          // businessRoomMessages.add(
          //     BusinessChatRoomMessage(
          //       text: msg["content"],
          //       event: Event(
          //         id: msg["singleEventId"],
          //       ),
          //       // singleEventId: msg["singleEventId"],
          //       // senderId: msg["senderId"],
          //       sender: User(
          //         id: msg["senderId"],
          //         profile_image: msg["senderProfileImage"],
          //         username: msg["senderUsername"],
          //       ),
          //       sent_at: DateTime.tryParse(msg['sentAt'].toString()),
          //       is_visible: 1,
          //       // id:
          //     )
          // );

          notifyListeners();
        },
      );

      socket.on(
        "cancel_business_appointment_notification",
        (appointment) async {
          // print('canceled appointment');
          // print(appointment);

          // streamController.sink.add(appointment);

          Business business00 = Business(
            id: appointment['business_id'],
            email: appointment['business_email'],
            name: appointment['business_name'],
            room_id: appointment['business_room_id'],
            longitude: appointment['business_longitude'],
            latitude: appointment['business_latitude'],
            phone: appointment['business_phone'],
            profile_image: appointment['business_profile_image'] ?? '',
            address: appointment['business_address'],
            description: appointment['business_description'],
            type_id: appointment['business_type_id'],
            // max_contemporary_appointments: e['max_contemporary_appointments'],
            // category: Category(
            //   id: e['category_id'],
            //   image: e['category_image'],
            //   name: e['category_name'],
            // )
          );

          for(var e in myAppointments){
            // if(e.id == appointment['appointment_id']){
            if(e.id == appointment['booking_id']){
              // print('ortsoalllaa');
              e.isCanceled = 1;
            }
          }

          notificationList.sort((b, a) {
            // return a.sent_at.compareTo(b.sent_at);
            // return a['created_at'].compareTo(b['created_at']);
            return DateTime.tryParse(a['sent_at'])!.compareTo(DateTime.tryParse(b['sent_at'])!);
          });

          getBusinessFrequencyReservationPerDay(business00, context);

          Map<String, dynamic> values = {
            "booking_id": appointment['booking_id'],
            'booking_price': appointment['prestazione_price'],
            "booking_begin_at": DateTime.tryParse(appointment['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
            "prestazione_id": appointment['prestazione_id'],
            'prestazione_image': appointment['prestazione_image'] != null && appointment['prestazione_image'] != '' ? appointment['prestazione_image'] : appointment['business_profile_image'] ?? '',
            'prestazione_title': appointment['prestazione_title'],
            'is_canceled': 1,
            'user_id': appointment['user_id'],
            'user_username': appointment['user_username'],
            'user_profile_image': appointment['user_profile_image'],
            'user_name': appointment['user_name'],
            'business_id': appointment['business_id'],
            'business_name': appointment['business_name'],
            'sent_at': DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString(),
          };

          await insertLocalNotification(
              'appointment_notification',
              values
          );

          notifyListeners();
        },
      );

      socket.on(
        "update_booking_business_appointments",
        (appointment) async {
          print('appointmentdc6ffe6ee6e66');
          print(appointment);

          // print('socket.id provider');
          // print(socket.id);

          Business business00 = Business(
            id: appointment['business_id'],
            email: appointment['business_email'],
            name: appointment['business_name'],
            room_id: appointment['business_room_id'],
            longitude: appointment['business_longitude'],
            latitude: appointment['business_latitude'],
            phone: appointment['business_phone'],
            profile_image: appointment['business_profile_image'] ?? '',
            address: appointment['business_address'],
            description: appointment['business_description'],
            type_id: appointment['business_type_id'],
            // max_contemporary_appointments: e['max_contemporary_appointments'],
            // category: Category(
            //   id: e['category_id'],
            //   image: e['category_image'],
            //   name: e['category_name'],
            // )
          );
          // print('myAppointments.length');
          // print(myAppointments.length);
          // print('myAppointments.first');
          // print(myAppointments.first.id.toString());
          // socketAppointments.add(appointment);
          // myAppointments.add(appointment);
          myAppointments.add(
              Booking(
                id: appointment['booking_id'],
                isCanceled: appointment['is_canceled'],
                is_guest: 0,
                // note: myAppointments[index]['note'],
                // user_id: myAppointments[index]['user_id'].toString(),
                prestazione: Prestazione(
                  duration: appointment['prestazione_duration'],
                  id: appointment['prestazione_id'],
                  image: appointment['prestazione_image'],
                  is_price_range: (appointment['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                  price: appointment['prestazione_price']?.toDouble(),
                  price_min: appointment['prestazione_price_min']?.toDouble(),
                  price_max: appointment['prestazione_price_max']?.toDouble(),
                  title: appointment['prestazione_title'],
                  description: appointment['prestazione_description'],
                  business_id: appointment['business_id'],
                  business: business00
                ),
                user: User(
                  id: appointment['user_id'],
                  email: appointment['user_email'],
                  username: appointment['user_username'],
                  name: appointment['user_name'],
                  phone: appointment['user_phone'],
                  profile_image: appointment['user_profile_image'],
                  // description: appointments[i]['user_description'],
                ),
                begin_at: DateTime.tryParse(appointment['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                end_at: DateTime.tryParse(appointment['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: appointment['prestazione_duration']?.toInt()))/*.toLocal()*/,
                created_at: DateTime.tryParse(appointment['created_at'])/*!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
              )
          );
          // myAppointments.sort((b, a) => a['created_at'].compareTo(b['created_at']));
          myAppointments.sort((b, a) => a.created_at!.compareTo(b.created_at!));
          // print('myAppointments.length');
          // print(myAppointments.length);
          // print('myAppointments.first');
          // print(myAppointments.first/*['created_at']*/.id.toString());

          // print('myAppointments.length');
          // print(myAppointments.length);
          // print('myAppointments.first');
          // print(myAppointments.first/*['created_at']*/.toString());

          getBusinessFrequencyReservationPerDay(
              business00,
              context
          );

          Map<String, dynamic> values = {
            "booking_id": appointment['booking_id'],
            'booking_price': appointment['prestazione_price'],
            "booking_begin_at": DateTime.tryParse(appointment['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
            // "booking_begin_at": appointment['begin_at']/*.toLocal()*//*.add(const Duration(hours: 2))*/.toString(),
            "prestazione_id": appointment['prestazione_id'],
            'prestazione_image': appointment['prestazione_image'] != null && appointment['prestazione_image'] != '' ? appointment['prestazione_image'] : appointment['business_profile_image'] ?? '',
            'prestazione_title': appointment['prestazione_title'],
            'is_canceled': 0,
            'user_id': appointment['user_id'],
            'user_username': appointment['user_username'],
            'user_profile_image': appointment['user_profile_image'],
            'user_name': appointment['user_name'],
            'business_id': appointment['business_id'],
            'business_name': appointment['business_name'],
            'sent_at': DateTime.now().toString(),
          };

          await insertLocalNotification(
              'appointment_notification',
              values
          );

          if(BusinessPreferences.getEnableNotifications()! && !BusinessPreferences.getBackgroundNotifications()!){
            //todo: serve??
            showNotification(title: 'title', body: 'body');
            /*instantNotification(
              beginAt: appointment['begin_at'],
              note: appointment['note'],
              username: appointment['username'],
              name: appointment['name'] ?? appointment['first_name'],
              prestazioneTitle: appointment['prestazione_title'],
              imagePrestazione: appointment['prestazione_image'],
              imageProfile: appointment['profile_image'],
            );*/
          }

          // audioPlayer.setVolume(1);
          if(BusinessPreferences.getEnableNotifications()!
            && !BusinessPreferences.getBackgroundNotifications()!
            && !BusinessPreferences.getSilentNotifications()!) {
            // player.play();
          }
          // imageNotification();
          // stylishNotification();
          // receivedSocket = true;
          notifyListeners();
        },
      );

      notifyListeners();
    });

    socket.connect();

    return socket;
  }

  setIsCanceledAppointment(String appointmentId) async {
    for(var e in myAppointments){
      // if(e.id == appointment['appointment_id']){
      if(e.id == appointmentId){
        // print('ortsoalllaa');
        e.isCanceled = 1;
        notifyListeners();
      }
    }

    notifyListeners();
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /*Future instantNotification({
    required String beginAt,
    String? prestazioneTitle,
    String? username,
    String? note,
    String? name,
    required String imageProfile,
    required String imagePrestazione,
  }) async {
    await BusinessPreferences.init();
    final Int64List vibrationPattern = Int64List(2);

    if(BusinessPreferences.getSilentNotifications() == false
        && BusinessPreferences.getEnableNotifications() == true
      && BusinessPreferences.getBackgroundNotifications() == false) {
      player.play();
    }

    print("BusinessPreferences.getVibrateNotifications() && BusinessPreferences.getEnableNotifications()");
    print(BusinessPreferences.getVibrateNotifications()! && BusinessPreferences.getEnableNotifications()!);

    if(BusinessPreferences.getVibrateNotifications() == true
        && BusinessPreferences.getEnableNotifications() == true) {
      vibrationPattern[0] = 0;
      vibrationPattern[1] = 2000;
    }
    // vibrationPattern[2] = 10000;
    // vibrationPattern[3] = 5000;

    final String largeIconPath = await _downloadAndSaveFile(
        // 'https://via.placeholder.com/48x48',
        imageProfile,
        'largeIcon'
    );
    final String bigPicturePath = await _downloadAndSaveFile(
        // 'https://via.placeholder.com/400x800',
      imagePrestazione,
      'bigPicture'
    );
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        largeIcon: FilePathAndroidBitmap(bigPicturePath),
        contentTitle: '$prestazioneTitle',
        htmlFormatContentTitle: true,
        summaryText: "<p>@$username</p>",
        htmlFormatSummaryText: true
    );

    // final sound = 'slow_spring_board_longer_tail_571.ogg';
    final sound = 'piece_of_cake_611.mp3';
    var android = AndroidNotificationDetails(
        'fcm_nurebo_admin_channel',
        'fcm_nurebo_admin_channel',
        // 'channelDescription',
        // playSound: true,
        playSound: false,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: false,
        // enableVibration: BusinessPreferences.getVibrateNotifications() == true && BusinessPreferences.getEnableNotifications() == true ? true : false,
        enableLights: true,
        channelShowBadge: true,
        // tag: 'Taggatolo',
        subText: "Prenotazione",
        fullScreenIntent: false,
        // groupKey: '1',
        // groupAlertBehavior: GroupAlertBehavior.children,
        // setAsGroupSummary: true,
        icon: 'calendar',
        // largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
        // largeIcon: const DrawableResourceAndroidBitmap('calendar'),
        // largeIcon: FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        ledOffMs: 300,
        ledOnMs: 300,
        ledColor: Colors.blue,
        // onlyAlertOnce: true,

        // styleInformation: MediaStyleInformation(
        //   htmlFormatContent: true,
        //   htmlFormatTitle: false,
        // ),
        // styleInformation: bigPictureStyleInformation,
        // vibrationPattern: Int64List(20000),//vibrazione non va
        vibrationPattern: vibrationPattern,
        visibility: NotificationVisibility.public,
        sound: RawResourceAndroidNotificationSound(sound.split('.').first)
    );

    var ios = IOSNotificationDetails(
      sound: sound,
      // presentSound: true,
      presentSound: false,
    );

    var platform = new NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.show(
        // 0,
        Random().nextInt(88887),
        prestazioneTitle,
        // '@' + username,
        // beginAt,
        DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(beginAt)).toString()
        + ' alle ' + beginAt.substring(11, 16),
        // 'erf',
        platform,
        payload: 'This is a demo app'
    );
  }*/

  Future query(String table, {String? where, List? whereArgs, String? orderBy}) async {
    var ff = await SqfliteDB.instance.query(
        table, where: where, whereArgs: whereArgs, orderBy: orderBy
    );
    notifyListeners();
    return ff;
  }

  Future getLocalNotifications(Business business) async {
    List localNotificationList = await (query(
      'appointment_notification',
      orderBy: 'sent_at DESC',
      where: 'business_id = ?',
      whereArgs: [business.id]
    ));
    // print(localNotificationList);
    notificationList = localNotificationList;

    notificationList.sort((b, a) {
      // return a.sent_at.compareTo(b.sent_at);
      // return a['created_at'].compareTo(b['created_at']);
      return DateTime.tryParse(a['sent_at'])!.compareTo(DateTime.tryParse(b['sent_at'])!);
    });
    notifyListeners();
  }

  Future deleteLocalNotification(String table, String id, int index) async {
    // print('notification list length 0');
    // print(notificationList.length);
    // List result = await SqfliteDB.instance.query(
    //   table,
    //   // orderBy: 'time DESC',
    // );
    // print('idoosssssssss');
    // print(id);
    // print(result);

    // var result = await SqfliteDB.instance.delete(
    //   table,
    //   where: "booking_id = ?",
    //   whereArgs: [bookingId],
    // );
    var result = await SqfliteDB.instance.delete(
      table,
      where: "id = ?",
      whereArgs: [id],
    );

    // print('result delete notification');
    // print(result);

    notificationList.removeAt(index);

    // notificationList.sort((b, a) {
    //   return DateTime.tryParse(a['sent_at']).compareTo(DateTime.tryParse(b['sent_at']));
    // });

    // print('notification list length 1');
    // print(notificationList.length);

    notifyListeners();
  }

  Future insertLocalNotification(String table, Map values) async {
    var result = await SqfliteDB.instance.insert(table, values);

    // print('result insert notification');
    // print(result);

    // if(result == 1){
    // if(result > 0){
    notificationList.add(values);
    // bookingNotificationList.insert(bookingNotificationList.length, values);

    // if(values['is_cancel'] == 1){
    //   showNotification(
    //     subText: 'Cancellazione',
    //     body: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(values['booking_begin_at'])).toString()
    //         + ' alle ' + values['booking_begin_at'].substring(11, 16),
    //     title: values['prestazione_title'],
    //     largeIconPath: values['prestazione_image'],
    //   );
    // }

    //order
    notificationList.sort((b, a) {
      // return a.sent_at.compareTo(b.sent_at);
      return DateTime.tryParse(a['sent_at'])!.compareTo(DateTime.tryParse(b['sent_at'])!);
    });

    // print('notification list length');
    // print(notificationList.length);
    // }

    notifyListeners();
  }

  Future getUnseenLocalNotifications(Business business, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // var url = Uri.parse(Utils.httpServerUrl + "user_business_notification/business_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/notification/booking");

    Map<String, dynamic> body = {
      'business_id': business.id,
    };

    // var response = await http.get(
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

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    else if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //inserirli nel db locale
      // print('jsonData business user notification');
      // print(jsonData);

      for(var e in jsonData){
        //todo: in tabella booking notification ci dovrebbe essere tutto quello che
        // serve per passare a booking screen o business screen

        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        // booking_id VARCHAR(36),
        // booking_price DOUBLE,
        // booking_begin_at TEXT,
        // is_canceled INTEGER,
        // user_id VARCHAR(36) NOT NULL,
        // business_id VARCHAR(36) NOT NULL,
        // business_name TEXT,
        // prestazione_id VARCHAR(36) NOT NULL,
        // prestazione_title TEXT,
        // prestazione_image TEXT,
        // created_at TEXT

        Map<String, dynamic> values = {
          // 'id': 'rem',
          'booking_id': e['booking_id'],
          'booking_begin_at': DateTime.tryParse(e['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
          'prestazione_id': e['prestazione_id'],
          'user_id': e['user_id'],
          // 'sender_username': e['username'],
          // 'sender_name': e['user_name'],
          'is_canceled': int.tryParse(e['type']) == 0 ? 0 : 1,
          'business_id': e['business_id'],
          'business_name': e['business_name'],
          'user_name': e['user_name'],
          'user_username': e['user_username'],
          'prestazione_title': e['prestazione_title'],
          'prestazione_image': e['prestazione_image'] != null && e['prestazione_image'] != '' ? e['prestazione_image'] :/*??*/ e['business_profile_image'] ?? '',
          'booking_price': e['prestazione_price'],
          'sent_at': DateTime.tryParse(e['sent_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString(),
          'user_profile_image': e['user_profile_image'] ?? '',
        };

        //todo: da attivare se si vogliono mostrare le notifiche all'avvio dell'app
        // showNotification(
        //   subText: int.tryParse(e['type']) == 1 ? 'Cancellazione' : 'Prenotazione',
        //   body: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(values['booking_begin_at'])).toString()
        //       + ' alle ' + values['booking_begin_at'].substring(11, 16),
        //   title: values['prestazione_title'],
        //   largeIconPath: values['prestazione_image'],
        // );

        await insertLocalNotification(
            'appointment_notification',
            values
        );

        // Map<String, dynamic> values1 = {
        //   // 'id': 'rem',
        //   'booking_id': e['booking_id'],
        //   'prestazione_id': e['prestazione_id'],
        //   'sender_id': e['sender_id'],
        //   'sender_username': e['username'],
        //   'sender_name': e['user_name'],
        //   'business_name': e['business_name'],
        //   'prestazione_title': e['prestazione_title'],
        //   'prestazione_image': e['prestazione_image'],
        //   'price': e['prestazione_price'],
        //   'sent_at': e['sent_at'],
        // };
        // await insertNotification(
        //   'booking_notification',
        //   values1
        // );

        notificationList.sort((b, a) {
          // return a.sent_at.compareTo(b.sent_at);
          // return a['created_at'].compareTo(b['created_at']);
          return DateTime.tryParse(a['sent_at'])!.compareTo(DateTime.tryParse(b['sent_at'])!);
        });
        notifyListeners();
      }
      notifyListeners();
      return jsonData;
    }
  }

//   //Image notification
//   Future imageNotification() async {
//     var bigPicture = BigPictureStyleInformation(
//         DrawableResourceAndroidBitmap("ic_launcher"),
//         largeIcon: DrawableResourceAndroidBitmap("ic_launcher"),
//         contentTitle: "Demo image notification",
//         summaryText: "This is some text",
//         htmlFormatContent: true,
//         htmlFormatContentTitle: true
//     );
//
//     var android = AndroidNotificationDetails(
//         "id",
//         "channel",
//         // "description",
//         styleInformation: bigPicture);
//
//     var platform = new NotificationDetails(android: android);
//
//     await _flutterLocalNotificationsPlugin.show(
//         0, "Demo Image notification", "Tap to do something", platform,
//         payload: "Welcome to demo app");
//   }
//
//   //Stylish Notification
//   Future stylishNotification() async {
//     var android = AndroidNotificationDetails(
//         "id",
//         "channel",
//         // "description",
//         color: Colors.deepblue,
//         enableLights: true,
//         enableVibration: true,
//         largeIcon: DrawableResourceAndroidBitmap("ic_launcher"),
//         styleInformation: MediaStyleInformation(
//             htmlFormatContent: true, htmlFormatTitle: true));
//
//     var platform = new NotificationDetails(android: android);
//
//     await _flutterLocalNotificationsPlugin.show(
//         0, "Demo Stylish notification", "Tap to do something", platform);
//   }
//
//   //Sheduled Notification
//
//   Future scheduledNotification() async {
//     var interval = RepeatInterval.everyMinute;
//     var bigPicture = BigPictureStyleInformation(
//         DrawableResourceAndroidBitmap("ic_launcher"),
//         largeIcon: DrawableResourceAndroidBitmap("ic_launcher"),
//         contentTitle: "Demo image notification",
//         summaryText: "This is some text",
//         htmlFormatContent: true,
//         htmlFormatContentTitle: true);
//
//     var android = AndroidNotificationDetails(
//         "id",
//         "channel",
//         // "description",
//         styleInformation: bigPicture
//     );
//
//     var platform = new NotificationDetails(android: android);
//
//     await _flutterLocalNotificationsPlugin.periodicallyShow(
//         0,
//         "Demo Sheduled notification",
//         "Tap to do something",
//         interval,
//         platform);
//   }
//
//   //Cancel notification
//
//   Future cancelNotification() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

/*Future<void> showNotification({
  // String senderUsername,
  String? body,
  String? senderUsername,
  String? senderName,
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String prestazioneImage = 'https://via.placeholder.com/48x48',
  String? text,
  String? title,
  String senderId = '0',
  String subText = '',
}) async {
  await BusinessPreferences.init();
  final player = AudioPlayer();
  var sound;

  if(subText == 'Cancellazione'){
    sound = 'my_work_is_done_message_tone.ogg';
    await player.setAsset('assets/audio/my_work_is_done_message_tone.ogg');
  }
  else {
    sound = 'piece_of_cake_611.mp3';
    await player.setAsset('assets/audio/piece-of-cake-611.ogg');
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
  final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS
  );

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: null
  );

  final Int64List vibrationPattern = Int64List(2);

  if(BusinessPreferences.getSilentNotifications() == false
      && BusinessPreferences.getEnableNotifications() == true) {
    // audioPlayer.play();
    player.play();
  }


  if(BusinessPreferences.getVibrateNotifications() == true
      && BusinessPreferences.getEnableNotifications() == true){
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 2000;
  }

  // final String bigPicturePath = await _downloadAndSaveFile(
  //   // 'https://via.placeholder.com/400x800',
  //     prestazioneImage,
  //     'bigPicture'
  // );
  // final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
  //     FilePathAndroidBitmap(largeIconPath),
  //     largeIcon: FilePathAndroidBitmap(bigPicturePath),
  //     contentTitle: '$prestazioneTitle',
  //     htmlFormatContentTitle: true,
  //     summaryText: "<p>@$username</p>",
  //     htmlFormatSummaryText: true
  // );

  final String largeIcon = await _downloadAndSaveFile(
    // 'https://via.placeholder.com/48x48',
    //   imageProfile,
      largeIconPath,
      'largeIcon'
  );

  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'fcm_nurebo_admin_channel', 'fcm_nurebo_admin_channel', //'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: BusinessPreferences.getSilentNotifications() == true ? true : false,
    // sound: RawResourceAndroidNotificationSound(sound.split('.').first),
    ticker: 'ticker',
    subText: subText,
    icon: 'calendar',
    largeIcon: FilePathAndroidBitmap(largeIcon),

    ledOffMs: 300,
    ledOnMs: 300,
    ledColor: Colors.blue,

    // fullScreenIntent: false,
    // groupKey: '1',
    // groupAlertBehavior: GroupAlertBehavior.children,
    // setAsGroupSummary: true,
    // enableVibration: BusinessPreferences.getVibrateNotifications() == true && BusinessPreferences.getEnableNotifications() == true ? true : false,
    enableVibration: false,
    enableLights: true,
    channelShowBadge: true,
    // tag: 'Taggatolo',
    // styleInformation: MediaStyleInformation(
    //   htmlFormatContent: true,
    //   htmlFormatTitle: false,
    // ),
    // styleInformation: bigPictureStyleInformation,
    styleInformation: MediaStyleInformation(
      htmlFormatContent: true,
      htmlFormatTitle: true
    ),
    // vibrationPattern: Int64List(20000),//vibrazione non va
    vibrationPattern: vibrationPattern,
    visibility: NotificationVisibility.public,
  );

  var ios = IOSNotificationDetails(
    sound: sound,
    presentSound: true,
    // presentSound: false,
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: ios
  );

  // await audioPlayer.setVolume(1.0);
  // await audioPlayer.play();

  await flutterLocalNotificationsPlugin.show(
    // 0,
      Random().nextInt(88887),
      title,
      // '@' + username,
      // beginAt,
      body,
      platformChannelSpecifics,
      payload: 'This is a demo app'
  );
}*/
