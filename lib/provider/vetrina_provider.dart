import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:provider/provider.dart';

class VetrinaProvider extends ChangeNotifier {
  // List<Post> postList = [];
  // List<User> userOrderList = [];
  // ImageCacheBusiness cacheBusiness = ImageCacheBusiness();
  // List<Prestazione> bestsellersList = [];
  List<Prestazione> recommendedList = [];


  void deleteAll(){
    recommendedList.clear();
    notifyListeners();
  }

  Future getAllRecommendedPrestazione(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione/recommended");

    Map<String, String?> body = {
      // 'event_business_id': widget.eventBusiness.id,
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

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDatag5gfgf5gf5');
      // print(jsonData);

      // prestazioneList = jsonData;

      print("5gg5bb5bn5n5n5n555");
      print(jsonData);
      for(var e in jsonData){
        recommendedList.add(
          Prestazione(
            duration: e['prestazione_duration'],
            id: e['prestazione_id'],
            image: e['prestazione_image'],
            is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
            price: (e['prestazione_price'] ?? 0).toDouble(),
            price_min: (e['prestazione_price_min'] ?? 0).toDouble(),
            price_max: (e['prestazione_price_max'] ?? 0).toDouble(),
            title: e['prestazione_title'],
            description: e['prestazione_description'],
            // business_id: e['prestazione_business_id'],
            business: businessProvider.business,
          ),
        );
      }

      // print('recommendedList.length5gg5g6gg6g');
      // print(recommendedList.length);

      // print('postList.length');
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future deleteRecommendedPrestazione(String? businessId, String? prestazioneId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione/recommended/$prestazioneId");

    // Map/*<String, String>*/ body = {
    //   'business_id': businessId,
    //   'post_id': prestazioneId,
    // };

    var response = await http.delete(
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
      // setState(() {
      //   eventBusinessEventsList = jsonData;
      // });
      // print(jsonData);

      for(var e in List.from(recommendedList)){
        // if(e['id'] == prestazioneId){
        if(e.id == prestazioneId){
          recommendedList.remove(e);
        }
      }
      // getAllBusinessPrestazioni(businessId);
      notifyListeners();
      // return jsonData;
    }
    return response.statusCode;
  }

  Future insertRecommendedPrestazione(String? businessId, Prestazione prestazione, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione/recommended");

    Map/*<String, String>*/ body = {
      // 'business_id': businessId,
      'prestazione_id': prestazione.id,
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

    // print('response.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   eventBusinessEventsList = jsonData;
      // });
      // print(jsonData);

      recommendedList.add(prestazione);

      // for(var e in List.from(recommendedList)){
      //   // if(e['id'] == prestazioneId){
      //   if(e.id == prestazioneId){
      //     recommendedList.remove(e);
      //   }
      // }
      // getAllBusinessPrestazioni(businessId);
      notifyListeners();
      // return jsonData;
    }
    return response.statusCode;
  }

}
