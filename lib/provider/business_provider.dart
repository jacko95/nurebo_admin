import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/models/business_setting.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/login_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo_admin/main.dart';


class BusinessProvider extends ChangeNotifier {
  Business? business;
  final ImagePicker _imagePicker = ImagePicker();
  static const restartChannel = MethodChannel('com.nurebo.nurebo_admin/restart');


  Future getDateBusinessTimetable() async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/timetable");

    Map/*<String, String>*/ body = {
      'business_id': business!.id,
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

    // print('response.statusCode');
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
        business!.bookingBusinessTimetable = jsonData;
      // });

      // bookingBusinessTimetable.sort((a, b) {
      //   if(a['weekday_id'] == b['weekday_id']) {
      //     if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
      //       return int.tryParse(a['close_at_hour']).compareTo(int.tryParse(b['close_at_hour']));
      //     }
      //     return int.tryParse(a['open_at_hour']).compareTo(int.tryParse(b['open_at_hour']));
      //   }
      //   return a['weekday_id'].compareTo(b['weekday_id']);
      // });
      // businessProvider.business!.bookingBusinessTimetable!.sort((a, b) {
      //   if(a['weekday_id'] == b['weekday_id']) {
      //     if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
      //       if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
      //         if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
      //           return int.tryParse(a['close_at_minute'])!.compareTo(int.tryParse(b['close_at_minute'])!);
      //         }
      //         return int.tryParse(a['close_at_hour'])!.compareTo(int.tryParse(b['close_at_hour'])!);
      //       }
      //       return int.tryParse(a['open_at_minute'])!.compareTo(int.tryParse(b['open_at_minute'])!);
      //     }
      //     return int.tryParse(a['open_at_hour'])!.compareTo(int.tryParse(b['open_at_hour'])!);
      //   }
      //   return a['weekday_id'].compareTo(b['weekday_id']);
      // });

      // print('businessProvider.business.bookingBusinessTimetable olaaa');
      // print(businessProvider.business.bookingBusinessTimetable);

      notifyListeners();
      return jsonData;
    }
  }

  void deleteLocalTimetable() async {
    business!.bookingBusinessTimetable!.clear();
    notifyListeners();
  }

  Future deleteTimetable() async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/timetable");

    Map<String, dynamic> body = {
      'business_id': business!.id,
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // print('timetable delete');
      // print(jsonData);

      // business.bookingBusinessTimetable = jsonData;
      business!.bookingBusinessTimetable!.clear();

      // business.bookingBusinessTimetable.sort((a, b) {
      //   if(a['weekday_id'] == b['weekday_id']) {
      //     if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
      //       if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
      //         if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
      //           return int.tryParse(a['close_at_minute']).compareTo(int.tryParse(b['close_at_minute']));
      //         }
      //         return int.tryParse(a['close_at_hour']).compareTo(int.tryParse(b['close_at_hour']));
      //       }
      //       return int.tryParse(a['open_at_minute']).compareTo(int.tryParse(b['open_at_minute']));
      //     }
      //     return int.tryParse(a['open_at_hour']).compareTo(int.tryParse(b['open_at_hour']));
      //   }
      //   return a['weekday_id'].compareTo(b['weekday_id']);
      // });

      // await Fluttertoast.showToast(
      //   msg: 'Orari di Apertura Aggiornati',
      //   backgroundColor: Colors.grey[700],
      // );
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(
      //         'Prenotazione inserita',
      //       ),
      //       backgroundColor: Colors.green,
      //     )
      // );
      const SnackBar snackBar = SnackBar(
        content: Text(
          'Orari aggiornati',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);

      notifyListeners();
      return jsonData;
    }

    notifyListeners();
  }

  Future getBusinessSettings(/*Business? business*/) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business/payments");
    var url = Uri.parse("${Utils.httpServerUrl}business/${BusinessPreferences.getBusinessId()}/setting");

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

      print('d5df6dfdf65gg8gvgv8vg8');
      // print(jsonData);
      // print(jsonData[0]);

      if(jsonData.length > 0){
        business?.businessSetting = BusinessSetting(
          chat_notification: jsonData[0]['chat_notification'] ?? 1,
          // chat_notification: jsonData['chat_notification'] ?? 1,
          email_notification: jsonData[0]['email_notification'] ?? 1,
          // email_notification: jsonData['email_notification'] ?? 1,
        );
      }
      // for(var e in jsonData){
      //
      // }

      print(business!.businessSetting?.chat_notification);
      print(business!.businessSetting?.email_notification);

      notifyListeners();
      return jsonData;
    }
  }

  Future updateOpenDatetime(BuildContext context, int i) async {
    TimeOfDay initialTime = TimeOfDay(
        hour: int.tryParse(/*businessProvider.*/business!.bookingBusinessTimetable![i]['open_at_hour'])!,
        minute: int.tryParse(/*businessProvider.*/business!.bookingBusinessTimetable![i]['open_at_minute'])!
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

    // setState(() {
      /*businessProvider.*/business!.bookingBusinessTimetable![i]['open_at_hour'] = newTime.hour.toString();
      /*businessProvider.*/business!.bookingBusinessTimetable![i]['open_at_minute'] = newTime.minute.toString();
    // });
  }

  Future updateCloseDatetime(BuildContext context, int i) async {
    TimeOfDay initialTime = TimeOfDay(
        hour: int.tryParse(/*businessProvider.*/business!.bookingBusinessTimetable![i]['close_at_hour'])!,
        minute: int.tryParse(/*businessProvider.*/business!.bookingBusinessTimetable![i]['close_at_minute'])!
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

    // setState(() {
      /*businessProvider.*/business!.bookingBusinessTimetable![i]['close_at_hour'] = newTime.hour.toString();
      /*businessProvider.*/business!.bookingBusinessTimetable![i]['close_at_minute'] = newTime.minute.toString();
    // });

    notifyListeners();
  }

  Future updateTimetable(List bookingBusinessTimetable) async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/timetable");

    // Map<String, dynamic> body = {
    //   'business_id': businessId,
    // };

    var response = await http.put(
        url,
        // body: jsonEncode(body),
        // body: jsonEncode(/*businessProvider.*/business.bookingBusinessTimetable),
        body: jsonEncode(/*businessProvider.*//*business.*/bookingBusinessTimetable),
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
      // print('ghghfdbsdvbsbfbf');
      // print(jsonData);

      business!.bookingBusinessTimetable = jsonData;

      business!.bookingBusinessTimetable!.sort((a, b) {
        if(a['weekday_id'] == b['weekday_id']) {
          if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
            if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
              if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
                return int.tryParse(a['close_at_minute'])!.compareTo(int.tryParse(b['close_at_minute'])!);
              }
              return int.tryParse(a['close_at_hour'])!.compareTo(int.tryParse(b['close_at_hour'])!);
            }
            return int.tryParse(a['open_at_minute'])!.compareTo(int.tryParse(b['open_at_minute'])!);
          }
          return int.tryParse(a['open_at_hour'])!.compareTo(int.tryParse(b['open_at_hour'])!);
        }
        return a['weekday_id'].compareTo(b['weekday_id']);
      });

      // await Fluttertoast.showToast(
      //   msg: 'Orari di Apertura Aggiornati',
      //   backgroundColor: Colors.grey[700],
      // );
      final SnackBar snackBar = SnackBar(
        content: Text(
          'Orari aggiornati',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);

      notifyListeners();
      return jsonData;
    }
    else if(response.statusCode == 466){
      final SnackBar snackBar = SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              response.body,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // backgroundColor: Colors.red,
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      business!.bookingBusinessTimetable = bookingBusinessTimetable;
      notifyListeners();
      return bookingBusinessTimetable;
    }

    notifyListeners();
  }

  Future<XFile> selectProfileImage() async {
    final XFile selected = (await _imagePicker.pickImage(source: ImageSource.gallery))!;
    if (selected.path.isEmpty) {
      // print(selected.path.toString());
      // _imageList.add(selected);
    }
    // setState(() {
    //   // _image = File(pickedImage.path);
    //   _imageList.add(selected);
    // });
    return selected;
  }

  Future uploadProfileImage(/*XFile _image*/) async {
    XFile _image = await selectProfileImage();

    String imageName = _image.path.split('/').last;
    // List<int> imageBytes = File(filePath.path).readAsBytesSync();

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(Utils.httpServerUrl + "business/profile_image")
    );

    String imageMimeType = lookupMimeType(_image.path)!;
    // print('imageMimeType');
    // print(imageMimeType);

    request.files.add(
        await http.MultipartFile.fromPath(
            'image',
            // imageFilePath,
            _image.path,
            filename: '${imageName.split('image_picker').last}',
            // contentType: new MediaType('image', 'jpeg')
            // contentType: new MediaType('image', 'png')
            contentType: new MediaType(
                imageMimeType.split('/').first,
                imageMimeType.split('/').last
            )
        )
    );
    // request.files.add(
    //   http.MultipartFile.fromBytes(
    //     'image',
    //     _imageFile.readAsBytesSync(),
    //     filename: '$imageName',
    //     // contentType: new MediaType('image', 'jpeg')
    //     contentType: new MediaType('image', 'png')
    //     // contentType: new MediaType('image', 'jpg')
    //   )
    // );

    // http.MultipartFile.fromString(
    //   'image',
    //   _imageFile.path,
    //   filename: '$imageName',
    // );

    request.headers.addAll({
      'Accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Accept-encoding': 'gzip, deflate',
    });
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = '*/*';
    // request.headers['Accept-encoding'] = 'gzip, deflate';
    // request.fields['file'] = name;

    request.fields['user_id'] = business!.id!;
    var res = await request.send();
    if(res.statusCode == 200){
      business!.profile_image = 'http://192.168.1.225/nurebo-server/posts/${imageName.split('image_picker').last}';
      Fluttertoast.showToast(
        msg: 'Immagine Profilo aggiornata',
        backgroundColor: Colors.grey[700],

      );
    }
    notifyListeners();
    return res.statusCode;
  }

  Future<void> _restartApp() async {
    try {
      await restartChannel.invokeMethod('restartApp');
    } on PlatformException catch (e) {
      print("Failed to restart app: '${e.message}'.");
    }
  }

  Future logout(context, [bool? isManual]) async {
    SocketProvider socketProvider = Provider.of<SocketProvider>(context, listen: false);
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // print('BusinessPreferences.getUserToken()');
    // print(BusinessPreferences.getBusinessToken());

    var splitToken = BusinessPreferences.getBusinessToken()!.split('.');
    // print(splitToken);
    String decodedHeader = utf8.fuse(base64).decode(base64.normalize(splitToken[0]));
    String decodedPayload = utf8.fuse(base64).decode(base64.normalize(splitToken[1]));
    // String decodedSignature = utf8.fuse(base64).decode(splitToken[2]);
    // print(decodedHeader);
    // print(decodedPayload);
    // print(decodedSignature);
    Map authId = jsonDecode(utf8.fuse(base64).decode(base64.normalize(splitToken[1])));
    // print("authId['id']");
    // print(authId['id']);

    // var url = Uri.parse(Utils.httpServerUrl + "business_authentication/logout");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/authentication/${authId['id']}/logout");

    Map body = {
      "auth_id": authId['id'],
      "business_id": business!.id,
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
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!,
        }
    );

    // print("response.statusCode:");
    // print(response.statusCode);

    // if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
    //   // if (!mounted) return;
    //   // await businessProvider.logout(context);
    //
    //   Fluttertoast.showToast(
    //     msg: 'Autenticazione scaduta',
    //     backgroundColor: Colors.grey[700],
    //   );
    // }
    /*else*/ if(response.statusCode >= 200 && response.statusCode < 400) {
      // Scaffold.of(context).openEndDrawer();
      // if(socketProvider.socket != null){
      //   if(socketProvider.socket.connected){
      //     // socketProvider.socket.disconnect();
      //     // socketProvider.socket.close();
      //     socketProvider.socket.destroy();
      //   }
      // }

      // print('socketProvider.socket.id');
      // print(socketProvider.socket.id);
      // print('business.id');
      // print(business!.id);

      // socketProvider.removeUserSocket(
      //     businessProvider.user.id,
      //     socketProvider.socket.id
      // );

      // await BusinessPreferences.init();
      await BusinessPreferences.setIsLogged(false);
      await BusinessPreferences.setBusinessId('');
      await BusinessPreferences.setBusinessToken('');

      socketProvider.socket.emit(
          "remove_user_socket",
          {
            "userId": businessProvider.business!.id,
            "socketId": socketProvider.socket.id,
          }
      );

      // businessProvider.setUser(null);
      emptyBusiness();

      // FlutterBackgroundService().sendData({"action": "stopService"},);
      // if((await FlutterBackgroundService().isServiceRunning()) == true){
      // if((await FlutterBackgroundService().isRunning()) == true){
      //   // FlutterBackgroundService().sendData({"action": "stopService"},);
      //   FlutterBackgroundService().invoke("stopService");
      // }

      if(isManual == null || isManual == false) {
        Fluttertoast.showToast(
          msg: 'Autenticazione scaduta',
          backgroundColor: Colors.grey[700],
        );
      }

      // await Navigator.pushAndRemoveUntil(
      //     context,
      //     PageTransition(
      //       child: LoginScreen(),
      //       type: PageTransitionType.fade,
      //       duration: Duration(milliseconds: 500),
      //     ),
      //         (route) => false
      //   // (route) => true
      // );

      // Get.offAll(() => const Main());
      // Get.offAll(() => LoginScreen());
      await _restartApp();

      // Get.reset();
      // Get.to(const Main());

      /*await SystemChannels.platform.invokeMethod('SystemNavigator.pop')*//*.then((value) => Phoenix.rebirth(context))*//*;
      return exit(0);*/
      // Phoenix.rebirth(context);
    }
  }

  setBusiness(Business? business){
    this.business = business;
    notifyListeners();
  }

  emptyBusiness(){
    business = Business();
    notifyListeners();
  }

  //todo: sono tutti da settare con chiamata http

  setphone(String phone){
    this.business!.phone = phone;
    notifyListeners();
  }

  setMaxContemporaryAppointments(int? maxContemporaryAppointments){
    business!.max_contemporary_appointments = maxContemporaryAppointments;
    notifyListeners();
  }

  setEmail(String email){
    this.business!.email = email;
    notifyListeners();
  }

  setProfileImage(String profileImage){
    business!.profile_image = profileImage;
    notifyListeners();
  }

  updateEmailNotification(int emailNotification){
    // business!.email_notification = emailNotification;
    business!.businessSetting?.email_notification = emailNotification;
    notifyListeners();
  }

  updateChatNotification(int chatNotification){
    business!.businessSetting?.chat_notification = chatNotification;
    notifyListeners();
  }

  setDescription(String description){
    business!.description = description;
    notifyListeners();
  }

  setName(String name){
    business!.name = name;
    notifyListeners();
  }

}
