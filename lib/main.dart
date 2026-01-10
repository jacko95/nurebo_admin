import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/campaign_provider.dart';
import 'package:nurebo_admin/provider/download_provider.dart';
import 'package:nurebo_admin/provider/event_provider.dart';
import 'package:nurebo_admin/provider/geolocation_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/notification_provider.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/provider/vetrina_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/booking_screen.dart';
import 'package:nurebo_admin/screens/home_screen1.dart';
import 'package:nurebo_admin/screens/login_screen.dart';
import 'package:nurebo_admin/screens/news_screen.dart';
import 'package:nurebo_admin/screens/server_down_screen.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/services/telephony/telephony.dart';
import 'package:nurebo_admin/utils/fcm_notification_helper.dart';
import 'package:nurebo_admin/utils/notification_helper.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:nurebo_admin/widgets/navigation_drawer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/get.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'dart:developer' as dev;


// final player = AudioPlayer();
final StreamController/*<String>*/ streamController = StreamController.broadcast();
final Stream/*<String>*/ broadcastStream = streamController.stream.asBroadcastStream();
String? deviceToken;
final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final RouteObserver<ModalRoute<dynamic>> routeObserver = RouteObserver<ModalRoute<dynamic>>();

// late PackageInfo packageInfo;
bool isServerDown = false;


@pragma('vm:entry-point')
Future getBusiness(/*String businessId*/) async {
  await BusinessPreferences.init();
  // var url = Uri.parse("${Utils.httpServerUrl}business");
  var url = Uri.parse("${Utils.httpServerUrl}business/${BusinessPreferences.getBusinessId()}/is_visible");

  // Map/*<String, String>*/ body = {
  //   'business_id': businessId,
  // };
  Map<String, String?> body = {
    'business_id': BusinessPreferences.getBusinessId(),
  };

  // print('BusinessPreferences.getUserToken()');
  // print(BusinessPreferences.getUserToken());

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
  ).timeout(
    const Duration(seconds: 5),
    // onTimeout: (){
    //   Navigator.pushReplacement(
    //       context,
    //       PageTransition(
    //         duration: const Duration(milliseconds: 200),
    //         type: PageTransitionType.fade,
    //         child: LoginScreen(),
    //       )
    //   );
    // }
  );

  print('response.statusCodeff5g5g5');
  print(response.statusCode);
  // if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
  //   // if (!mounted) return;
  //   await businessProvider.logout(context);
  // }
  if(response.statusCode >= 520 && response.statusCode <= 530) {
    isServerDown = true;
  }
  if(response.statusCode >= 200 && response.statusCode < 400) {
    var jsonData = json.decode(response.body);

    Business? business;
    try{
      business = Business(
          id: jsonData[0]['business_id'],
          description: jsonData[0]['business_description'],
          name: jsonData[0]['business_name'],
          email: jsonData[0]['business_email'],
          room_id: jsonData[0]['business_room_id'],
          email_notification: jsonData[0]['business_email_notification'],
          max_contemporary_appointments: jsonData[0]['max_contemporary_appointments'],
          address: jsonData[0]['business_address'],
          address_number: jsonData[0]['business_address_number'],
          postal_code: jsonData[0]['business_postal_code'],
          province: jsonData[0]['business_province'],
          city: jsonData[0]['business_city'],
          region: jsonData[0]['business_region'],
          phone: jsonData[0]['business_phone'],
          // is_booking_business: jsonData[0]['is_booking_business'],
          profile_image: jsonData[0]['business_profile_image'] ?? '',
          type_id: jsonData[0]['business_type_id'],
          latitude: jsonData[0]['business_latitude'],
          longitude: jsonData[0]['business_longitude'],
          category: Category(
            id: jsonData[0]['category_id'],
            image: jsonData[0]['category_image'],
            name: jsonData[0]['category_name'],
          )
      );
    } catch (e) {
      print(e);
    };

    return business;
  }
}

// Future/*<Socket*//*void*//*>*/ socketConnect(/*String businessId*/) async {
//   await BusinessPreferences.init();
//   // AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
//   await initializeDateFormatting();
//
//   SocketProvider socketProvider = SocketProvider();
//
//   Socket socket = IO.io(
//       Utils.httpServerUrl,
//       IO.OptionBuilder()
//           .setTransports(["websocket", "polling"])
//           .enableForceNewConnection()
//       // .disableForceNewConnection()
//       // .enableAutoConnect()
//           .disableAutoConnect()
//           .enableReconnection()
//       // .disableReconnection()
//           .enableForceNew()
//       // .disableForceNew()
//           .enableMultiplex()
//       // .disableMultiplex()
//           .build()
//   );
//
//   // Socket socket = IO.io(Utils.httpServerUrl, <String, dynamic>{
//   //   "transports": ["websocket", "polling"],
//   //   "autoConnect": false,
//   //   "forceNew": true,
//   //   "reconnect": true
//   // });
//
//   // print('socket.connected1');
//   // print(socket.connected);
//   // if(!socket.connected) {
//     socket.connect();
//   // }
//   // print('socket.connected2');
//   // print(socket.connected);
//   // print('socket.id');
//   // print(socket.id);
//   // print('socket.ids');
//   // print(socket.ids);
//   // print('socket.opts');
//   // print(socket.opts);
//   // print('socket.flags');
//   // print(socket.flags);
//   // print('socket.connected');
//   // print(socket.connected);
//
//   /*await*/ socket.onConnect((data) /*async*/ {
//     // Utils.connectedSockets++;
//     // if(Utils.connectedSockets > 1){
//     //   socket.dispose();
//     //   Utils.connectedSockets--;
//     // }
//     // print('Utils.connectedSockets');
//     // print(Utils.connectedSockets.toString());
//     // print('socket.id background');
//     // print(socket.id);
//     // print('socket.id');
//     // print(socket.id);
//     // print('socket.ids');
//     // print(socket.ids);
//     // print('socket.opts');
//     // print(socket.opts);
//     // print('socket.flags');
//     // print(socket.flags);
//     // print('socket.connected');
//     // print(socket.connected);
//     // print('data');
//     // print(data);
//
//     /*await*/ socket.onReconnectFailed((data) {
//       // print('onReconnectFailed');
//     });
//
//     /*await*/ socket.onConnectError((data) {
//       // print('onConnectError');
//     });
//
//     /*await*/ socket.onConnectTimeout((data) {
//       // print('onConnectTimeout');
//     });
//
//     /*await*/ socket.onReconnectAttempt((data) {
//       // print('onReconnectAttempt');
//     });
//
//     /*await*/ socket.onReconnectError((data) {
//       // print('onReconnectError');
//     });
//
//     /*await*/ socket.onReconnect((data) {
//       // print('onReconnect');
//     });
//
//     /*await*/ socket.onConnecting((data) {
//       // print('onConnecting');
//     });
//
//     /*await*/ socket.onReconnecting((data) {
//       // print('onReconnecting');
//     });
//
//     /*await*/ socket.onError((data) {
//       // print('onError');
//     });
//
//     /*await*/ socket.onDisconnect((data) {
//       // socket.destroy();
//       // socket.disconnect();
//       // socket.close();
//       // socket.dispose();
//       // print('onDisconnect');
//     });
//
//     socket.emit(
//         "join_booking_business_appointments",
//         {
//           'id': BusinessPreferences.getBusinessId(),
//           'type': 'background'
//         }
//     );
//
//     socket.on('broad', (data) async {
//       // print(data.toString());
//       socket.ack('arribatolooss');
//       if(BusinessPreferences.getEnableNotifications() == true){
//         await showNotification(title: 'm1', body: 'w1');
//         // if(BusinessPreferences.getSilentNotifications() == false){
//         //   await audioPlayer.setVolume(1.0);
//         //   await audioPlayer.play();
//         // }
//       }
//
//     });
//
//     socket.on(
//       "cancel_business_appointment_notification",
//       (appointment) async {
//         // print('appointment in background');
//         // print(appointment);
//
//         streamController.sink.add(appointment);
//
//         // Map<String, dynamic> values = {
//         //   "booking_id": appointment['booking_id'],
//         //   'booking_price': appointment['prestazione_price'],
//         //   "booking_begin_at": appointment['begin_at'].toString(),
//         //   "prestazione_id": appointment['prestazione_id'],
//         //   'prestazione_image': appointment['prestazione_image'] != null && appointment['prestazione_image'] != '' ? appointment['prestazione_image'] : appointmente['business_profile_image'] ?? '',
//         //   'prestazione_title': appointment['prestazione_title'],
//         //   'is_canceled': 1,
//         //   'user_id': appointment['user_id'],
//         //   'user_username': appointment['user_username'],
//         //   'user_profile_image': appointment['user_profile_image'],
//         //   'user_name': appointment['user_name'],
//         //   'business_id': appointment['business_id'],
//         //   'business_name': appointment['business_name'],
//         //   'sent_at': DateTime.now().toString(),
//         // };
//         //
//         // await insertLocalNotification(
//         //     'appointment_notification',
//         //     values
//         // );
//
//         // if(BusinessPreferences.getEnableNotifications() == true){
//         // await _showNotification(
//         await showNotification(
//           // text: 'tiesto',
//           // senderUsername: 'meeee',
//           subText: 'Cancellazione',
//           // subText: '@' + appointment['username'],
//           body: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(appointment['begin_at'])!/*.tolocal()*/).toString()
//               + ' alle ' + DateTime.tryParse(appointment['begin_at'])/*.tolocal()*/.toString().substring(11, 16),
//           // note: appointment['note'],
//           // senderUsername: appointment['username'],
//           // senderName: appointment['name'] ?? '',
//           title: appointment['prestazione_title'],
//           // prestazioneImage: appointment['prestazione_image'],
//           largeIconPath: appointment['user_profile_image'],
//         );
//       },
//     );
//
//     socket.on(
//       "update_booking_business_appointments",
//       (appointment) async {
//
//         // print('appointment');
//         // print(appointment);
//
//         // print('socket.id background');
//         // print(socket.id);
//
//         streamController.sink.add(appointment);
//
//         // socketAppointments.add(appointment);
//         // instantNotification(
//         //   beginAt: appointment['begin_at'],
//         //   note: appointment['note'],
//         //   username: appointment['username'],
//         //   name: appointment['name'] ?? appointment['first_name'],
//         //   prestazioneTitle: appointment['title'],
//         //   imagePrestazione: appointment['prestazione_image'],
//         //   imageProfile: appointment['profile_image'],
//         // );
//         // if(BusinessPreferences.getEnableNotifications() == true){
//         // await _showNotification(
//         await showNotification(
//           // text: 'tiesto',
//           // senderUsername: 'meeee',
//           subText: 'Prenotazione',
//           // subText: '@' + appointment['username'],
//           body: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(appointment['begin_at'])!/*.tolocal()*/).toString()
//               + ' alle ' + DateTime.tryParse(appointment['begin_at'])!/*.tolocal()*/.toString().substring(11, 16),
//           // note: appointment['note'],
//           // senderUsername: appointment['username'],
//           // senderName: appointment['name'] ?? '',
//           title: appointment['prestazione_title'],
//           // prestazioneImage: appointment['prestazione_image'],
//           largeIconPath: appointment['prestazione_image'],
//           // largeIconPath: appointment['user_profile_image'],
//         );
//         // if(BusinessPreferences.getSilentNotifications() == false){
//         //   await audioPlayer.setVolume(1.0);
//         //   await audioPlayer.play();
//         // }
//         // }
//
//         // imageNotification();
//         // stylishNotification();
//         // receivedSocket = true;
//         // notifyListeners();
//       },
//     );
//   });
//
//   // print('socket.id ytytr');
//   // print(socket.id);
//   // return socket.id;
// }

Future getIpLocation(String? ip) async {
  var url = Uri.parse("http://ip-api.com/json/$ip");

  var response = await http.get(
      url,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
      }
  );

  if(response.statusCode >= 200 && response.statusCode < 400) {
    var jsonData = json.decode(response.body);
    //print("iplocation: ");
    //print(jsonData);
    return jsonData;
  }
}

// Future getIp() async {
//   var url = Uri.parse("https://api.ipify.org?format=json");
//
//   var response = await http.get(
//       url,
//       headers: {
//         'Accept': '*/*',
//         'Content-Type': 'application/json',
//         'Accept-encoding': 'gzip, deflate',
//         'connection': 'keep-alive',
//       }
//   );
//
//   // //print("response.statusCode");
//   // //print(response.statusCode);
//   if(response.statusCode >= 200 && response.statusCode < 400) {
//     var jsonData = json.decode(response.body);
//     var ipLocation = await getIpLocation(jsonData['ip']);
//     //print('ip location:');
//     //print(ipLocation);
//     // return jsonData;
//     return ipLocation;
//   }
// }
Future getIp() async {
  var url = Uri.parse("https://api.ipify.org?format=json");

  try {
    var response = await http.get(
      url,
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'connection': 'keep-alive',
      },
    ).timeout(Duration(seconds: 5)); // Imposta il timeout a 5 secondi

    if (response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      var ipLocation = await getIpLocation(jsonData['ip']);
      return ipLocation;
    }
    else {
      // Gestisci il caso in cui la richiesta non abbia avuto successo
      print("Errore: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    // Gestisci il caso in cui la richiesta abbia superato il timeout o abbia fallito
    print("Errore: $e");
    return null;
  }
}

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await BusinessPreferences.init();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will executed when app is in foreground or background in separated isolate
//       onStart: onStart,
//       // onStart: start,
//
//       // auto start service
//       // autoStart: true,
//       autoStart: false,
//       // autoStart: BusinessPreferences.getIsLogged() == true && BusinessPreferences.getBusinessId() != null && BusinessPreferences.getEnableNotifications() && BusinessPreferences.getBackgroundNotifications(),
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       // autoStart: true,
//       autoStart: false,
//       // autoStart: BusinessPreferences.getIsLogged() == true && BusinessPreferences.getBusinessId() != null && BusinessPreferences.getEnableNotifications() && BusinessPreferences.getBackgroundNotifications(),
//
//       // this will executed when app is in foreground in separated isolate
//       onForeground: onStart,
//       // onForeground: start,
//
//       // you have to enable background fetch capability on xcode project
//       onBackground: onIosBackground,
//     ),
//   );
// }

// // to ensure this executed
// // run app from xcode, then from xcode menu, select Simulate Background Fetch
// // void onIosBackground() {
// bool onIosBackground(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   print('FLUTTER BACKGROUND FETCH');
//
//   return true;
// }

// // Future<void> onStart() async {
// void onStart(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();
//
//   Business business = await getBusiness();
//
//   // final service = FlutterBackgroundService();
//
//   // service.onDataReceived.listen((event) {
//   //   if (event/*!*/["action"] == "setAsForeground") {
//   //     service.setForegroundMode(true);
//   //     return;
//   //   }
//   //
//   //   if (event["action"] == "setAsBackground") {
//   //     service.setForegroundMode(false);
//   //   }
//   //
//   //   if (event["action"] == "stopService") {
//   //     service.stopBackgroundService();
//   //   }
//   // });
//   if (service is AndroidServiceInstance) {
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
//   // // bring to foreground
//   // service.setForegroundMode(true);
//
//   // service.setNotificationInfo(
//   //   // title: "My App Service",
//   //   title: "Estetica Elixir",
//   //   // content: "Upbookingd at ${DateTime.now()}",
//   //   content: "Notifiche Attive",
//   // );
//   if (service is AndroidServiceInstance) {
//     service.setForegroundNotificationInfo(
//       // title: "Estetica Elixir",
//       title: business.name,
//       content: business.email
//       // content: "Notifiche Attive",
//     );
//   }
//
//   //
//   //   service.sendData(
//   //     {"current_booking": DateTime.now().toIso8601String()},
//   //   );
//   // });
//   // await start();
//
//   // print((await socketConnect()).id + 'back connectied');
//   // Socket socket2 = await socketConnect();
//   /*var socketBGId = */await socketConnect();
//   // print('socketBGId');
//   // print(socketBGId);
// }

// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  // print(message);
  // print(message.data.toString());
  // print(message.notification!.title);
  dev.log(
    'message.data58920@@8',
    name: 'my.app.category',
    error: jsonEncode(message.data),
  );
}

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  //Handle background message
  Vibration.vibrate();
}

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // HttpOverrides.global = MyHttpOverrides();

  // ByteData byteData = await rootBundle.load('assets/certificates/fullchain.pem');
  ByteData byteData = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(byteData.buffer.asUint8List());
  // assert();

  // await initializeService();

  FCMNotificationHelper.registerNotification();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // /*String*/ deviceToken = await FirebaseMessaging.instance.getToken();
  // print('deviceToken');
  // print(deviceToken);
  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // await FirebaseMessaging.instance.requestPermission(
  //   alert: true,
  //   announcement: true,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  Business? business;

  // Constants.version_id;
  //prendere tutte le versioni o solo l'ultima con order by id in nodejs
  //con limit 1 e vedere se è maggiore di Constants.version_id.
  //se si mostrare il dialog per scaricare l apk con flutter_download
  //e aprirlo con open_file
  //altrimenti non mostrare niente

  await BusinessPreferences.init();

  // Future getBusiness() async {
  //   var url = Uri.parse(Constants.httpServerUrl + "business");
  //
  //   Map/*<String, String>*/ body = {
  //     'id': BusinessPreferences.getBusiness(),
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
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // print('jsonData???????????');
  //     // print(jsonData);
  //     // print(jsonData[0]['id']);
  //
  //     // setState(() {
  //     //   // user.id = int.tryParse(jsonData[0]['id']);
  //     //   user.id = jsonData[0]['id'].toInt();
  //     //   user.description = jsonData[0]['description'];
  //     //   user.profile_image = jsonData[0]['profile_image'];
  //     //   user.first_name = jsonData[0]['first_name'];
  //     //   user.name = jsonData[0]['name'];
  //     //   user.username = jsonData[0]['username'];
  //     //   user.phone_number = jsonData[0]['phone_number'];
  //     //   user.email = jsonData[0]['email'];
  //     // });
  //
  //     // setState(() {
  //     business = new Business(
  //       id: jsonData[0]['id'],
  //       description: jsonData[0]['description'],
  //       name: jsonData[0]['name'],
  //       email: jsonData[0]['email'],
  //       max_contemporary_appointments: jsonData[0]['max_contemporary_appointments'],
  //       address: jsonData[0]['address'],
  //       phone_number: jsonData[0]['phone_number'],
  //       is_booking_business: jsonData[0]['is_booking_business'],
  //       profile_image: jsonData[0]['profile_image'],
  //     );
  //     // });
  //
  //     return jsonData;
  //   }
  // }

  try {
    business = await (getBusiness());
    // } catch (e) {
  } on TimeoutException catch (e) {
    print('un dio che prima dd5dd5d5d5 un cane');
    print(e);
    // if(BusinessPreferences.getIsLogged()!){
      isServerDown = true;
    // }
  }

  // print('BusinessPreferences.getIsLogged()');
  // print(BusinessPreferences.getIsLogged().toString());

  // ConnectivityResult connectivityResult = await connectivity.checkConnectivity();
  // if(BusinessPreferences.getIsLogged() == true && connectivityResult != ConnectivityResult.none)
  //   await getBusiness();

  runApp(
      /*Phoenix(
        child:*/ MultiProvider(
          providers: [
            StreamProvider(
              // child: MyApp(),
              create: (_) => streamController.stream, initialData: 'null',
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => PrestazioneProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => BookingProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => CampaignProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => EventProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => SocketProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => NotificationProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => PostProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => VetrinaProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => GeolocationProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => DownloadProvider(),
            ),
            ChangeNotifierProvider(
              // child: MyApp(),
              create: (_) => BusinessProvider(),
            ),
          ],
          child: const NureboAdmin()
        ),
      // )
  );

  // packageInfo = await PackageInfo.fromPlatform();
  // String appName = packageInfo.appName;
  // String packageName = packageInfo.packageName;
  // String version = packageInfo.version;
  // String buildNumber = packageInfo.buildNumber;
  // print('packageInfo');
  // print(appName);
  // print(packageName);
  // print(version);
  // print(buildNumber);
}

class NureboAdmin extends StatefulWidget {
  static const String title = 'Nurebo Admin';

  const NureboAdmin({Key? key,});

  @override
  State<NureboAdmin> createState() => _NureboAdminState();
}

class _NureboAdminState extends State<NureboAdmin> with WidgetsBindingObserver {
  Business? business;
  BusinessProvider? businessProvider;
  late SocketProvider socketProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if (message != null) {
    //     print('************ getInitialMessage *****************');
    //     Fluttertoast.showToast(msg: message.notification?.body ?? '');
    //     // Navigator.push(
    //     //     context,
    //     //     PageTransition(
    //     //         duration: const Duration(milliseconds: 500),
    //     //         alignment: Alignment.center,
    //     //         type: PageTransitionType.fade,
    //     //         child: const NewsScreen()
    //     //     )
    //     // );
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (BuildContext context) => const NewsScreen(),
    //         fullscreenDialog: true,
    //         settings: RouteSettings(
    //
    //         )
    //       ),
    //     );
    //   }
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   //   print('new messages on opened app');
    //   // print(message.notification?.title ?? '');
    //   // Fluttertoast.showToast(msg: message.notification?.body ?? '');
    //   // Navigator.push(
    //   //     context,
    //   //     PageTransition(
    //   //         duration: const Duration(milliseconds: 500),
    //   //         alignment: Alignment.center,
    //   //         type: PageTransitionType.fade,
    //   //         child: const NewsScreen()
    //   //     )
    //   // );
    // });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   showNotification(
    //     // id: 1,
    //     title: message.notification?.title ?? '',
    //     body: message.notification?.body ?? '',
    //     largeIconPath: message.data['prestazione_image']
    //     // payload: message.notification?.title ?? ''
    //   );
    // });

    if(BusinessPreferences.getIsLogged() == true && BusinessPreferences.getBusinessId() != null && BusinessPreferences.getBusinessId() != '' && BusinessPreferences.getEnableNotifications()! /*&& BusinessPreferences.getBackgroundNotifications()*/) {
      // FlutterBackgroundService().sendData({"action": "stopService"},);
      // FlutterBackgroundService().invoke("stopService");
      // Future.wait([
      //   // FlutterBackgroundService().start()
      //   FlutterBackgroundService().startService()
      // ]);
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive){
      // print('AppLifecycleState.inactive');
      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // return exit(0);

      if(BusinessPreferences.getIsLogged()!) {
        await socketProvider.closeSession((await getBusiness())!);
      }

      return;
    }
    else if (state == AppLifecycleState.detached) {
      // print('AppLifecycleState.detached');
      // if(await FlutterBackgroundService().isRunning() == true && BusinessPreferences.getIsLogged() && BusinessPreferences.getBackgroundNotifications()) {
      //   FlutterBackgroundService().invoke("stopService");
      // }

      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // return exit(0);
      return;
    }
    else if (state == AppLifecycleState.paused) {
      // print('AppLifecycleState.paused');
      // await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // return exit(0);
      // return;
    }
    else if (state == AppLifecycleState.resumed) {
      // print('AppLifecycleState.resumed');
      // FlutterBackgroundService().invoke("stopService");
      // if(BusinessPreferences.getIsLogged() &&/*await FlutterBackgroundService().isRunning() == false && */BusinessPreferences.getBackgroundNotifications()) {
      //   await FlutterBackgroundService().startService();
      // }
      if(BusinessPreferences.getIsLogged()!) {
        await socketProvider.startSession((await getBusiness())!, (await getIp()) ?? <String, dynamic>{});
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    print('isServerD');
    print(isServerDown);
    print('BusinessPreferences.getIsLogged()gg6gg6g6');
    print(BusinessPreferences.getIsLogged());


    // return MaterialApp(
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        // '/second': (context) => SecondScreen(),
      },
      navigatorObservers: [routeObserver],
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: snackbarKey,
      title: NureboAdmin.title,
      // localizationsDelegates: GlobalMaterialLocalizations.delegates,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        // Locale('en', ''),
        // Locale('en', 'US'),
        // Locale('zh', ''),
        // Locale('he', ''),
        // Locale('es', ''),
        // Locale('it', ''),
        Locale('it', 'IT'),
        // Locale('ru', ''),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false
      ),
      home: /*isServerDown ? ServerDownScreen()
        : */BusinessPreferences.getIsLogged() == true && isServerDown == false ? HomeScreen()
        : BusinessPreferences.getIsLogged() == false && isServerDown == false ? LoginScreen()
        : BusinessPreferences.getIsLogged() == null && isServerDown == false ? LoginScreen()
        // : const Scaffold(backgroundColor: Colors.white,)
        : const ServerDownScreen()
    );

  }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

//todo: da sistemare
/*Future<void> _showNotification({
  // String senderUsername,
  String? body,
  String? senderUsername,
  String? senderName,
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String? prestazioneImage = 'https://via.placeholder.com/48x48',
  String? text,
  String? title,
  String senderId = '0',
  String subText = '',
}) async {
  await BusinessPreferences.init();

  // final sound = 'piece_of_cake_611.mp3';
  final player = AudioPlayer();
  // var notificationAudio = await player.setAsset('assets/audio/piece_of_cake_611.ogg');
  var sound;

  if(subText == 'Cancellazione'){
    sound = 'my_work_is_done_message_tone.ogg';
    await player.setAsset('assets/audio/my_work_is_done_message_tone.ogg');
  }
  else {
    sound = 'piece_of_cake_611.mp3';
    await player.setAsset('assets/audio/piece-of-cake-611.ogg');
  }

  // AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  // await audioPlayer.open(
  //   // Audio('assets/audio/Life Could Be A Dream (Chill TRAP REMIX).mp3'),
  //   Audio('assets/audio/piece-of-cake-611.ogg'),
  //   // autoStart: false,
  //   autoStart: true,
  //   // showNotification: true
  // );
  // audioPlayer.play();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
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

      // onSelectNotification: null
  );

  final Int64List vibrationPattern = Int64List(2);

  if(BusinessPreferences.getSilentNotifications() == false
      && BusinessPreferences.getEnableNotifications() == true
    *//*&& BusinessPreferences.getBackgroundNotifications() == false*//*) {
    // audioPlayer.play();
    player.play();
  }

  print("BusinessPreferences.getVibrateNotifications() && BusinessPreferences.getEnableNotifications()");
  print(BusinessPreferences.getVibrateNotifications()! && BusinessPreferences.getEnableNotifications()!);

  if(BusinessPreferences.getVibrateNotifications() == true
      && BusinessPreferences.getEnableNotifications() == true
      && BusinessPreferences.getBackgroundNotifications() == false){
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
    sound: RawResourceAndroidNotificationSound(sound.split('.').first),
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
    fullScreenIntent: false,
    channelShowBadge: true,
    // channelShowBadge: true,
    // tag: 'Taggatolo',
    // styleInformation: MediaStyleInformation(
    //   htmlFormatContent: true,
    //   htmlFormatTitle: false,
    // ),
    // styleInformation: bigPictureStyleInformation,
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

class RadialPainter extends CustomPainter {
  const RadialPainter({
    this.bgColor,
    this.lineColor,
    this.percent,
    this.width,
  });

  final Color? bgColor;
  final Color? lineColor;
  final double? percent;
  final double? width;

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgLine = Paint()
      ..color = bgColor!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;

    Paint coloredLine = Paint()
      ..color = lineColor!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, bgLine);

    double sweepAngle = 2 * pi * percent!;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle,
      false, coloredLine,);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

