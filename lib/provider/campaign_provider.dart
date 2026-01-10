import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/booking_post.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign.dart';
import 'package:nurebo_admin/models/business_campaign_type.dart';
import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/post_like.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/models/user_device.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/screens/campaign_user_preview_list_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CampaignProvider extends ChangeNotifier {
  static final ImageCacheBusiness cacheBusiness = ImageCacheBusiness();
  List businessCampaignList = [];
  List<BusinessCampaignType> campaignTypeList = [];
  List<UserDevice> userDeviceCampaignList = [];
  late BusinessCampaignType businessCampaignType;
  List<User> campaignUserPreviewList = [];
  File? file;
  String? title;
  String? body;
  int campaignThisWeek = 0;


  void deleteAll(){
    userDeviceCampaignList.clear();
    notifyListeners();
  }

  Future getAllBusinessCampaignTypes(BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/campaign/type");

    // Map<String, String?> body = {
    //   // 'event_business_id': widget.eventBusiness.id,
    //   'business_id': businessId,
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
          'X-Client-Type': 'Business-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print('response.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      campaignTypeList.clear();

      for(var e in jsonData){
        campaignTypeList.add(
            BusinessCampaignType(
              id: e['id'],
              icon: e['icon'],
              icon_size: e['icon_size']?.toDouble(),
              title: e['title'],
              description: e['description'],
              created_at: DateTime.tryParse(e['created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            )
        );
      }

      // print('postList.length');
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future getAllBusinessCampaign(BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/campaign");

    // Ottieni la data attuale e il giorno della settimana
    final DateTime now = DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/;
    final int currentDayOfWeek = now.weekday;
    // Calcola la differenza di giorni per raggiungere l'ultimo lunedì
    final int daysUntilLastMonday = (currentDayOfWeek + 6) % 7;
    // Calcola la data dell'ultimo lunedì
    final DateTime lastMonday = now.subtract(Duration(days: daysUntilLastMonday));
    // Combina la data dell'ultimo lunedì con l'orario di mezzanotte
    final DateTime midnightLastMonday = DateTime(
      lastMonday.year,
      lastMonday.month,
      lastMonday.day,
      0,
      0,
      0,
    );
    print('midnightLastMonday');
    print(midnightLastMonday);
    // Map<String, String?> body = {
    //   // 'event_business_id': widget.eventBusiness.id,
    //   'business_id': businessId,
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
          'X-Client-Type': 'Business-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print('response.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      businessCampaignList.clear();

      // businessCampaignList = jsonData;
      for(var e in List.from(jsonData)){
        // businessCampaignList.addIf(
        //     DateTime.tryParse(e['created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAfter(midnightLastMonday),
        //     e
        //   // BusinessCampaignType(
        //   //   id: e['id'],
        //   //   icon: e['icon'],
        //   //   icon_size: e['icon_size'].toDouble(),
        //   //   title: e['title'],
        //   //   description: e['description'],
        //   //   created_at: DateTime.tryParse(e['created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
        //   // )
        // );
        businessCampaignList.add(e);
      }

      campaignThisWeek = 0;
      for(var e in businessCampaignList){
        if(DateTime.tryParse(e['created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAfter(midnightLastMonday)){
          campaignThisWeek++;
        }
      }

      print('jsonG6GG6G6G6G');
      print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  void setNotificationCampaign({required String? title, required String? body, required File? file}){
    this.title = title;
    this.body = body;
    this.file = file;
    notifyListeners();
  }

  Future sendCampaignNotification({
    // required String businessId,
    required String notificationTitle,
    required String notificationBody,
    required BusinessCampaignType businessCampaignType,
    File? uploadImage,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    var request = http.MultipartRequest(
        'POST',
        // Uri.parse(Utils.httpServerUrl + "prestazione")
        Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/campaign/device?campaign_type_id=${businessCampaignType.id}")
    );

    if(uploadImage != null) {
      String imageName = uploadImage.path.split('/').last;
      // List<int> imageBytes = File(filePath.path).readAsBytesSync();

      String imageMimeType = lookupMimeType(uploadImage.path)!;
      // print('imageMimeType');
      // print(imageMimeType);

      request.files.add(
          await http.MultipartFile.fromPath(
              'image',
              // imageFilePath,
              // uploadImage.path,
              file!.path,
              filename: '${imageName.split('image_picker').last}',
              // contentType: new MediaType('image', 'jpeg')
              // contentType: new MediaType('image', 'png')
              // contentType: MediaType(
              //     imageMimeType.split('/').first,
              //     imageMimeType.split('/').last
              // )
              contentType: MediaType.parse(imageMimeType)
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
    }

    request.headers.addAll({
      'Accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Accept-encoding': 'gzip, deflate',
      'connection': 'keep-alive',
      'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
      'X-App-Version-Name': Utils.version_name,
      'X-App-Version-Number': Utils.version_id.toString(),
      'X-Client-Type': 'Business-Mobile-App',
      HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
    });
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = '*/*';
    // request.headers['Accept-encoding'] = 'gzip, deflate';
    // request.fields['file'] = name;

    // Map userDeviceCampaignJsonList = {};
    // for (var element in userDeviceCampaignList.) {
    //   userDeviceCampaignJsonList.addIf(true, element.toJson().k, );
    // }
    List<Map<String, dynamic>> userDeviceCampaignJsonList = userDeviceCampaignList.map((oggetto) => oggetto.toJson()).toList();
    print('userDeviceCampaignJsonList');
    print(userDeviceCampaignJsonList);

    print('titlef5gg65g6');
    print(title);

    Map<String, String> body = {
      "title": title ?? '',
      "body": this.body ?? '',
      "user_device": jsonEncode(userDeviceCampaignJsonList)
    };
    request.fields.addAll(body);

    var res = await request.send();

    // print(res.statusCode.toString());

    if(res.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    else if(res.statusCode == 200){
      // var jsonData = json.decode(response.body);
      var resData = await res.stream.bytesToString();
      var jsonData = json.decode(resData);

      // print('res.statusCode');
      // print(res.statusCode);
      // print('res.stream.bytesToString()');
      // print(await res.stream.bytesToString());
      // print(json.decode(g)['Location']);
      // print(jsonData);

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();

    }
    else {
      Fluttertoast.showToast(
        msg: await res.stream.bytesToString(),
        backgroundColor: Colors.grey[700],
      );
    }

    return res.statusCode;
    // return json.decode(g);
  }

  Future getAllCampaignPreviewUsers(/*BusinessCampaignType campaignType,*/ BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/post_id");
    // var url = Uri.parse("${Utils.httpServerUrl}booking/post/${widget.post!.id}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/campaign/type/${businessCampaignType.id}/user");
    // var userProvider = Provider.of<UserProvider>(context);

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.post!.id,
    //   // 'text': commentController.text,
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
        }
    );

    //print("postcomment getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    else if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // comments = jsonData;
      userDeviceCampaignList.clear();

      // print('jsonDataf5gg5');
      // print(jsonData);

      for(var e in jsonData){
        // print('ef5g6bb6b6666');
        // print(e);

        UserDevice userDevice = UserDevice(
          id: e['device_id'],
          model: e['device_model'],
          manufacturer: e['device_manufacturer'],
          fcm_token: e['fcm_token'],
          user: User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image' ?? ''] ?? '',
            description: e['user_description'],
            // fcm_token: e['fcm_token'],
          )
        );

        userDeviceCampaignList.add(
            userDevice
        );
      }

      Set seen = <String?>{};
      campaignUserPreviewList = userDeviceCampaignList.map((userDevice) => userDevice.user!).toList().where((user) => seen.add(user.id)).toList();

      // print('userCampaignList.length');
      // print(userDeviceCampaignList.length);
      // print('userList.length');
      // print(userList.length);
      // for(User element in userList) {
      //   print(element.toJson());
      // }

      // Navigator.push(
      //     context,
      //     PageTransition(
      //         duration: const Duration(milliseconds: 500),
      //         alignment: Alignment.center,
      //         type: PageTransitionType.fade,
      //         // child: CampaignNotificationScreen(
      //         //   // campaignType: _selectedItemIndex,
      //         //   campaignType: campaignTypeList[_selectedItemIndex],
      //         // )
      //         child: const CampaignUserListScreen()
      //     )
      // );

      notifyListeners();
      return jsonData;
    }
  }

  Future getAllCampaignUsers(/*BusinessCampaignType campaignType,*/BusinessCampaign businessCampaign, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/campaign/${businessCampaignType.id}/user");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/campaign/${businessCampaign.id}/user");
    // var userProvider = Provider.of<UserProvider>(context);

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.post!.id,
    //   // 'text': commentController.text,
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
        }
    );

    //print("postcomment getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    else if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // comments = jsonData;
      userDeviceCampaignList.clear();

      // print('jsonDataf5gg5');
      // print(jsonData);

      for(var e in jsonData){
        // print('ef5g6bb6b6666');
        // print(e);

        UserDevice userDevice = UserDevice(
            is_open: e['is_open'].toInt(),

            id: e['device_id'],
            model: e['device_model'],
            manufacturer: e['device_manufacturer'],
            fcm_token: e['fcm_token'],
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image' ?? ''] ?? '',
              description: e['user_description'],
              // fcm_token: e['fcm_token'],
            )
        );

        userDeviceCampaignList.add(
            userDevice
        );
      }

      Set seen = <String?>{};
      campaignUserPreviewList = userDeviceCampaignList.map((userDevice) => userDevice.user!).toList().where((user) => seen.add(user.id)).toList();

      // print('userCampaignList.length');
      // print(userDeviceCampaignList.length);
      // print('userList.length');
      // print(userList.length);
      // for(User element in userList) {
      //   print(element.toJson());
      // }

      // Navigator.push(
      //     context,
      //     PageTransition(
      //         duration: const Duration(milliseconds: 500),
      //         alignment: Alignment.center,
      //         type: PageTransitionType.fade,
      //         // child: CampaignNotificationScreen(
      //         //   // campaignType: _selectedItemIndex,
      //         //   campaignType: campaignTypeList[_selectedItemIndex],
      //         // )
      //         child: const CampaignUserListScreen()
      //     )
      // );

      // notifyListeners();
      return jsonData;
    }
  }
}
