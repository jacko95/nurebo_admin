import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:provider/provider.dart';

class PrestazioneProvider extends ChangeNotifier {
  List<Prestazione> prestazioneList = [];
  ImageCacheBusiness cacheBusiness = ImageCacheBusiness();


  void deleteAll(){
    prestazioneList.clear();
    notifyListeners();
  }

  Future getAllBusinessPrestazioni(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione/is_valid");

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

      prestazioneList.clear();
      // prestazioneList = jsonData;

      print('dv5gf5gf5gf5');
      print(jsonData);

      for(var e in jsonData){
        prestazioneList.add(
          Prestazione(
            id: e['id'],
            duration: e['duration'],
            business_id: e['business_id'],
            image: e['image'],
            is_price_range: (e['is_price_range']?.toInt() ?? 0) == 1 ? true : false,
            price: e['price']?.toDouble(),
            price_min: e['price_min']?.toDouble(),
            price_max: e['price_max']?.toDouble(),
            title: e['title'],
            description: e['description'],
            created_at: DateTime.tryParse(e['created_at']),
            is_valid: e['is_valid'],
            previous_prestazione: e['previous_prestazione'],
            business: businessProvider.business
          )
        );
      }

      // print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  Future deletePrestazione(String? businessId, String? prestazioneId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione/$prestazioneId");

    Map/*<String, String>*/ body = {
      'business_id': businessId,
      'prestazione_id': prestazioneId,
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

      for(var e in List.from(prestazioneList)){
        // if(e['id'] == prestazioneId){
        if(e.id == prestazioneId){
          prestazioneList.remove(e);
        }
      }
      // getAllBusinessPrestazioni(businessId);
      notifyListeners();
      // return jsonData;
    }
    return response.statusCode;
  }

  // Future upbookingPrestazione({
  //   String businessId,
  //   String prestazioneId,
  //   String title,
  //   String description,
  //   String duration,
  //   String price,
  //   BuildContext context
  // }) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione/upbooking");
  //
  //   Map/*<String, String>*/ body = {
  //     'prestazione_id': prestazioneId,
  //     'business_id': businessId,
  //     'title': title,
  //     'description': description,
  //     'duration': duration,
  //     'price': price,
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
  //   print('response.statusCode');
  //   print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //
  //     print('jsonData55555');
  //     print(response.body);
  //
  //     var jsonData = json.decode(response.body);
  //
  //     // getAllBusinessPrestazioni(businessId);
  //
  //     // for(var e in prestazioneList){
  //     //   if(e['id'] == prestazioneId){
  //     //     e['id'] = jsonData['id'];
  //     //     e['business_id'] = jsonData['business_id'];
  //     //     e['image'] = jsonData['image'];
  //     //     e['price'] = jsonData['price'];
  //     //     e['duration'] = jsonData['duration'];
  //     //     e['title'] = jsonData['title'];
  //     //     e['description'] = jsonData['description'];
  //     //     e['created_at'] = jsonData['created_at'];
  //     //     e['is_valid'] = jsonData['is_valid'];
  //     //     e['previous_prestazione'] = jsonData['previous_prestazione'];
  //     //   }
  //     // }
  //     for(var e in prestazioneList){
  //       if(e.id == prestazioneId){
  //         e.id = jsonData['id'];
  //         e.business_id = jsonData['business_id'];
  //         e.image = jsonData['image'];
  //         e.price = jsonData['price'].toDouble();
  //         e.duration = jsonData['duration'];
  //         e.title = jsonData['title'];
  //         e.description = jsonData['description'];
  //         // e.created_at = DateTime.tryParse(jsonData['created_at']);
  //         e.created_at = DateTime.now();
  //         e.is_valid = jsonData['is_valid'];
  //         e.previous_prestazione = jsonData['previous_prestazione'];
  //       }
  //     }
  //
  //     notifyListeners();
  //     // return jsonData;
  //   }
  //   return response.statusCode;
  // }

  Future<StreamedResponse> updatePrestazione({
    required String businessId,
    required String prestazioneId,
    required String title,
    required String description,
    required String duration,
    required bool isPriceRange,
    required String? price,
    required String? priceMin,
    required String? priceMax,
    File? uploadImage,
    String? image,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    cacheBusiness.removeImageFromCache('${Utils.httpServerUrl}image?path=${image}');

    var request = http.MultipartRequest(
        'PUT',
        // Uri.parse(Utils.httpServerUrl + "prestazione")
        Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione/$prestazioneId")
    );

    if(uploadImage != null) {
      String imageMimeType = lookupMimeType(uploadImage.path)!;
      // print('imageMimeType');
      // print(imageMimeType);

      String imageName = uploadImage.path.split('/').last;
      // List<int> imageBytes = File(filePath.path).readAsBytesSync();

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          // imageFilePath,
          uploadImage.path,
          filename: '${imageName.split('image_picker').last}',
          // contentType: new MediaType('image', 'jpeg')
          // contentType: new MediaType('image', 'png')
          // contentType: MediaType(imageMimeType.split('/').first, imageMimeType.split('/').last)
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

    Map<String, String> body = {
      'prestazione_id': prestazioneId,
      'business_id': businessId,
      'title': title,
      'description': description,
      'duration': duration,
      'is_price_range': isPriceRange ? "1" : "0",
      // 'price': !isPriceRange ? price : null,
      // 'price_min': priceMin!,
      // 'price_max': priceMax!,
      'image': image ?? '',
    };
    if (!isPriceRange && price != null) {
      body['price'] = price;
    }
    else if (isPriceRange ) {
      body['price_min'] = priceMin!;
      body['price_max'] = priceMax!;
    }
    request.fields.addAll(body);

    // print('body');
    // print(body);

    var response = await request.send();

    // print(response.statusCode.toString());

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    else if(response.statusCode >= 200 && response.statusCode < 400) {
      // var jsonData = json.decode(response.body);
      var resData = await response.stream.bytesToString();
      var jsonData = json.decode(resData);

      // print('res.statusCode');
      // print(response.statusCode);
      // print('res.stream.bytesToString()');
      // print(await res.stream.bytesToString());
      // print(json.decode(g)['Location']);
      // print(jsonData);

      // getAllBusinessPrestazioni(businessId);

      // for(var e in prestazioneList){
      //   if(e['id'] == prestazioneId){
      //     e['id'] = jsonData['id'];
      //     e['business_id'] = jsonData['business_id'];
      //     e['image'] = jsonData['image'];
      //     e['price'] = jsonData['price'];
      //     e['duration'] = jsonData['duration'];
      //     e['title'] = jsonData['title'];
      //     e['description'] = jsonData['description'];
      //     e['created_at'] = jsonData['created_at'];
      //     e['is_valid'] = jsonData['is_valid'];
      //     e['previous_prestazione'] = jsonData['previous_prestazione'];
      //   }
      // }
      for(var e in prestazioneList){
        if(e.id == prestazioneId){
          e.id = jsonData['id'];
          e.business_id = jsonData['business_id'];
          e.image = jsonData['image'];
          e.is_price_range = int.tryParse(jsonData['is_price_range'])/*?.toInt()*/ == 1 ? true : false;
          e.price = jsonData['price']?.toDouble();
          e.price_min = jsonData['price_min']?.toDouble();
          e.price_max = jsonData['price_max']?.toDouble();
          e.duration = jsonData['duration'];
          e.title = jsonData['title'];
          e.description = jsonData['description'];
          // e.created_at = DateTime.tryParse(jsonData['created_at']);
          e.created_at = DateTime.now();
          e.is_valid = jsonData['is_valid'];
          e.previous_prestazione = jsonData['previous_prestazione'];
        }
      }

      prestazioneList.sort((a, b) {
        // print('a.toString()');
        // print(a.title.toString());
        // print('b.toString()');
        // print(b.title.toString());
        // print('');
        return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
      });

      notifyListeners();
      // return jsonData;
    }
    else {
      // print('response55668');
      // print(response);
      Fluttertoast.showToast(
        msg: await response.stream.bytesToString(),
        backgroundColor: Colors.grey[700],
      );
    }

    return response;
  }

  // Future createPrestazione({
  //   String businessId,
  //   String title,
  //   String description,
  //   String duration,
  //   String price,
  //   File image,
  //   BuildContext context
  // }) async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione/insert");
  //
  //   Map/*<String, String>*/ body = {
  //     'business_id': businessId,
  //     'title': title,
  //     'description': description,
  //     'duration': duration,
  //     'price': price,
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
  //   print('response.statusCode');
  //   print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   ticketCategories = jsonData.toList();
  //     // });
  //     print('jsonData1212122233');
  //     print(jsonData);
  //
  //     // Map/*<String, String>*/ body = {
  //     //   'id': jsonData['id'],
  //     //   'business_id': jsonData['business_id'],
  //     //   'image': jsonData['image'],
  //     //   'price': jsonData['price'],
  //     //   'duration': jsonData['duration'],
  //     //   'title': jsonData['title'],
  //     //   'description': jsonData['description'],
  //     //   'created_at': jsonData['created_at'],
  //     //   'is_valid': jsonData['is_valid'],
  //     //   'previous_prestazione': jsonData['previous_prestazione'],
  //     // };
  //     //
  //     // prestazioneList.add(
  //     //   body
  //     // );
  //
  //     prestazioneList.add(
  //       Prestazione(
  //         id: jsonData['id'],
  //         duration: jsonData['duration'],
  //         business_id: jsonData['business_id'],
  //         image: jsonData['image'],
  //         price: jsonData['price'].toDouble(),
  //         title: jsonData['title'].toString(),
  //         description: jsonData['description'],
  //         // created_at: DateTime.tryParse(jsonData['created_at']),
  //         created_at: DateTime.now(),
  //         is_valid: jsonData['is_valid'].toInt(),
  //         previous_prestazione: jsonData['previous_prestazione'],
  //       )
  //     );
  //
  //     // prestazioneList.sort((a, b) => a['title'].toString().compareTo(b['title'].toString()));
  //     prestazioneList.sort((a, b) {
  //       print('a.toString()');
  //       print(a.title.toString());
  //       print('b.toString()');
  //       print(b.title.toString());
  //       print('');
  //
  //       return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
  //     });
  //
  //     // getAllBusinessPrestazioni(businessId);
  //     notifyListeners();
  //     // return jsonData;
  //   }
  //   return response.statusCode;
  // }

  Future createPrestazione({
    required String businessId,
    required String title,
    required String description,
    required String duration,
    required bool isPriceRange,
    required String? price,
    required String? priceMin,
    required String? priceMax,
    File? uploadImage,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    var request = http.MultipartRequest(
        'POST',
        // Uri.parse(Utils.httpServerUrl + "prestazione")
        Uri.parse("${Utils.httpServerUrl}business/$businessId/prestazione")
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
          uploadImage.path,
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

    Map<String, String> body = {
      'business_id': businessId,
      'title': title,
      'description': description,
      'duration': duration,
      'is_price_range': isPriceRange ? "1" : "0",
      // 'price': price!.replaceAll(',', '.'),
      // 'price_min': priceMin!.replaceAll(',', '.'),
      // 'price_max': priceMax!.replaceAll(',', '.'),
    };
    if (!isPriceRange) {
      body['price'] = price!;
    }
    else if (isPriceRange ) {
      body['price_min'] = priceMin!.replaceAll(',', '.');
      body['price_max'] = priceMax!.replaceAll(',', '.');
    }
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

      prestazioneList.add(
        Prestazione(
          id: jsonData['id'],
          duration: jsonData['duration'],
          business_id: jsonData['business_id'],
          image: jsonData['image'],
          is_price_range: (jsonData['is_price_range']?.toInt() ?? 0) == 1 ? true : false,
          price: jsonData['price']?.toDouble(),
          price_min: jsonData['price_min']?.toDouble(),
          price_max: jsonData['price_max']?.toDouble(),
          title: jsonData['title'].toString(),
          description: jsonData['description'],
          // created_at: DateTime.tryParse(jsonData['created_at']),
          created_at: DateTime.now(),
          is_valid: jsonData['is_valid']?.toInt(),
          previous_prestazione: jsonData['previous_prestazione'],
        )
      );

      prestazioneList.sort((a, b) {
        // print('a.toString()');
        // print(a.title.toString());
        // print('b.toString()');
        // print(b.title.toString());
        // print('');
        return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
      });

      // return json.decode(g);
      notifyListeners();
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

}
