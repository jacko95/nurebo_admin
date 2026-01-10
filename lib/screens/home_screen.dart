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
import 'package:nurebo_admin/widgets/navigation_drawer.dart';
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

    return RefreshIndicator(
      edgeOffset: 60,
      // strokeWidth: 5,
      // displacement: 200,
      // triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        socketProvider.businessReservationList.clear();
        /*await*/ Future.wait([
          socketProvider.getBusinessReservations(),
          // all = futureBuilderMethods(),

        ]);
        // print('socketProvider.myAppointments.length1');
        // print(socketProvider.myAppointments.length);
      },
      child: FutureBuilder(
        future: all,
          initialData: const [],
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                // backgroundColor: Colors.white,
                //   backgroundColor: Color.fromRGBO(247, 251, 254, 1),
                //   backgroundColor: Colors.blue[100],
                  backgroundColor: Colors.green[100],
                  // drawer: NureboAdminDrawer(),
                  drawer: NavigationDrawerWidget(/*business: businessProvider.business,*/),
                  // endDrawer: NavigationDrawerWidget(),
                  appBar: AppBar(
                    // centerTitle: true,

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
                        // SizedBox(width: 30,),
                      ],
                    ),
                    // actions: [
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    //     child: Icon(
                    //       // Icons.notifications_none,
                    //       Icons.logout,
                    //       size: 28,
                    //       color: Colors.grey[600],
                    //     ),
                    //   )
                    //   // SizedBox(height: 0,)
                    // ],
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
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Expanded(
                          child: ListView.builder(
                              // padding: EdgeInsets.all(16),
                              padding: EdgeInsets.only(bottom: 16),
                              // physics: NeverScrollableScrollPhysics(),

                              shrinkWrap: true,
                              itemCount: socketProvider.businessReservationList.length,
                              itemBuilder: (context, index) {
                                // Booking? appun;
                                // for(Booking e in socketProvider.myAppointments){
                                //   if(e.id == socketProvider.notificationList[index]['booking_id']){
                                //     appun = e;
                                //   }
                                // }

                                return InkWell(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(milliseconds: 500),
                                            alignment: Alignment.center,
                                            type: PageTransitionType.fade,
                                            child: ReservationDetailScreen(
                                              reservation: socketProvider.businessReservationList[index],
                                            )
                                        )
                                    );

                                  },
                                  child: Container(
                                    // color: Colors.white,
                                    margin: EdgeInsets.only(top: 16, left: 8, right: 8),
                                    padding: const EdgeInsets.only(
                                      right: 24, left: 12, bottom: 24, top: 24
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Card(
                                              semanticContainer: true,
                                              // color: Colors.grey[100],
                                              // color: socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null ? Colors.green[100] : Colors.red[100],
                                              color: (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null) /*&& socketProvider.businessReservationList[index].validated_at != null*/ && socketProvider.businessReservationList[index].proposal == null
                                                  ? Colors.green[100]
                                                  : socketProvider.businessReservationList[index].proposal != null && (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null)
                                                  ? Colors.orange[100]
                                                  : Colors.red[100],
                                              // color: Colors.green[100],
                                              // color: Colors.red[100],
                                              // color: Colors.orange[100],
                                              margin: EdgeInsets.all(0),
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(50.0),
                                              ),
                                              elevation: 0,
                                              // margin: EdgeInsets.all(0),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: 6,
                                                  bottom: 6,
                                                  left: 10,
                                                  right: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    // SizedBox(width: 5),
                                                    RichText(
                                                      text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                // text: 'Confermato',
                                                                // text: 'Annullato',
                                                                // text: 'In Attesa di Convalida',
                                                                // text: 'Da Convalidare',
                                                                text: (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null) && socketProvider.businessReservationList[index].proposal == null
                                                                    ? 'Confermato'
                                                                    : socketProvider.businessReservationList[index].proposal != null && socketProvider.businessReservationList[index].proposal?.user_type_id == 2 && (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null)
                                                                    ? 'Da Convalidare'
                                                                    : socketProvider.businessReservationList[index].proposal != null && socketProvider.businessReservationList[index].proposal?.user_type_id == 1 && (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null)
                                                                    ? 'In Attesa di Convalida'
                                                                    : 'Annullato',
                                                                style: GoogleFonts.roboto(
                                                                    fontWeight: FontWeight.w700,
                                                                    // color: Colors.grey[600],
                                                                    // color: Colors.green[600],
                                                                    // color: Colors.red[600],
                                                                    // color: Colors.orange[600],
                                                                    color: (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null) && socketProvider.businessReservationList[index].proposal == null
                                                                        ? Colors.green[600]
                                                                        : socketProvider.businessReservationList[index].proposal != null && (socketProvider.businessReservationList[index].is_canceled == false || socketProvider.businessReservationList[index].is_canceled == null)
                                                                        ? Colors.orange[600]
                                                                        : Colors.red[600],
                                                                    fontSize: 12
                                                                )
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        duration: const Duration(milliseconds: 500),
                                                        alignment: Alignment.center,
                                                        type: PageTransitionType.fade,
                                                        // child:
                                                    )
                                                );
                                              },
                                              child: Icon(
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
                                                      // socketProvider.businessReservationList[index].name!,
                                                      socketProvider.businessReservationList[index].business_url!,
                                                      gradient: LinearGradient(
                                                          begin: Alignment.bottomLeft,
                                                          end: Alignment.topRight,
                                                          colors: [
                                                            // Color(0xff8921aa),
                                                            // Color(0xffDA44bb),

                                                            // Colors.green[600]!,
                                                            // Colors.green[600]!,

                                                            Colors.blue[600]!,
                                                            Colors.blue[600]!,
                                                          ]
                                                      ),
                                                      style: TextStyle(
                                                        //   color: Colors.black,
                                                          color: Colors.green[600],
                                                          fontWeight: FontWeight.w600,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        // Icon(
                                                        //   Icons.person,
                                                        //   color: Colors.grey[700],
                                                        // ),
                                                        Text(
                                                          // appointment.prestazione.title,
                                                          // socketProvider.notificationList[index]['prestazione_title'],
                                                          "${socketProvider.businessReservationList[index].quantity!.toString()} coperti",
                                                          style: TextStyle(
                                                              color: Colors.black.withOpacity(0.8),
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        // Icon(
                                                        //   Icons.access_time,
                                                        //   color: Colors.grey[700],
                                                        // ),
                                                        Text(
                                                          //todo: qui va messo l  ultimo
                                                          socketProvider.businessReservationList[index].datetime != null ? DateFormat.MMMMd('it_IT').format(DateTime.tryParse(socketProvider.businessReservationList[index].datetime.toString()) ?? DateTime(0)) + " alle " + (DateTime.tryParse(socketProvider.businessReservationList[index].datetime.toString()) ?? DateTime(0)).toString().substring(11, 16) : "Non Convalidato",
                                                          style: TextStyle(
                                                              color: Colors.black.withOpacity(0.5),
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500
                                                          ),
                                                        ),
                                                      ],
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
                                              textAlign: TextAlign.center,
                                              timeAgo.format(
                                                // appointment.created_at,
                                                // DateTime.tryParse(socketProvider.notificationList[index]['sent_at']),
                                                DateTime.tryParse(socketProvider.businessReservationList[index].last_edit_at.toString())!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
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
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  )
              );
            }
            else {
              return const SplashScreen();
            }
        }
      ),
    );
  }
}