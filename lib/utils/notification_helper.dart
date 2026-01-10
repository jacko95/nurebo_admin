import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/reservation.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/booking_screen.dart';
import 'package:nurebo_admin/screens/campaign_selection_screen.dart';
import 'package:nurebo_admin/screens/home_screen.dart';
import 'package:nurebo_admin/screens/news_screen.dart';
import 'package:nurebo_admin/screens/prestazione_list_screen.dart';
import 'package:nurebo_admin/screens/reservation_detail_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  if (kDebugMode) {
    // print('background clicked');
  }
  // if (notificationResponse.payload == 'Title botwana sadame ujungi') {
  //   Get.to(() => const Screen1View());
  // } else {
  //   Get.to(() => const Screen2View());
  // }
}

final localNotifications = FlutterLocalNotificationsPlugin();

class LocalNotification {
   Future<void> initializeLocalNotifications(/*BuildContext? context*/) async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('calendar_1');

    DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    LinuxInitializationSettings initializationSettingsLinux = const LinuxInitializationSettings(
      defaultActionName: 'Open notification'
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux
    );

    await localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        print('notificationResponse');
        // print(notificationResponse.payload);
        // print(jsonEncode(notificationResponse.payload));
        print(jsonDecode(notificationResponse.payload!));
        print(notificationResponse.id);
        print(notificationResponse.actionId);
        print(notificationResponse.input);
        print(notificationResponse.notificationResponseType);

        // Get.to(() => BookingScreen());
        // Get.to(() => const HomeScreen());
        navigatorKey.currentState?.push(
          // MaterialPageRoute(builder: (context) => HomeScreen()),
          MaterialPageRoute(
            builder: (context) => ReservationDetailScreen(
              reservation: Reservation.fromJson(
                jsonDecode(notificationResponse.payload!)
              ),
              key: UniqueKey(), // Forza un nuovo widget
            ),

          ),
        );
        /*if (notificationResponse.payload == 'Title botwana sadame ujungi') {
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
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground
    );
  }

  // this function is applicable to iOS versions older than 10.
  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {}
}

Future<void> showNotification({
  /*required*/ int? id,
  required String title,
  required String body,
  /*required*/ String? payload = '',
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String subText = '',
  String? senderId = '0',
  BuildContext? context,
}) async {
  // print('fdvc5cvcv54');
  // print(largeIconPath);
  final platformChannelSpecifics = await _notificationDetails(
    // largeIconPath: largeIconPath,
    subText: subText,
    body: body,
    title: title,
    context: context,
  );
  await localNotifications.show(
    // id,
    Random().nextInt(999999),
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  // print('dsvfggf');
  // print(url);
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<NotificationDetails> _notificationDetails({
  String largeIconPath = 'https://via.placeholder.com/48x48',
  String subText = '',
  String title = '',
  String body = '',
  BuildContext? context,
}) async {
  // final String largeIcon = await _downloadAndSaveFile(
  //   largeIconPath,
  //   'largeIcon'
  // );

  final Int64List vibrationPattern = Int64List(2);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 2000;

  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    Random().nextInt(999999).toString(), // id
    'fcm_nurebo_admin_channel', // title
    importance: Importance.high,
    playSound: true,
    groupKey: 'com.nurebo.nurebo_admin',
    channelDescription: 'channel description',
    priority: Priority.max,
    // icon: 'ticket',
    icon: 'splash',
    ticker: 'ticker',
    // color: const Color(0xff2196f3),
    color: Colors.white,

    // largeIcon: FilePathAndroidBitmap(largeIcon),
    ledOffMs: 300,
    ledOnMs: 300,
    ledColor: Colors.blue,
    enableVibration: false,
    enableLights: true,
    channelShowBadge: true,
    vibrationPattern: vibrationPattern,
    visibility: NotificationVisibility.public,
    subText: subText,
    // fullScreenIntent: true,
    sound: const RawResourceAndroidNotificationSound('piece_of_cake_611'),
    // styleInformation: const MediaStyleInformation(),
    styleInformation: BigTextStyleInformation(
      body
    ),
    // styleInformation: const DefaultStyleInformation(
    //   true,
    //   true
    // ),
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fcm_nurebo_admin_channel', // id
      'fcm_nurebo_admin_channel', // title
      importance: Importance.high,
      playSound: true
  );

  await localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      channel
  );

  DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
    threadIdentifier: "thread1",
  );

  final details = await localNotifications.getNotificationAppLaunchDetails();
  if (details != null && details.didNotificationLaunchApp) {}
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosNotificationDetails
  );

  return platformChannelSpecifics;
}
