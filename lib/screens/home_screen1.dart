import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/screens/reservation_detail_screen.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart' as gw;
import 'package:http/io_client.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
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
import 'package:nurebo_admin/screens/login_screen.dart';
import 'package:nurebo_admin/screens/notifications_screen.dart';
import 'package:nurebo_admin/screens/prestazione_list_screen.dart';
import 'package:nurebo_admin/screens/splash_screen.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/navigation_drawer1.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/get.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:socket_io_client/socket_io_client.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const notificationChannel = MethodChannel('notification00');
  // List? bookingList = [];
  // List<int> bookingFrequencyList = [];
  // double chartBarWidth = 20.2;
  Future b = Future(() {}), c = Future(() {}), d = Future(() {}), e = Future(() {}), f = Future(() {}), g = Future(() {}), hu = Future(() {}), l = Future(() {}), all = Future(() {});
  List? subscriptionList = [];
  List<int> subscriptionFrequencyList = [];
  late SocketProvider socketProvider;
  late PostProvider postProvider;
  late BusinessProvider businessProvider;
  late PrestazioneProvider prestazioneProvider;
  late GeolocationProvider geolocationProvider;
  late VetrinaProvider vetrinaProvider;
  late EventProvider eventProvider;
  List? prestazioneRankingList = [];
  List? usersRankingList = [];
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool showSplashScreen = true;
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    };
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (foundation.kIsWeb) {
        // deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          // deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          // deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    // print('deviceData');
    // print(deviceData);

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Future callFutureMethods1() async {
    /*f = */socketProvider.getBusinessReservations(/*businessProvider.business*/);
    /*f = */socketProvider.getBusinessAppointments(/*businessProvider.business*/);
    /*b = */socketProvider.getBusinessFrequencyReservationPerDay(businessProvider.business!, context);
  }

  // Future getBusiness(String businessId) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "business");
  //   Map/*<String, String>*/ body = {
  //     'id': businessId,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       bodfromY: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //   //todo: si sputtana il certificato https qui
  //   print('fff');
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     Business business = new Business(
  //       id: jsonData[0]['business_id'],
  //       description: jsonData[0]['business_description'],
  //       name: jsonData[0]['business_name'],
  //       email: jsonData[0]['business_email'],
  //       max_contemporary_appointments: jsonData[0]['max_contemporary_appointments'],
  //       address: jsonData[0]['business_address'],
  //       phone_number: jsonData[0]['business_phone_number'],
  //       is_booking_business: jsonData[0]['is_booking_business'],
  //       profile_image: jsonData[0]e['business_profile_image'] ?? '',
  //       latitude: jsonData[0]['business_latitude'],
  //       longitude: jsonData[0]['business_longitude'],
  //       categorfromY: Category(
  //         id: jsonData[0]['category_id'],
  //         image: jsonData[0]['category_image'],
  //         name: jsonData[0]['category_name'],
  //       )
  //     );
  //     // });
  //
  //     return business;
  //   }
  // }
  Future getBusiness(String? businessId) async {
    final context = SecurityContext.defaultContext;
    // modify context as needed
    final httpClient = HttpClient(context: context);
    final client = IOClient(httpClient);

    // var url = Uri.parse("${Utils.httpServerUrl}business");
    // var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/is_visible");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/is_visible");
    Map/*<String, String>*/ body = {
      'business_id': businessId,
    };

    // var response = await client.post(
    var response = await client.get(
        url,
        // bodfromY: jsonEncode(body),
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
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      Business business = Business(
          id: jsonData[0]['business_id'],
          room_id: jsonData[0]['business_room_id'],
          description: jsonData[0]['business_description'],
          name: jsonData[0]['business_name'],
          email: jsonData[0]['business_email'],
          email_notification: jsonData[0]['business_email_notification'],
          max_contemporary_appointments: jsonData[0]['max_contemporary_appointments'],
          address: jsonData[0]['business_address'],
          address_number: jsonData[0]['business_address_number'],
          postal_code: jsonData[0]['business_postal_code'],
          province: jsonData[0]['business_province'],
          city: jsonData[0]['business_city'],
          region: jsonData[0]['business_region'],
          phone: jsonData[0]['business_phone_number'],
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
      // });

      return business;
    }
  }

  Future getLastVersion() async {
    var url = Uri.parse(Utils.httpServerUrl + "version/last");

    var response = await http.get(
        url,
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // lastVersionId = jsonData['id'];

      if(jsonData[0]['id'] > Utils.version_id){
        // print('gggll');
        //mostrare dialog
        if(mounted){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return Text('bimbo');
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(
                  'Aggiornamento disponibile',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Vuoi aggiornare nurebo dalla versione ${Utils.version_name} alla ${jsonData[0]['name']}',
                  textAlign: TextAlign.center,
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                actions: <Widget>[
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                        child: Text(
                          'Più tardi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                  ),
                  InkWell(
                      onTap: () async {
                        // Navigator.of(context, rootNavigator: false).pop(context);
                        Navigator.pop(context);
                        DownloadProvider provider = Provider.of<DownloadProvider>(context, listen: false);
                        if(await provider.checkPermission()) {
                          await provider.downloadFile(
                            context: context,
                            // url: url,
                            // url: "https://drive.google.com/file/d/1x4wXpR-1aR6qddxhAUDH0AuCsICAdUFp/view?usp=sharing",
                            // url: "https://images.pexels.com/photos/219095/pexels-photo-219095.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                            // url: "https://www.filehosting.org/file/download/969725/dC0mB9FGGSZphZ4j",
                            // url: "https://file.io/sGWMJ9f7cSTU",
                            // url: "https://filetransfer.io/manage-package/5Z0Xmp4k",
                            // url: "http://192.168.1.252/nurebo-server/qr_codes/03d9d653-1966-47ce-8e11-4518cef7d7d3.png",
                            // url: "http://192.168.1.252/nurebo/uploads/image_picker4385430151078139697.jpg",
                            // url: "http://192.168.1.252/nurebo-server/upload/SymbolabMathsolver_v3.2.1_apkpure.com.apk",
                            // url: "http://192.168.1.252/nurebo-server/upload/com.devsense.symbolab.apk",
                            url: jsonData[0]['apk_url'],
                            // fileExtension: '.pdf',
                            // fileExtension: '.png',
                            // fileExtension: '.apk',
                            fileExtension: '',
                            // fileExtension: '.jpg',
                            openAfterDownload: true,
                            // filename: "cccio",
                            // filename: jsonData[0]['apk_url'].toString().split('/').last,
                            filename: jsonData[0]['apk_url'].toString().split('/').last,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
                        child: Text(
                          'Aggiorna',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[500],
                          ),
                        ),
                      )
                  ),
                  SizedBox(width: 2,),
                  // ElevatedButton(
                  //   // onPressed: () => Navigator.of(context).pop(DialogAction.abort),
                  //   onPressed: () {  },
                  //   child: const Text('No'),
                  // ),
                  // ElevatedButton(
                  //   // onPressed: () => Navigator.of(context).pop(DialogAction.yes),
                  //   onPressed: () {  },
                  //   child: const Text(
                  //     'Yes',
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },

          );
        }

      }
      // else
      //   print('ribosoma');

      return jsonData;
    }
  }

  // Future getDateBusinessTimetable() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "timetable/business");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/timetable");
  //
  //   Map/*<String, String>*/ body = {
  //     'business_id': businessProvider.business!.id,
  //   };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // bodfromY: jsonEncode(body),
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
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       businessProvider.business!.bookingBusinessTimetable = jsonData;
  //     });
  //
  //     // bookingBusinessTimetable.sort((a, b) {
  //     //   if(a['weekday_id'] == b['weekday_id']) {
  //     //     if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
  //     //       return int.tryParse(a['close_at_hour']).compareTo(int.tryParse(b['close_at_hour']));
  //     //     }
  //     //     return int.tryParse(a['open_at_hour']).compareTo(int.tryParse(b['open_at_hour']));
  //     //   }
  //     //   return a['weekday_id'].compareTo(b['weekday_id']);
  //     // });
  //     businessProvider.business!.bookingBusinessTimetable!.sort((a, b) {
  //       if(a['weekday_id'] == b['weekday_id']) {
  //         if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
  //           if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
  //             if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
  //               return int.tryParse(a['close_at_minute'])!.compareTo(int.tryParse(b['close_at_minute'])!);
  //             }
  //             return int.tryParse(a['close_at_hour'])!.compareTo(int.tryParse(b['close_at_hour'])!);
  //           }
  //           return int.tryParse(a['open_at_minute'])!.compareTo(int.tryParse(b['open_at_minute'])!);
  //         }
  //         return int.tryParse(a['open_at_hour'])!.compareTo(int.tryParse(b['open_at_hour'])!);
  //       }
  //       return a['weekday_id'].compareTo(b['weekday_id']);
  //     });
  //
  //     // print('businessProvider.business.bookingBusinessTimetable olaaa');
  //     // print(businessProvider.business.bookingBusinessTimetable);
  //
  //     return jsonData;
  //   }
  // }

  // Future getBusinessAppointments() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/appointments");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/booking/is_visible");
  //
  //   Map/*<String, String>*/ body = {
  //     'business_id': businessProvider.business!.id,
  //     // 'business_id': BusinessPreferences.getBusinessId(),
  //   };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // bodfromY: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //         'Authorization': BusinessPreferences.getBusinessToken()!
  //       }
  //   );
  //
  //   // print("fgggggi response.statusCode:");
  //   // print(response.statusCode);
  //
  //   if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
  //     // if (!mounted) return;
  //     await businessProvider.logout(context);
  //   }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     bookingList = jsonData;
  //
  //     int daysToSubtract = 0;
  //     // print('bookingFrequency');
  //     for(int i = 13; i > 0; i--){
  //       int bookingFrequency = 0;
  //       for(int i = bookingList!.length-1; i >= 0; i--){
  //         if(DateTime.tryParse(bookingList![i]['created_at'])!.day.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).day)
  //             && DateTime.tryParse(bookingList![i]['created_at'])!.month.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).month)
  //             && DateTime.tryParse(bookingList![i]['created_at'])!.year.isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).year)){
  //           bookingFrequency++;
  //         }
  //       }
  //       if(mounted){
  //         setState(() {
  //           bookingFrequencyList.add(bookingFrequency);
  //         });
  //       }
  //
  //       // print(i.toString() + " $bookingFrequency");
  //       daysToSubtract++;
  //     }
  //
  //     // print('jsonData');
  //     // print(jsonData);
  //     // print('bookingList');
  //     // print(bookingList);
  //     return jsonData;
  //   }
  // }

  Future getBusinessSubscriptions() async {
    var url = Uri.parse(Utils.httpServerUrl + "business_subscription/business_id");

    Map/*<String, String>*/ body = {
      'business_id': businessProvider.business!.id,
      // 'business_id': BusinessPreferences.getBusinessId(),
      'booking': DateTime.now().subtract(Duration(days: 13)).toString(),
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
          'Authorization': BusinessPreferences.getBusinessToken()!
        }
    );

    // print("fddfdbgdgdgdg response.statusCode:");
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      subscriptionList = jsonData;

      int daysToSubtract = 0;
      // print('subscriptionFrequency');
      for(int i = 0; i < 13; i++){
        int subscriptionFrequency = 0;
        for(int i = 0; i <= subscriptionList!.length-1; i++){
          if(DateTime.tryParse(subscriptionList![i]['business_subscription_created_at'])!.day
              .isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).day)
              && DateTime.tryParse(subscriptionList![i]['business_subscription_created_at'])!.month
                  .isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).month)
              && DateTime.tryParse(subscriptionList![i]['business_subscription_created_at'])!.year
                  .isEqual(DateTime.now().subtract(Duration(days: daysToSubtract)).year)){
            subscriptionFrequency++;
          }
        }
        if(mounted){
          setState(() {
            subscriptionFrequencyList.add(subscriptionFrequency);
          });
        }

        // print(i.toString() + " $subscriptionFrequency");
        daysToSubtract++;
      }

      // print('jsonData');
      // print(jsonData);
      // print('subscriptionList');
      // print(subscriptionList);
      return jsonData;
    }
  }

  // Future getUsersRanking() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking?business_id=${businessProvider.business.id}");
  //
  //   // final queryParameters = {
  //   //   'param1': 'one',
  //   //   'param2': 'two',
  //   // };
  //
  //   // final uri = Uri.http('www.myurl.com', '/api/v1/test/${widget.pk}', queryParameters);
  //   // final url = Uri.http(Utils.httpServerUrl/* + "booking/user_ranking"*/, '/booking/user_ranking', queryParameters);
  //   // final url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking").replace(querfromY: 'param1=one');
  //
  //   // final url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking").replace(queryParameters: {
  //   //   'business_id': businessProvider.business!.id,
  //   // });
  //   final url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/order/user/grouped-by-order").replace(queryParameters: {
  //     'business_id': businessProvider.business!.id,
  //   });
  //
  //   var response = await http.get(
  //       url,
  //       // bodfromY: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
  //       }
  //   );
  //
  //   // print('user_ranking');
  //   // print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // print("booking/user_ranking");
  //     // print(jsonData);
  //
  //     usersRankingList = jsonData;
  //
  //     return jsonData;
  //   }
  // }
  //
  // Future getPrestazioneRanking() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking?business_id=${businessProvider.business.id}");
  //
  //   // final queryParameters = {
  //   //   'param1': 'one',
  //   //   'param2': 'two',
  //   // };
  //
  //   // final uri = Uri.http('www.myurl.com', '/api/v1/test/${widget.pk}', queryParameters);
  //   // final url = Uri.http(Utils.httpServerUrl/* + "booking/user_ranking"*/, '/booking/user_ranking', queryParameters);
  //   // final url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking").replace(querfromY: 'param1=one');
  //
  //   // final url = Uri.parse(Utils.httpServerUrl + "booking/prestazione_ranking").replace(queryParameters: {
  //   //   'business_id': businessProvider.business!.id,
  //   // });
  //   final url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/order/user/grouped-by-prestazione").replace(queryParameters: {
  //     'business_id': businessProvider.business!.id,
  //   });
  //
  //   var response = await http.get(
  //       url,
  //       // bodfromY: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
  //       }
  //   );
  //
  //   // print('user_ranking');
  //   // print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // print("booking/prestazione_ranking");
  //     // print(jsonData);
  //
  //     prestazioneRankingList = jsonData;
  //
  //     return jsonData;
  //   }
  // }

  Future futureBuilderMethods() async {
    BusinessPreferences.init().then((value) async {
      //todo: da riabilitare nel caso serva. per restaurant è disabilitato
      // /*await*/ geolocationProvider.getGeolocationPermission();

      if(BusinessPreferences.getIsLogged()!) {
        try {
          Business business = await (getBusiness(BusinessPreferences.getBusinessId()) /*as Future<Business>*/);
          businessProvider.setBusiness(business);
          // } catch (e) {
        } on TimeoutException catch (e) {
          // print('un dio che prima dd5dd5d5d5 un cane');
          // print(e);
          // isServerDown = true;
        }
      }
      else{
        await Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: LoginScreen(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
            ),
                (route) => false
        );
      }

      if(BusinessPreferences.getBackgroundNotifications()! && BusinessPreferences.getEnableNotifications()!){
        await BusinessPreferences.setBackgroundNotifications(true);

        // print('FlutterBackgroundService().isServiceRunning() 00');
        // // print((await FlutterBackgroundService().isServiceRunning()).toString());
        // print((await FlutterBackgroundService().isRunning()).toString());

        // // if((await FlutterBackgroundService().isServiceRunning()) == false){
        // if((await FlutterBackgroundService().isRunning()) == false){
        //   // await FlutterBackgroundService().start();
        //   await FlutterBackgroundService().startService();
        // }

        //   print('FlutterBackgroundService().isServiceRunning() 01');
        //   // print((await FlutterBackgroundService().isServiceRunning()).toString());
        //   print((await FlutterBackgroundService().isRunning()).toString());
        // }

        if(mounted){
          // socketProvider = Provider.of<SocketProvider>(context, listen: false);
          // await socketProvider.connect(businessProvider.business.id.toString());

          //todo: così funzionano, da provare in future.wait
          // await socketProvider.connect(BusinessPreferences.getBusinessId(), context);
          /*late*/ Socket? sock;
          do {
            sock = await socketProvider.connect(BusinessPreferences.getBusinessId(), context);
          } while(sock == null);
          // await socketProvider.tryConnectSocket(BusinessPreferences.getBusinessId(), context);

          // await socketProvider.getBusinessAppointments(businessProvider.business);
          // await prestazioneProvider.getAllBusinessPrestazioni(businessProvider.business.id, context);

          Future.wait([
            // socketProvider.connect(BusinessPreferences.getBusinessId(), context),
            socketProvider.startSession(businessProvider.business!, (await getIp()) ?? <String, dynamic>{}),
            // f = socketProvider.getBusinessAppointments(/*businessProvider.business*/),
            // b = socketProvider.getBusinessFrequencyReservationPerDay(businessProvider.business!, context),
            hu = callFutureMethods1(),
            // e = socketProvider.getGuestBookings(),
            socketProvider.updateFcmToken(businessProvider.business!),
            // socketProvider.getBusinessChatRoom(context),
            // postProvider.getAllBusinessPost(businessProvider.business!.id, context),

            // g = getUsersRanking(),
            // l = getPrestazioneRanking(),
            getLastVersion(),
            socketProvider.insertDevice(businessProvider.business!, _deviceData),
            // socketConnect(),
            // b = getBusinessAppointments(),
            // c = getBusinessSubscriptions(),

            /**/
            //todo: deselezionate per reservation app
            // socketProvider.getUnseenLocalNotifications(businessProvider.business!, context),
            // socketProvider.getLocalNotifications(businessProvider.business!),
            // businessProvider.getBusinessSettings(/*businessProvider.business*/),
            // prestazioneProvider.getAllBusinessPrestazioni(businessProvider.business!.id, context),
            // eventProvider.getAllBusinessEvents(businessProvider.business!.id, context),
            // eventProvider.getAllBusinessEventTickets(businessProvider.business!.id, context),
            // vetrinaProvider.getAllRecommendedPrestazione(businessProvider.business!.id, context),
            // socketProvider.getAllChatRoomMessages(context),
            // d = businessProvider.getDateBusinessTimetable().then((value) {
            //   // setState(() {
            //   //   businessProvider.business!.bookingBusinessTimetable = value;
            //   // });
            //
            //   businessProvider.business!.bookingBusinessTimetable!.sort((a, b) {
            //     if(a['weekday_id'] == b['weekday_id']) {
            //       if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
            //         if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
            //           if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
            //             return int.tryParse(a['close_at_minute'])!.compareTo(int.tryParse(b['close_at_minute'])!);
            //           }
            //           return int.tryParse(a['close_at_hour'])!.compareTo(int.tryParse(b['close_at_hour'])!);
            //         }
            //         return int.tryParse(a['open_at_minute'])!.compareTo(int.tryParse(b['open_at_minute'])!);
            //       }
            //       return int.tryParse(a['open_at_hour'])!.compareTo(int.tryParse(b['open_at_hour'])!);
            //     }
            //     return a['weekday_id'].compareTo(b['weekday_id']);
            //   });
            // }),
            /**/
          ]).then((value) {
            // FlutterNativeSplash.remove();
            setState(() {
              showSplashScreen = false;
            });
          });

        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    eventProvider = Provider.of<EventProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    vetrinaProvider = Provider.of<VetrinaProvider>(context, listen: false);

    // initializeDateFormatting();

    Future.wait([
      initPlatformState(),
      initializeDateFormatting(),
    ]);

    timeAgo.setLocale('it', timeAgo.Italian());

    all = futureBuilderMethods();

    print('Utils.timezoneOffset');
    print(Utils.timezoneOffset);
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    double chartBarWidth = MediaQuery.of(context).size.width * 0.0565;

    int crossAxisCount = 2;
    double childAspectRatio = 1.9;

    return FutureBuilder(
      future: all,
        initialData: const [],
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              // backgroundColor: Colors.white,
                backgroundColor: Color.fromRGBO(247, 251, 254, 1),
                // drawer: NureboAdminDrawer(),
                drawer: NavigationDrawerWidget(/*business: businessProvider.business,*/),
                // endDrawer: NavigationDrawerWidget(),
                appBar: AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        // 'assets/launcher_icons/14162885.png',
                        'assets/launcher_icons/MivdtMvHOvJLhJ3HFeVz.png',
                        height: 34,
                      ),
                      SizedBox(width: 5,),
                      Text(
                        // 'Admin',
                        'nurebo',
                        style: TextStyle(
                            color: Colors.blue[500],
                            // fontWeight: FontWeight.w600,
                            fontSize: 27,
                            letterSpacing: -2.3,

                            fontFamily: 'Panton'
                        ),
                      ),
                      SizedBox(width: 30,),
                    ],
                  ),
                  actions: [
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    //   child: Icon(
                    //     Icons.notifications_none,
                    //     size: 28,
                    //     color: Colors.grey[600],
                    //   ),
                    // )
                    SizedBox(height: 0,)
                  ],
                  // backgroundColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    // color: Colors.blue
                    color: Colors.grey[700],
                    size: 30,
                  ),
                  // centerTitle: true,
                ),
                body: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Container(
                        //   height: MediaQuery.of(context).size.height * 0.68,
                        //   padding: EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Text(
                        //             'Ultime Notifiche',
                        //             style: TextStyle(
                        //               color: Colors.black,
                        //               fontWeight: FontWeight.w700,
                        //               fontSize: 15,
                        //             ),
                        //           ),
                        //           InkWell(
                        //             onTap: (){
                        //               Navigator.push(
                        //                   context,
                        //                   PageTransition(
                        //                       duration: const Duration(milliseconds: 500),
                        //                       alignment: Alignment.center,
                        //                       type: PageTransitionType.fade,
                        //                       child: BookingScreen(
                        //                         bookingBusiness: businessProvider.business,
                        //                       )
                        //                     // child: TicketDetailScreen(
                        //                     //   user: widget.user,
                        //                     //   singleEventTicket: singleEventTicket,
                        //                     // ),
                        //                   )
                        //               );
                        //             },
                        //             child: Text(
                        //               'Show All',
                        //               // 'Guarda tutte',
                        //               style: TextStyle(
                        //                 // color: Colors.black.withOpacity(0.5),
                        //                 color: Colors.blue,
                        //                 fontWeight: FontWeight.bold,
                        //                 fontSize: 13,
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(
                        //         height: 16,
                        //       ),
                        //
                        //       Expanded(
                        //         child: ListView.builder(
                        //             physics: NeverScrollableScrollPhysics(),
                        //             shrinkWrap: true,
                        //             // itemCount: discussionData.length,
                        //             itemCount: bookingList.length < 6 ? bookingList.length : 6,
                        //             // itemBuilder: (context, index) => DiscussionInfoDetail(
                        //             //   info: discussionData[index],
                        //             // ),
                        //             itemBuilder: (context, index) => InkWell(
                        //               onTap: (){
                        //                 Appointment appointment = Appointment(
                        //                   id: bookingList[index]['booking_id'],
                        //                   // note: myAppointments[index]['note'],
                        //                   // user_id: myAppointments[index]['user_id'].toString(),
                        //                   prestazione: Prestazione(
                        //                     duration: bookingList[index]['prestazione_duration'],
                        //                     image: bookingList[index]['prestazione_image'],
                        //                     price: bookingList[index]['prestazione_price'],
                        //                     title: bookingList[index]['prestazione_title'],
                        //                     description: bookingList[index]['prestazione_description'],
                        //                     business_id: bookingList[index]['prestazione_business_id'],
                        //                   ),
                        //                   user: User(
                        //                     email: bookingList[index]['user_email'],
                        //                     username: bookingList[index]['user_username'],
                        //                     name: bookingList[index]['user_name'],
                        //                     phone_number: bookingList[index]['user_phone_number'],
                        //                     profile_image: bookingList[index]['user_profile_image'],
                        //                     description: bookingList[index]['user_description'],
                        //                   ),
                        //                   // business: new Business(
                        //                   //   image: myAppointments[index]['profile_image'],
                        //                   //   id: myAppointments[index]['business_id'],
                        //                   //   // is_booking_business: 1,
                        //                   //   name: myAppointments[index]['name'],
                        //                   //   address: myAppointments[index]['address'],
                        //                   //   phone_number: myAppointments[index]['phone_number'],
                        //                   //   // max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
                        //                   //
                        //                   // ),
                        //                   // is_paid: myAppointments[index]['is_paid'],
                        //                   begin_at: DateTime.tryParse(bookingList[index]['begin_at']),
                        //                   end_at: DateTime.tryParse(bookingList[index]['begin_at']).add(
                        //                       Duration(
                        //                           minutes: bookingList[index]['prestazione_duration'].toInt()
                        //                       )
                        //                   ),
                        //                   created_at: DateTime.tryParse(bookingList[index]['created_at']),
                        //                 );
                        //
                        //                 Navigator.push(
                        //                     context,
                        //                     PageTransition(
                        //                         duration: const Duration(milliseconds: 500),
                        //                         alignment: Alignment.center,
                        //                         type: PageTransitionType.fade,
                        //                         child: AppointmentDetailScreen(
                        //                           appointment: appointment,
                        //                         )
                        //                       // child: TicketDetailScreen(
                        //                       //   user: widget.user,
                        //                       //   singleEventTicket: singleEventTicket,
                        //                       // ),
                        //                     )
                        //                 );
                        //               },
                        //               child: Container(
                        //                 margin: EdgeInsets.only(top: 16),
                        //                 padding: EdgeInsets.all(16 / 2),
                        //                 child: Row(
                        //                   children: [
                        //                     ClipRRect(
                        //                       borderRadius: BorderRadius.circular(40),
                        //                       // child: Image.asset(
                        //                       child: Image.network(
                        //                         // discussionData[index].imageSrc,
                        //                         bookingList[index]['user_profile_image'],
                        //                         height: 38,
                        //                         width: 38,
                        //                         fit: BoxFit.cover,
                        //                       ),
                        //                     ),
                        //                     Expanded(
                        //                       child: Padding(
                        //                         padding: const EdgeInsets.symmetric(horizontal: 16),
                        //                         child: Column(
                        //                           crossAxisAlignment: CrossAxisAlignment.start,
                        //                           children: [
                        //                             /*gw.Gradient*/Text(
                        //                               'Prenotazione',
                        //                               // gradient: LinearGradient(
                        //                               //     begin: Alignment.bottomLeft,
                        //                               //     end: Alignment.topRight,
                        //                               //     colors: [
                        //                               //       Color(0xff8921aa),
                        //                               //       Color(0xffDA44bb),
                        //                               //       // Color(0xffDA44bb)
                        //                               //     ]
                        //                               // ),
                        //                               style: TextStyle(
                        //                                 // color: Colors.greenAccent[700],
                        //                                 color: Colors.green[500],
                        //                                 fontWeight: FontWeight.w700
                        //                               ),
                        //                             ),
                        //                             Text(
                        //                               bookingList[index]['user_name'],
                        //                               style: TextStyle(
                        //                                 color: Colors.black,
                        //                                 fontWeight: FontWeight.w600
                        //                               ),
                        //                             ),
                        //                             Text(bookingList[index]['prestazione_title'],
                        //                               style: TextStyle(
                        //                                 color: Colors.black.withOpacity(0.5),
                        //                                 fontSize: 13,
                        //                                 fontWeight: FontWeight.w600
                        //                               ),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     ),
                        //                     // Icon(
                        //                     //   Icons.more_vert_rounded,
                        //                     //   color: Colors.black.withOpacity(0.5),
                        //                     //   size: 18,
                        //                     // )
                        //                     Text(
                        //                       // discussionData[index].booking,
                        //                       timeAgo.format(
                        //                           DateTime.tryParse(bookingList[index]['created_at']),
                        //                           locale: 'it'
                        //                       ),
                        //                       // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                        //                       //     + ' alle ' +
                        //                       //     bookingList[index]['created_at'].toString().substring(11, 16),
                        //                       style: TextStyle(
                        //                         color: Colors.black.withOpacity(0.5),
                        //                         fontSize: 13,
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             )
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),

                        // Visibility(
                        //   visible: businessProvider.business?.type_id == 2,
                        //   child: Container(
                        //     height: 400,
                        //     width: double.infinity,
                        //     padding: EdgeInsets.symmetric(
                        //         vertical: 16,
                        //         horizontal: MediaQuery.of(context).size.width * 0.03
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           "Prenotazioni nell'ultimo periodo",
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.w700,
                        //             fontSize: 15,
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //         SizedBox(height: 40,),
                        //         FutureBuilder(
                        //           // future: Future.wait([e, f, b]),
                        //           // future: callFutureMethods1(),
                        //             future: hu,
                        //             builder: (context, snapshot) {
                        //               if(snapshot.connectionState == ConnectionState.done /*&& snapshot.hasData*/
                        //                   && socketProvider.bookingFrequencyList.isNotEmpty){
                        //                 return Expanded(
                        //                   child: BarChart(
                        //                     BarChartData(
                        //                         borderData: FlBorderData(
                        //                             border: Border.all(width: 0),
                        //                             show: false
                        //                         ),
                        //                         groupsSpace: 15,
                        //                         // minfromY: 0,
                        //                         // maxfromY: 10,
                        //                         barTouchData: BarTouchData(
                        //                           // touchCallback: (flTouchEvent, barTouchResponse){
                        //                           //   print('ciao');
                        //                           // },
                        //                           // enabled: true
                        //                         ),
                        //                         titlesData: FlTitlesData(
                        //                             show: true,
                        //                             rightTitles: AxisTitles(
                        //                               sideTitles: SideTitles(
                        //                                   showTitles: false
                        //                               ),
                        //                             ),
                        //                             topTitles: AxisTitles(
                        //                               sideTitles: SideTitles(
                        //                                   showTitles: false
                        //                               ),
                        //                             ),
                        //                             bottomTitles: AxisTitles(
                        //                               sideTitles: SideTitles(
                        //                                 showTitles: true,
                        //                                 interval: 15,
                        //                                 getTitlesWidget: (double value, TitleMeta meta) {
                        //                                   TextStyle style = const TextStyle(
                        //                                     color: Colors.black26,
                        //                                     fontWeight: FontWeight.w700,
                        //                                     fontSize: 9.5,
                        //                                   );
                        //
                        //                                   double margin = MediaQuery.of(context).size.width * 0.015;
                        //
                        //                                   Widget textWidget(String text) => Padding(
                        //                                     padding: EdgeInsets.only(bottom: margin),
                        //                                     child: Text(
                        //                                       text,
                        //                                       style: style,
                        //                                     ),
                        //                                   );
                        //
                        //                                   String formattedDate(int daysAgo) {
                        //                                     DateTime date = DateTime.now().subtract(Duration(days: daysAgo));
                        //                                     String day = date.day.toString();
                        //                                     String? month = DateFormat.MMMM('it_IT').format(date).substring(0, 3).capitalizeFirst;
                        //                                     return '$day\n$month';
                        //                                   }
                        //
                        //                                   switch (value.toInt()) {
                        //                                     case 1:
                        //                                       return textWidget(formattedDate(12));
                        //                                     case 3:
                        //                                       return textWidget(formattedDate(10));
                        //                                     case 5:
                        //                                       return textWidget(formattedDate(8));
                        //                                     case 7:
                        //                                       return textWidget(formattedDate(6));
                        //                                     case 9:
                        //                                       return textWidget(formattedDate(4));
                        //                                     case 11:
                        //                                       return textWidget(formattedDate(2));
                        //                                     case 13:
                        //                                       return textWidget(formattedDate(0));
                        //                                     default:
                        //                                       return textWidget('');
                        //                                   }
                        //                                 },
                        //                               ),
                        //                             ),
                        //                             leftTitles: AxisTitles(
                        //                               sideTitles: SideTitles(
                        //                                   showTitles: true,
                        //                                   interval: 4.toDouble(),
                        //                                   // getTextStyles: (value, h) => const TextStyle(
                        //                                   //   color: Colors.black26,
                        //                                   //   fontWeight: FontWeight.bold,
                        //                                   //   fontSize: 11,
                        //                                   // ),
                        //                                   // // margin: 16,
                        //                                   // margin: MediaQuery.of(context).size.width * 0.015,
                        //                                 getTitlesWidget: (double value, TitleMeta meta) {
                        //                                   switch (value.toInt()) {
                        //                                     case 4:
                        //                                       return SideTitleWidget(
                        //                                         axisSide: meta.axisSide,
                        //                                         child: Text('4'),
                        //                                       );
                        //                                     case 8:
                        //                                       return SideTitleWidget(
                        //                                         axisSide: meta.axisSide,
                        //                                         child: Text('8'),
                        //                                       );
                        //                                     case 12:
                        //                                       return SideTitleWidget(
                        //                                         axisSide: meta.axisSide,
                        //                                         child: Text('12'),
                        //                                       );
                        //                                     case 16:
                        //                                       return SideTitleWidget(
                        //                                         axisSide: meta.axisSide,
                        //                                         child: Text('16'),
                        //                                       );
                        //                                     case 20:
                        //                                       return SideTitleWidget(
                        //                                         axisSide: meta.axisSide,
                        //                                         child: Text('20'),
                        //                                       );
                        //                                     default:
                        //                                       return SideTitleWidget(
                        //                                         axisSide: meta.axisSide,
                        //                                         child: Text(''),
                        //                                       );
                        //                                   }
                        //                                 },
                        //                               )
                        //                             )
                        //                         ),
                        //                         gridData: FlGridData(
                        //                           show: true,
                        //                           drawHorizontalLine: false,
                        //                           // getDrawingHorizontalLine: (value) {
                        //                           //   return FlLine(
                        //                           //     color: Colors.grey[400],
                        //                           //     strokeWidth: .5,
                        //                           //   );
                        //                           // },
                        //                           drawVerticalLine: false,
                        //                           getDrawingVerticalLine: (value) {
                        //                             return FlLine(
                        //                               color: Colors.grey[400],
                        //                               strokeWidth: 1,
                        //                             );
                        //                           },
                        //                         ),
                        //                         barGroups: [
                        //                           BarChartGroupData(
                        //                               x: 1,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 5,
                        //                                     fromY: /*bookingFrequencyList.length > 0 ? */socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-1].toDouble(),
                        //                                     toY: /*bookingFrequencyList.length > 0 ? */socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-1].toDouble()
                        //                                     /*: bookingFrequencyList[bookingFrequencyList.length].toDouble()*/,
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: const Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 2,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 18,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-2].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-2].toDouble(),
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 3,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 12,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-3].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-3].toDouble(),
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 4,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 8,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-4].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-4].toDouble(),
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 5,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 6,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-5].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-5].toDouble(),
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 6,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 16,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-6].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-6].toDouble(),
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 7,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 6,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-7].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-7].toDouble(),
                        //                                     // fromY: bookingFrequencyList[8].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 8,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 4,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-8].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-8].toDouble(),
                        //                                     // fromY: bookingFrequencyList[9].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 9,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 9,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-9].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-9].toDouble(),
                        //                                     // fromY: bookingFrequencyList[10].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 10,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 12,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-10].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-10].toDouble(),
                        //                                     // fromY: bookingFrequencyList[11].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 11,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 13,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-11].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-11].toDouble(),
                        //                                     // fromY: bookingFrequencyList[12].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 12,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 13,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-12].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-12].toDouble(),
                        //                                     // fromY: bookingFrequencyList[12].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           BarChartGroupData(
                        //                               x: 13,
                        //                               // barsSpace: 10,
                        //                               barRods: [
                        //                                 BarChartRodData(
                        //                                   // fromY: 13,
                        //                                     fromY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-13].toDouble(),
                        //                                     toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-13].toDouble(),
                        //                                     // fromfromY:: bookingFrequencyList[12].toDouble(),
                        //                                     width: chartBarWidth,
                        //                                     color: Color.fromRGBO(17, 159, 250, 1),
                        //                                     borderRadius: BorderRadius.circular(5)
                        //                                 )
                        //                               ]
                        //                           ),
                        //                           // BarChartGroupData(
                        //                           //     x: 14,
                        //                           //     barRods: [
                        //                           //       BarChartRodData(
                        //                           //         fromfromY:: 9,
                        //                           //         width: chartBarWidth,
                        //                           //         color: Color.fromRGBO(17, 159, 250, 1),
                        //                           //         borderRadius: BorderRadius.circular(5),
                        //                           //
                        //                           //       )
                        //                           //     ]
                        //                           // ),
                        //                           // BarChartGroupData(
                        //                           //     x: 15,
                        //                           //     barRods: [
                        //                           //       BarChartRodData(
                        //                           //         // fromfromY:: 20,
                        //                           //           fromY: bookingFrequencyList[1].toDouble(),
                        //                           //           width: 15,
                        //                           //           color: Color.fromRGBO(17, 159, 250, 1),
                        //                           //           borderRadius: BorderRadius.circular(5)
                        //                           //       )
                        //                           //     ]
                        //                           // ),
                        //                         ]
                        //                     ),
                        //                   ),
                        //                 );
                        //               }
                        //               else if (snapshot.connectionState != ConnectionState.done){
                        //                 return Padding(
                        //                   padding: EdgeInsets.only(
                        //                       top: MediaQuery.of(context).size.height * 0.18
                        //                   ),
                        //                   child: const Center(
                        //                     child: CircularProgressIndicator(
                        //                       color: Colors.blue,
                        //                     ),
                        //                   ),
                        //                 );
                        //               }
                        //               else if(snapshot.connectionState == ConnectionState.done /*&& snapshot.hasData*/
                        //                   && socketProvider.bookingFrequencyList.isEmpty){
                        //                 return Padding(
                        //                   padding: EdgeInsets.only(
                        //                       top: MediaQuery.of(context).size.height * 0.18
                        //                   ),
                        //                   child: const Center(
                        //                     child: Text(
                        //                         "Nessuna prenotazione"
                        //                     ),
                        //                   ),
                        //                 );
                        //               }
                        //               else {
                        //                 return const SizedBox();
                        //               }
                        //             }
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Visibility(
                          visible: businessProvider.business?.type_id == 1,
                          child: Container(
                            height: 400,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: MediaQuery.of(context).size.width * 0.03
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Prenotazioni ricevute nell'ultimo periodo",
                                  // "Prenotazioni effettuate nell'ultimo periodo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 40,),
                                FutureBuilder(
                                  // future: Future.wait([e, f, b]),
                                    future: hu,
                                    // future: Future.wait([callFutureMethods1()]),
                                    builder: (context, snapshot) {
                                      if(snapshot.connectionState == ConnectionState.done /*&& snapshot.hasData*/
                                          && socketProvider.bookingFrequencyList.isNotEmpty){
                                        return Expanded(
                                          child: BarChart(
                                            BarChartData(
                                                borderData: FlBorderData(
                                                    border: Border.all(width: 0),
                                                    show: false
                                                ),
                                                groupsSpace: 15,
                                                // minfromY: 0,
                                                // maxfromY: 10,
                                                barTouchData: BarTouchData(
                                                  // touchCallback: (flTouchEvent, barTouchResponse){
                                                  //   print('ciao');
                                                  // },
                                                  // enabled: true
                                                ),
                                                titlesData: FlTitlesData(
                                                  show: true,
                                                  rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false
                                                    ),
                                                  ),
                                                  topTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false
                                                    ),
                                                  ),
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      reservedSize: 30,
                                                      interval: 15,
                                                      getTitlesWidget: (double value, TitleMeta meta) {
                                                        TextStyle style = const TextStyle(
                                                          color: Colors.black26,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 9.5,
                                                        );

                                                        double margin = MediaQuery.of(context).size.width * 0.015;

                                                        Widget textWidget(String text) => Padding(
                                                          padding: EdgeInsets.only(/*bottom: margin,*/ top: 8),
                                                          child: Text(
                                                            text,
                                                            textAlign: TextAlign.center,
                                                            style: style,
                                                          ),
                                                        );

                                                        String formattedDate(int daysAgo) {
                                                          DateTime date = DateTime.now().subtract(Duration(days: daysAgo));
                                                          String day = date.day.toString();
                                                          String? month = DateFormat.MMMM('it_IT').format(date).substring(0, 3).capitalizeFirst;
                                                          return '$day\n$month';
                                                        }

                                                        switch (value.toInt()) {
                                                          case 1:
                                                            return textWidget(formattedDate(12));
                                                          case 3:
                                                            return textWidget(formattedDate(10));
                                                          case 5:
                                                            return textWidget(formattedDate(8));
                                                          case 7:
                                                            return textWidget(formattedDate(6));
                                                          case 9:
                                                            return textWidget(formattedDate(4));
                                                          case 11:
                                                            return textWidget(formattedDate(2));
                                                          case 13:
                                                            return textWidget(formattedDate(0));
                                                          default:
                                                            return textWidget('');
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  leftTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        interval: 4.toDouble(),
                                                        // getTextStyles: (value, h) => const TextStyle(
                                                        //   color: Colors.black26,
                                                        //   fontWeight: FontWeight.bold,
                                                        //   fontSize: 11,
                                                        // ),
                                                        // // margin: 16,
                                                        // margin: MediaQuery.of(context).size.width * 0.015,
                                                        getTitlesWidget: (double value, TitleMeta meta) {
                                                          TextStyle style = const TextStyle(
                                                            color: Colors.black26,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                          );

                                                          double margin = MediaQuery.of(context).size.width * 0.015;

                                                          Widget textWidget(String text) => Padding(
                                                            padding: EdgeInsets.only(bottom: margin),
                                                            child: Text(
                                                              text,
                                                              style: style,
                                                            ),
                                                          );

                                                          // switch (value.toInt()) {
                                                          //   case 4:
                                                          //     return textWidget('4');
                                                          //   case 8:
                                                          //     return textWidget('8');
                                                          //   case 12:
                                                          //     return textWidget('12');
                                                          //   case 16:
                                                          //     return textWidget('16');
                                                          //   case 20:
                                                          //     return textWidget('20');
                                                          //   default:
                                                          //     return textWidget('');
                                                          // }
                                                          if(value > 0){
                                                            return textWidget(value.toInt().toString());
                                                          }
                                                          else {
                                                            return textWidget('');
                                                          }
                                                        },
                                                      )
                                                  ),
                                                ),
                                                gridData: FlGridData(
                                                  show: true,
                                                  drawHorizontalLine: false,
                                                  // getDrawingHorizontalLine: (value) {
                                                  //   return FlLine(
                                                  //     color: Colors.grey[400],
                                                  //     strokeWidth: .5,
                                                  //   );
                                                  // },
                                                  drawVerticalLine: false,
                                                  getDrawingVerticalLine: (value) {
                                                    return FlLine(
                                                      color: Colors.grey[400],
                                                      strokeWidth: 1,
                                                    );
                                                  },
                                                ),
                                                barGroups: [
                                                  BarChartGroupData(
                                                      x: 1,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: /*bookingFrequencyList.length > 0 ? */socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-1].toDouble()
                                                            /*: bookingFrequencyList[bookingFrequencyList.length].toDouble()*/,
                                                            // fromY: bookingFrequencyList[8].toDouble(),
                                                            width: chartBarWidth,
                                                            color: const Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 2,
                                                      barRods: [
                                                        BarChartRodData(
                                                          fromY: 0,
                                                          toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-2].toDouble(),
                                                          // fromY: bookingFrequencyList[8].toDouble(),
                                                          width: chartBarWidth,
                                                          color: Color.fromRGBO(17, 159, 250, 1),
                                                          borderRadius: BorderRadius.circular(5),
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 3,
                                                      barRods: [
                                                        BarChartRodData(
                                                          // fromY: 12,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-3].toDouble(),
                                                            fromY: 0,
                                                            // fromY: bookingFrequencyList[8].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 4,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-4].toDouble(),
                                                            // fromY: bookingFrequencyList[8].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 5,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-5].toDouble(),
                                                            // fromY: bookingFrequencyList[8].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 6,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-6].toDouble(),
                                                            // fromY: bookingFrequencyList[8].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 7,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-7].toDouble(),
                                                            // fromY: bookingFrequencyList[8].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 8,
                                                      barRods: [
                                                        BarChartRodData(
                                                          fromY: 0,
                                                          toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-8].toDouble(),
                                                          // fromY: bookingFrequencyList[9].toDouble(),
                                                          width: chartBarWidth,
                                                          color: Color.fromRGBO(17, 159, 250, 1),
                                                          borderRadius: BorderRadius.circular(5),
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 9,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-9].toDouble(),
                                                            // fromY: bookingFrequencyList[10].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 10,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-10].toDouble(),
                                                            // fromY: bookingFrequencyList[11].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 11,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-11].toDouble(),
                                                            // fromY: bookingFrequencyList[12].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 12,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-12].toDouble(),
                                                            // fromY: bookingFrequencyList[12].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  BarChartGroupData(
                                                      x: 13,
                                                      // barsSpace: 10,
                                                      barRods: [
                                                        BarChartRodData(
                                                            fromY: 0,
                                                            toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-13].toDouble(),
                                                            // fromY: bookingFrequencyList[12].toDouble(),
                                                            width: chartBarWidth,
                                                            color: Color.fromRGBO(17, 159, 250, 1),
                                                            borderRadius: BorderRadius.circular(5)
                                                        )
                                                      ]
                                                  ),
                                                  // BarChartGroupData(
                                                  //     x: 14,
                                                  //     barRods: [
                                                  //       BarChartRodData(
                                                  //         fromY: 9,
                                                  //         width: chartBarWidth,
                                                  //         color: Color.fromRGBO(17, 159, 250, 1),
                                                  //         borderRadius: BorderRadius.circular(5),
                                                  //
                                                  //       )
                                                  //     ]
                                                  // ),
                                                  // BarChartGroupData(
                                                  //     x: 15,
                                                  //     barRods: [
                                                  //       BarChartRodData(
                                                  //         // fromY: 20,
                                                  //           fromY: bookingFrequencyList[1].toDouble(),
                                                  //           width: 15,
                                                  //           color: Color.fromRGBO(17, 159, 250, 1),
                                                  //           borderRadius: BorderRadius.circular(5)
                                                  //       )
                                                  //     ]
                                                  // ),
                                                ]
                                            ),
                                          ),
                                        );
                                      }
                                      else if (snapshot.connectionState != ConnectionState.done){
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context).size.height * 0.18
                                          ),
                                          child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blue,
                                              )
                                          ),
                                        );
                                      }
                                      else if(snapshot.connectionState == ConnectionState.done /*&& snapshot.hasData*/
                                          && socketProvider.bookingFrequencyList.isEmpty){
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context).size.height * 0.18
                                          ),
                                          child: const Center(
                                            child: Text(
                                                "Nessuna prenotazione"
                                            ),
                                          ),
                                        );
                                      }
                                      else {
                                        return const SizedBox();
                                      }
                                    }
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),

                        Container(
                          height: 530,
                          // padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                    child: Text(
                                      'Ultime notifiche',
                                      style: TextStyle(
                                        color: Colors.black,
                                        // color: Colors.green[600],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              duration: const Duration(milliseconds: 500),
                                              alignment: Alignment.center,
                                              type: PageTransitionType.fade,
                                              child: NotificationsScreen()
                                            // child: TicketDetailScreen(
                                            //   user: widget.user,
                                            //   singleEventTicket: singleEventTicket,
                                            // ),
                                          )
                                      );
                                    },
                                    child: Padding(
                                      // padding: const EdgeInsets.only(
                                      //     left: 8.0,
                                      //   bottom: 0,
                                      //   top: 0,
                                      //   right: 8
                                      // ),
                                      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                      child: Text(
                                        // 'Show All',
                                        'Mostra',
                                        style: TextStyle(
                                          // color: Colors.black.withOpacity(0.5),
                                          color: Colors.blue[500],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: 16,
                              // ),

                              Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.all(16),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: socketProvider.notificationList.length < 6 ? socketProvider.notificationList.length : 6,
                                    itemBuilder: (context, index) {
                                      Booking? appun;
                                      for(Booking e in socketProvider.myAppointments){
                                        if(e.id == socketProvider.notificationList[index]['booking_id']){
                                          appun = e;
                                        }
                                      }

                                      // Appointment appointment = new Appointment(
                                      //   id: socketProvider.notificationList[index].id,
                                      //   isCanceled: socketProvider.notificationList[index].isCanceled,
                                      //   prestazione: new Prestazione(
                                      //     id: socketProvider.notificationList[index].prestazione.id,
                                      //     duration: socketProvider.notificationList[index].prestazione.duration,
                                      //     image: socketProvider.notificationList[index].prestazione.image,
                                      //     price: socketProvider.notificationList[index].prestazione.price,
                                      //     title: socketProvider.notificationList[index].prestazione.title,
                                      //     description: socketProvider.notificationList[index].prestazione.description,
                                      //     business_id: socketProvider.notificationList[index].prestazione.business_id,
                                      //   ),
                                      //   user: new User(
                                      //     email: socketProvider.notificationList[index].user.email,
                                      //     username: socketProvider.notificationList[index].user.username,
                                      //     name: socketProvider.notificationList[index].user.name,
                                      //     phone_number: socketProvider.notificationList[index].user.phone_number,
                                      //     profile_image: socketProvider.notificationList[index].user.profile_image,
                                      //     description: socketProvider.notificationList[index].user.description,
                                      //     id: socketProvider.notificationList[index].user.id,
                                      //   ),
                                      //   // business: new Business(
                                      //   //   image: myAppointments[index]['profile_image'],
                                      //   //   id: myAppointments[index]['business_id'],
                                      //   //   // is_booking_business: 1,
                                      //   //   name: myAppointments[index]['name'],
                                      //   //   address: myAppointments[index]['address'],
                                      //   //   phone_number: myAppointments[index]['phone_number'],
                                      //   //   // max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
                                      //   //
                                      //   // ),
                                      //   // begin_at: DateTime.tryParse(bookingList[index]['begin_at']),
                                      //   begin_at: socketProvider.notificationList[index].begin_at,
                                      //   // end_at: DateTime.tryParse(bookingList[index]['begin_at']).add(
                                      //   //   Duration(
                                      //   //       minutes: bookingList[index]['prestazione_duration'].toInt()
                                      //   //   )
                                      //   // ),
                                      //   end_at: socketProvider.notificationList[index].begin_at.add(
                                      //     Duration(
                                      //         minutes: socketProvider.notificationList[index].prestazione.duration.toInt()
                                      //     )
                                      //   ),
                                      //   // created_at: DateTime.tryParse(bookingList[index]['created_at']),
                                      //   created_at: socketProvider.notificationList[index].created_at
                                      // );

                                      print('socketProvider.notificationList[index]');
                                      print(socketProvider.notificationList[index]);

                                      return InkWell(
                                        onTap: (){
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  duration: const Duration(milliseconds: 500),
                                                  alignment: Alignment.center,
                                                  type: PageTransitionType.fade,
                                                  child: BookingDetailScreen(
                                                    booking: appun,
                                                  )
                                                // child: TicketDetailScreen(
                                                //   user: widget.user,
                                                //   singleEventTicket: singleEventTicket,
                                                // ),
                                              )
                                          );

                                          print(socketProvider.notificationList[index]);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 16),
                                          padding: const EdgeInsets.all(16 / 2),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          duration: const Duration(milliseconds: 500),
                                                          alignment: Alignment.center,
                                                          type: PageTransitionType.fade,
                                                          child: UserProfileScreen(
                                                            userId: socketProvider.notificationList[index]['user_id'],
                                                          )
                                                        // child: TicketDetailScreen(
                                                        //   user: widget.user,
                                                        //   singleEventTicket: singleEventTicket,
                                                        // ),
                                                      )
                                                  );

                                                  // print(socketProvider.notificationList[index]);
                                                  print('fg5gfgf5gf5gfgf5gf5gg5g5g');
                                                  print(socketProvider.notificationList[index]['user_profile_image']);
                                                  print(socketProvider.notificationList[index]['user_profile_image'] != 'null');
                                                  print(socketProvider.notificationList[index]['user_profile_image'] != null);
                                                  print(socketProvider.notificationList[index]['user_profile_image'] != '');
                                                },
                                                child: socketProvider.notificationList[index]['user_profile_image'] != null && socketProvider.notificationList[index]['user_profile_image'] != 'null' ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(40),
                                                  // child: Image.asset(
                                                  child: FutureImage(
                                                    // imageUrl: appointment.user.profile_image,
                                                    socketProvider.notificationList[index]['user_profile_image'] ?? '',
                                                    height: 45,
                                                    width: 45,
                                                  ),
                                                ) : Icon(
                                                  Icons.account_circle_rounded,
                                                  color: Colors.grey[300],
                                                  size: 55,
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      gw.GradientText(
                                                        // appointment.user.name,
                                                        // socketProvider.notificationList[index]['user_name'] ?? '',
                                                        socketProvider.notificationList[index]['user_name'] ?? "@${socketProvider.notificationList[index]['user_username']}",
                                                        // gradient: appointment.isCanceled == 0 ? LinearGradient(
                                                        gradient: socketProvider.notificationList[index]['is_canceled'] == 0 ? LinearGradient(
                                                            begin: Alignment.bottomLeft,
                                                            end: Alignment.topRight,
                                                            colors: [
                                                              // Color(0xff8921aa),
                                                              // Color(0xffDA44bb),
                                                              Colors.green[600]!,
                                                              Colors.green[600]!,
                                                            ]
                                                        ) : LinearGradient(
                                                            begin: Alignment.bottomLeft,
                                                            end: Alignment.topRight,
                                                            colors: [
                                                              // Colors.red[600],
                                                              // Colors.red[600],
                                                              Colors.red[900]!,
                                                              Colors.red[600]!,
                                                            ]
                                                        ),
                                                        style: TextStyle(
                                                          //   color: Colors.black,
                                                            color: Colors.green[600],
                                                            fontWeight: FontWeight.w600
                                                        ),
                                                      ),
                                                      Text(
                                                        // appointment.prestazione.title,
                                                        socketProvider.notificationList[index]['prestazione_title'],
                                                        style: TextStyle(
                                                            color: Colors.black.withOpacity(0.8),
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500
                                                        ),
                                                      ),
                                                      Text(
                                                        DateFormat.MMMMd('it_IT').format(DateTime.tryParse(socketProvider.notificationList[index]['booking_begin_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                                            + ' alle ' +
                                                            // socketProvider.notificationList[index]['booking_begin_at'].toString().substring(11, 16),
                                                            DateTime.tryParse(socketProvider.notificationList[index]['booking_begin_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                        style: TextStyle(
                                                            color: Colors.black.withOpacity(0.5),
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Icon(
                                              //   Icons.more_vert_rounded,
                                              //   color: Colors.black.withOpacity(0.5),
                                              //   size: 18,
                                              // )
                                              Text(
                                                // discussionData[index].booking,
                                                timeAgo.format(
                                                  // appointment.created_at,
                                                  // DateTime.tryParse(socketProvider.notificationList[index]['sent_at']),
                                                  DateTime.tryParse(socketProvider.notificationList[index]['sent_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
                                                  locale: 'it',
                                                ),
                                                // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                                                //     + ' alle ' +
                                                //     bookingList[index]['created_at'].toString().substring(11, 16),
                                                style: TextStyle(
                                                    color: Colors.black.withOpacity(0.5),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),

                        // Container(
                        //   height: 350,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   padding: EdgeInsets.all(16),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         'Users by device',
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: 15,
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ),
                        //       Container(
                        //         margin: EdgeInsets.all(16),
                        //         padding: EdgeInsets.all(16),
                        //         height: 230,
                        //         child: CustomPaint(
                        //           foregroundPainter: RadialPainter(
                        //             bgColor: Colors.black.withOpacity(0.1),
                        //             lineColor: Color.fromRGBO(17, 159, 250, 1),
                        //             // percent: 0.9,
                        //             percent: 1-(5/100*4.5),
                        //             // percent: (4.5*5/100),
                        //             width: 18.0,
                        //           ),
                        //           child: Center(
                        //             child: Text(
                        //               '70%',
                        //               // '4.5',
                        //               style: TextStyle(
                        //                 color: Colors.grey[500],
                        //                 fontSize: 34,
                        //                 fontWeight: FontWeight.w600,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(horizontal: 16),
                        //         child: Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 Icon(
                        //                   Icons.circle,
                        //                   color: Color.fromRGBO(17, 159, 250, 1),
                        //                   size: 10,
                        //                 ),
                        //                 SizedBox(width: 16 /2,),
                        //                 Text('Desktop',style: TextStyle(
                        //                   color: Colors.black.withOpacity(0.5),
                        //                   fontWeight: FontWeight.bold,
                        //                 ),)
                        //               ],
                        //             ),
                        //             Row(
                        //               children: [
                        //                 Icon(
                        //                   Icons.circle,
                        //                   color: Colors.black.withOpacity(0.2),
                        //                   size: 10,
                        //                 ),
                        //                 SizedBox(width: 16 /2,),
                        //                 Text('Mobile',style: TextStyle(
                        //                   color: Colors.black.withOpacity(0.5),
                        //                   fontWeight: FontWeight.bold,
                        //                 ),)
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),

                        // FutureBuilder(
                        //   future: g,
                        //   builder: (context, snapshot) {
                        //     return Container(
                        //       height: 530,
                        //       // padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        //       decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //             children: [
                        //               Padding(
                        //                 padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        //                 child: Text(
                        //                   // 'Clienti ',
                        //                   // 'Top 10 Clienti',
                        //                   'Clienti più frequenti',
                        //                   style: TextStyle(
                        //                     color: Colors.black,
                        //                     // color: Colors.green[600],
                        //                     fontWeight: FontWeight.w700,
                        //                     fontSize: 15,
                        //                   ),
                        //                 ),
                        //               ),
                        //               InkWell(
                        //                 onTap: (){
                        //                   Navigator.push(
                        //                       context,
                        //                       PageTransition(
                        //                           duration: const Duration(milliseconds: 500),
                        //                           alignment: Alignment.center,
                        //                           type: PageTransitionType.fade,
                        //                           child: BookingScreen()
                        //                       )
                        //                   );
                        //                 },
                        //                 child: Padding(
                        //                   // padding: const EdgeInsets.only(
                        //                   //     left: 8.0,
                        //                   //   bottom: 0,
                        //                   //   top: 0,
                        //                   //   right: 8
                        //                   // ),
                        //                   padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        //                   child: Text(
                        //                     // 'Show All',
                        //                     'Mostra',
                        //                     style: TextStyle(
                        //                       // color: Colors.black.withOpacity(0.5),
                        //                       color: Colors.blue[500],
                        //                       fontWeight: FontWeight.bold,
                        //                       fontSize: 13,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //           // SizedBox(
                        //           //   height: 16,
                        //           // ),
                        //
                        //           Expanded(
                        //             child: ListView.builder(
                        //                 padding: EdgeInsets.all(16),
                        //                 physics: NeverScrollableScrollPhysics(),
                        //                 shrinkWrap: true,
                        //                 itemCount: usersRankingList!.length < 6 ? usersRankingList!.length : 6,
                        //                 // itemBuilder: (context, index) => DiscussionInfoDetail(
                        //                 //   info: discussionData[index],
                        //                 // ),
                        //                 itemBuilder: (context, index) {
                        //                   User user = User(
                        //                     email: usersRankingList![index]['user_email'],
                        //                     username: usersRankingList![index]['user_username'],
                        //                     name: usersRankingList![index]['user_name'],
                        //                     phone_number: usersRankingList![index]['user_phone_number'],
                        //                     profile_image: usersRankingList![index]['user_profile_image'] ?? '',
                        //                     description: usersRankingList![index]['user_description'],
                        //                     id: usersRankingList![index]['user_id'],
                        //                   );
                        //
                        //                   return InkWell(
                        //                     onTap: (){
                        //
                        //                       Navigator.push(
                        //                           context,
                        //                           PageTransition(
                        //                               duration: const Duration(milliseconds: 500),
                        //                               alignment: Alignment.center,
                        //                               type: PageTransitionType.fade,
                        //                               child: UserProfileScreen(
                        //                                 user: user,
                        //                               )
                        //                             // child: TicketDetailScreen(
                        //                             //   user: widget.user,
                        //                             //   singleEventTicket: singleEventTicket,
                        //                             // ),
                        //                           )
                        //                       );
                        //                     },
                        //                     child: Container(
                        //                       margin: EdgeInsets.only(top: 16),
                        //                       padding: const EdgeInsets.all(16 / 2),
                        //                       child: Row(
                        //                         children: [
                        //                           ClipRRect(
                        //                             borderRadius: BorderRadius.circular(40),
                        //                             // child: Image.asset(
                        //                             child: FutureImage(
                        //                               // discussionData[index].imageSrc,
                        //                               // bookingList[index]['user_profile_image'],
                        //                               user.profile_image,
                        //                               height: 49,
                        //                               width: 49,
                        //                             ),
                        //                           ),
                        //                           Expanded(
                        //                             child: Padding(
                        //                               padding: const EdgeInsets.symmetric(horizontal: 16),
                        //                               child: Column(
                        //                                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                                 children: [
                        //                                   gw.GradientText(
                        //                                     user.username!,
                        //                                     // gradient: LinearGradient(
                        //                                     //     begin: Alignment.bottomLeft,
                        //                                     //     end: Alignment.topRight,
                        //                                     //     colors: [
                        //                                     //       Color(0xff8921aa),
                        //                                     //       Color(0xffDA44bb),
                        //                                     //     ]
                        //                                     // ),
                        //                                     style: TextStyle(
                        //                                         color: Colors.green[600],
                        //                                         fontWeight: FontWeight.w600
                        //                                     ),
                        //                                   ),
                        //                                   SizedBox(height: 2.5,),
                        //                                   Text(
                        //                                     user.name ?? '',
                        //                                     style: TextStyle(
                        //                                         color: Colors.grey[500],
                        //                                         fontWeight: FontWeight.w600,
                        //                                         fontSize: 12
                        //                                     ),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                           ),
                        //                           // Icon(
                        //                           //   Icons.more_vert_rounded,
                        //                           //   color: Colors.black.withOpacity(0.5),
                        //                           //   size: 18,
                        //                           // )
                        //                           Text(
                        //                             int.tryParse(usersRankingList![index]['ranking'].toString()).toString(),
                        //                             style: TextStyle(
                        //                                 color: Colors.black.withOpacity(0.6),
                        //                                 fontSize: 15,
                        //                                 fontWeight: FontWeight.w700
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   );
                        //                 }
                        //             ),
                        //           )
                        //         ],
                        //       ),
                        //     );
                        //   }
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),
                        //
                        // FutureBuilder(
                        //     future: l,
                        //     builder: (context, snapshot) {
                        //       return Container(
                        //         height: 560,
                        //         // padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        //         decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Padding(
                        //                   padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        //                   child: Text(
                        //                     // 'Clienti ',
                        //                     // 'Top 10 Clienti',
                        //                     'Prestazioni più acquistate',
                        //                     style: TextStyle(
                        //                       color: Colors.black,
                        //                       // color: Colors.green[600],
                        //                       fontWeight: FontWeight.w700,
                        //                       fontSize: 15,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 InkWell(
                        //                   onTap: (){
                        //                     Navigator.push(
                        //                         context,
                        //                         PageTransition(
                        //                             duration: const Duration(milliseconds: 500),
                        //                             alignment: Alignment.center,
                        //                             type: PageTransitionType.fade,
                        //                             child: PrestazioneScreen()
                        //                         )
                        //                     );
                        //                   },
                        //                   child: Padding(
                        //                     // padding: const EdgeInsets.only(
                        //                     //     left: 8.0,
                        //                     //   bottom: 0,
                        //                     //   top: 0,
                        //                     //   right: 8
                        //                     // ),
                        //                     padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        //                     child: Text(
                        //                       // 'Show All',
                        //                       'Mostra',
                        //                       style: TextStyle(
                        //                         // color: Colors.black.withOpacity(0.5),
                        //                         color: Colors.blue[500],
                        //                         fontWeight: FontWeight.bold,
                        //                         fontSize: 13,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             // SizedBox(
                        //             //   height: 16,
                        //             // ),
                        //
                        //             Expanded(
                        //               child: ListView.builder(
                        //                   padding: EdgeInsets.all(16),
                        //                   physics: NeverScrollableScrollPhysics(),
                        //                   shrinkWrap: true,
                        //                   itemCount: prestazioneRankingList!.length < 6 ? prestazioneRankingList!.length : 6,
                        //                   // itemBuilder: (context, index) => DiscussionInfoDetail(
                        //                   //   info: discussionData[index],
                        //                   // ),
                        //                   itemBuilder: (context, index) {
                        //                     Prestazione prestazione = Prestazione(
                        //                       id: prestazioneRankingList![index]['prestazione_id'],
                        //                       duration: prestazioneRankingList![index]['prestazione_duration'],
                        //                       image: prestazioneRankingList![index]['prestazione_image'],
                        //                       price: prestazioneRankingList![index]['prestazione_price'].toDouble(),
                        //                       title: prestazioneRankingList![index]['prestazione_title'],
                        //                       description: prestazioneRankingList![index]['prestazione_description'],
                        //                       business: Business(
                        //                           id: prestazioneRankingList![index]['business_id'],
                        //                           description: prestazioneRankingList![index]['business_description'],
                        //                           name: prestazioneRankingList![index]['business_name'],
                        //                           room_id: prestazioneRankingList![index]['business_room_id'],
                        //                           email: prestazioneRankingList![index]['business_email'],
                        //                           email_notification: prestazioneRankingList![index]['business_email_notification'],
                        //                           max_contemporary_appointments: prestazioneRankingList![index]['max_contemporary_appointments'],
                        //                           address: prestazioneRankingList![index]['business_address'],
                        //                           phone_number: prestazioneRankingList![index]['business_phone_number'],
                        //                           // is_booking_business: prestazioneRankingList![index]['is_booking_business'],
                        //                           profile_image: prestazioneRankingList![index]e['business_profile_image'] ?? '',
                        //                           latitude: prestazioneRankingList![index]['business_latitude'],
                        //                           longitude: prestazioneRankingList![index]['business_longitude'],
                        //                           categorfromY: Category(
                        //                             id: prestazioneRankingList![index]['category_id'],
                        //                             image: prestazioneRankingList![index]['category_image'],
                        //                             name: prestazioneRankingList![index]['category_name'],
                        //                           )
                        //                       ),
                        //                     );
                        //
                        //                     return InkWell(
                        //                       onTap: (){
                        //                         Navigator.push(
                        //                             context,
                        //                             PageTransition(
                        //                                 duration: const Duration(milliseconds: 500),
                        //                                 alignment: Alignment.center,
                        //                                 type: PageTransitionType.fade,
                        //                                 child: PrestazioneScreen()
                        //                             )
                        //                         );
                        //                       },
                        //                       child: Container(
                        //                         margin: EdgeInsets.only(top: 16),
                        //                         padding: const EdgeInsets.all(16 / 2),
                        //                         child: Row(
                        //                           children: [
                        //                             ClipRRect(
                        //                               borderRadius: BorderRadius.circular(8),
                        //                               child: FutureImage(
                        //                                 prestazione.image != null && prestazione.image != '' ? prestazione.image! : prestazione.business!.profile_image!,
                        //                                 width: 50,
                        //                                 height: 50,
                        //                               ),
                        //                             ),
                        //                             Expanded(
                        //                               child: Padding(
                        //                                 padding: const EdgeInsets.symmetric(horizontal: 16),
                        //                                 child: Column(
                        //                                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                                   children: [
                        //                                     gw.GradientText(
                        //                                       prestazione.title!,
                        //                                       gradient: LinearGradient(
                        //                                           begin: Alignment.bottomLeft,
                        //                                           end: Alignment.topRight,
                        //                                           colors: [
                        //                                             Color(0xff8921aa),
                        //                                             Color(0xffDA44bb),
                        //                                             // Color(0xffDA44bb)
                        //                                           ]
                        //                                       ),
                        //                                       style: TextStyle(
                        //                                           color: Colors.green[600],
                        //                                           fontWeight: FontWeight.w600
                        //                                       ),
                        //                                     ),
                        //                                     SizedBox(height: 2.5),
                        //                                     Text(
                        //                                       '€ ' + NumberFormat.currency(
                        //                                         // customPattern: '#,##',
                        //                                         decimalDigits: 2,
                        //                                         symbol: '',
                        //                                         locale: 'IT_it',
                        //                                         // symbol: '€'
                        //                                       ).format(prestazione.price),
                        //                                       style: TextStyle(
                        //                                           color: Colors.green[600],
                        //                                           fontWeight: FontWeight.w600,
                        //                                           fontSize: 12
                        //                                       ),
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                             // Icon(
                        //                             //   Icons.more_vert_rounded,
                        //                             //   color: Colors.black.withOpacity(0.5),
                        //                             //   size: 18,
                        //                             // )
                        //                             Text(
                        //                               int.tryParse(prestazioneRankingList![index]['ranking'].toString()).toString(),
                        //                               style: TextStyle(
                        //                                   color: Colors.black.withOpacity(0.6),
                        //                                   fontSize: 15,
                        //                                   fontWeight: FontWeight.w700
                        //                               ),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     );
                        //                   }
                        //               ),
                        //             )
                        //           ],
                        //         ),
                        //       );
                        //     }
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),

                        // SizedBox(
                        //   height: 16,
                        // ),
                      ],
                    ),
                  ),
                )
            );
          }
          else {
            return const SplashScreen();
          }
      }
    );
  }
}