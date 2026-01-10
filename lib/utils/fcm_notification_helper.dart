import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/campaign_selection_screen.dart';
import 'package:nurebo_admin/screens/news_screen.dart';
import 'package:nurebo_admin/services/firebase_options.dart';
import 'package:nurebo_admin/utils/notification_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  // print('message.data3');
  // print(message.data);
  dev.log(
    'message.data3',
    name: 'my.app.category',
    error: jsonEncode(message.data),
  );
  // showLocalNotification(
  //     id: 1,
  //     title: message.notification?.title ?? '',
  //     body: message.notification?.body ?? '',
  //     payload: message.notification?.title ?? '');

}

class FCMNotificationHelper {
  // SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);

  static void registerNotification(/*BuildContext? context*/) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    LocalNotification service = LocalNotification();
    await service.initializeLocalNotifications(/*context*/); //todo: bisogna passargli il booking

    FirebaseMessaging.instance.getToken().then((value) {
      // if (kDebugMode) {
        // print(value);
      // }
      deviceToken = value;
    });

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // print('************ getInitialMessage *****************');
        // print('message.data2');
        // print(message.data);
        dev.log(
          'message.data200005',
          name: 'my.app.category',
          error: jsonEncode(message.data),
        );

        // if(/*(message.data['keyname'] == "Messaggio" && Utils.businessChatRoomOpen != "dcsvfb888") ||*/ message.data['keyname'] != "Messaggio") {
          // print(message.data['booking_id']);
          Get.to(() => BookingDetailScreen(
                booking: Booking(
                    id: message.data['booking_id'],
                    isCanceled: int.tryParse(message.data['is_canceled']) ?? 0,
                    is_guest: 0,
                    prestazione: Prestazione(
                      duration: int.tryParse(message.data['prestazione_duration']) ?? 0,
                      id: message.data['prestazione_id'],
                      image: message.data['prestazione_image'],
                      is_price_range: (message.data['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                      price: double.tryParse(message.data['prestazione_price']) /*.toDouble()*/ ?? 0.0,
                      price_max: double.tryParse(message.data['prestazione_price_max']) /*.toDouble()*/ ?? 0.0,
                      price_min: double.tryParse(message.data['prestazione_price_min']) /*.toDouble()*/ ?? 0.0,
                      title: message.data['prestazione_title'],
                      description: message.data['prestazione_description'],
                      business_id: message.data['prestazione_business_id'],
                    ),
                    user: User(
                      id: message.data['user_id'],
                      email: message.data['user_email'],
                      username: message.data['user_username'],
                      name: message.data['user_name'],
                      phone: message.data['user_phone'],
                      profile_image: message.data['user_profile_image'] ??
                          '',
                      description: message.data['user_description'],
                    ),
                    begin_at: DateTime.tryParse(
                        message.data['begin_at']) /*.tolocal()*/,
                    end_at: DateTime.tryParse(message.data['begin_at'])!.add(
                        Duration(minutes: int.tryParse(
                            message.data['prestazione_duration']) ??
                            0)) /*.tolocal()*/,
                    created_at: DateTime.tryParse(message
                        .data['created_at']) /*.tolocal()*/ /*.add(Duration(hours: 2))*/,
                    note: message.data['note']
                ),
              ));
        // }

        /*// Get.showSnackbar(GetSnackBar(title: 'getInitialMessage',message: message.notification?.body ?? '',));
        if (message.notification?.title == 'Title botwana sadame ujungi') {
          Get.to(() => const NewsScreen());
          // Navigator.push(
          //     context!,
          //     PageTransition(
          //         duration: const Duration(milliseconds: 500),
          //         alignment: Alignment.center,
          //         type: PageTransitionType.fade,
          //         child: const NewsScreen()
          //     )
          // );
          // Navigator.push(
          //   context!,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => const NewsScreen(),
          //       fullscreenDialog: true,
          //       settings: RouteSettings(
          //
          //       )
          //   ),
          // );
        }
        else {
          Get.to(() => const CampaignsScreen());
          // Navigator.push(
          //     context!,
          //     PageTransition(
          //         duration: const Duration(milliseconds: 500),
          //         alignment: Alignment.center,
          //         type: PageTransitionType.fade,
          //         child: const ExploreScreen()
          //     )
          // );
        }*/
      }
    });

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // print('new messages on opened app');
        // showLocalNotification(
        //     id: 1,
        //     title: message.notification?.title ?? '',
        //     body: 'It is from onMessageOpenedApp',
        //     payload: message.notification?.title ?? '');
        //   // Parse the message received

        // print('message.data0');
        // print(message.data);
        // print(message.notification?.title ?? '');
        // Get.showSnackbar(GetSnackBar(title: 'onMessageOpenedApp',message: message.notification?.body ?? '',));

        // if(/*(message.data['keyname'] == "Messaggio" && Utils.businessChatRoomOpen != "dcsvfb888") ||*/ message.data['keyname'] != "Messaggio") {
          Get.to(() => BookingDetailScreen(
                booking: Booking(
                    id: message.data['booking_id'],
                    isCanceled: int.tryParse(message.data['is_canceled']) ?? 0,
                    is_guest: 0,
                    prestazione: Prestazione(
                      //todo: prestazione_duration non deve essere null, altrimenti le notifiche non si aprono
                      duration: int.tryParse(message.data['prestazione_duration']) ?? 0,
                      id: message.data['prestazione_id'],
                      image: message.data['prestazione_image'],
                      is_price_range: (message.data['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                      price: double.tryParse(message.data['prestazione_price']) /*.toDouble()*/ ?? 0.0,
                      price_max: double.tryParse(message.data['prestazione_price_max']) /*.toDouble()*/ ?? 0.0,
                      price_min: double.tryParse(message.data['prestazione_price_min']) /*.toDouble()*/ ?? 0.0,
                      title: message.data['prestazione_title'],
                      description: message.data['prestazione_description'],
                      business_id: message.data['prestazione_business_id'],
                    ),
                    user: User(
                      id: message.data['user_id'],
                      email: message.data['user_email'],
                      username: message.data['user_username'],
                      name: message.data['user_name'],
                      phone: message.data['user_phone'],
                      profile_image: message.data['user_profile_image'] ??
                          '',
                      description: message.data['user_description'],
                    ),
                    begin_at: DateTime.tryParse(
                        message.data['begin_at']) /*.tolocal()*/,
                    end_at: DateTime.tryParse(message.data['begin_at'])!.add(
                        Duration(minutes: int.tryParse(
                            message.data['prestazione_duration']) ??
                            0)) /*.tolocal()*/,
                    created_at: DateTime.tryParse(message.data['created_at']) /*.tolocal()*/ /*.add(Duration(hours: 2))*/,
                    note: message.data['note']
                ),
              ));
        // }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // print('message.data1');
        dev.log(
          'log me',
          name: 'my.app.category',
          error: jsonEncode(message.data),
        );
        print('message.data');
        print(message.data);
        print(message.data['prestazione_image']);
        print('message.notification?.android!.imageUrl');
        print(message.notification?.android!.imageUrl);
        print(message.data['keyname']);
        print(Utils.businessChatRoomOpen);
        print(message.data['keyname'] != "Messaggio");
        print(/*socketProvider*/Utils.businessChatRoomOpen != "dcsvfb888");

        // if((message.data['keyname'] == "Messaggio" && /*socketProvider*/Utils.businessChatRoomOpen != "dcsvfb888") || message.data['keyname'] != "Messaggio"){
          showNotification(
            id: 1,
            title: message.notification?.title ?? '',
            body: message.notification?.body ?? '',
            // payload: message.notification?.title ?? '',
            payload: message.notification?.bodyLocKey ?? '',
            // payload: message.data.toString() ?? '',
            // largeIconPath: message.notification?.android!.imageUrl != null ? '${Utils.httpServerUrl}image?path=${message.notification?.android!.imageUrl}' : 'https://via.placeholder.com/48x48',
            // largeIconPath: message.data['prestazione_image'] != null ? '${Utils.httpServerUrl}image?path=${message.data['prestazione_image']}' : 'https://via.placeholder.com/48x48',
          );
        // }

        // Parse the message received
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }
}
