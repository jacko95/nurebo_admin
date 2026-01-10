import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/event.dart';
import 'package:nurebo_admin/models/event_ticket.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:provider/provider.dart';

class EventProvider extends ChangeNotifier {
  List<Event> eventList = [];
  List<EventTicket> eventTicketList = [];


  void deleteAll(){
    eventList.clear();
    notifyListeners();
  }

  Future getAllBusinessEvents(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "event/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/event/is_visible");

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
          // HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
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

      // prestazioneList = jsonData;
      for(var e in jsonData){
        eventList.add(
          Event(
            id: e['id'],
            business_id: e['business_id'],
            is_valid: 1,
            image: e['image'],
            title: e['title'],
            description: e['description'],
            created_at: DateTime.tryParse(e['created_at']),
            begin_at: DateTime.tryParse(e['begin_at'])/*.toLocal()*/,
            end_at: DateTime.tryParse(e['end_at'])/*.add(Duration(minutes: ))*//*.toLocal()*/,
          )
        );
      }

      eventList.sort((b, a) => a.begin_at!.compareTo(b.begin_at!));

      // print(jsonData);
      notifyListeners();
      return jsonData;
    }
  }

  Future getAllBusinessEventTickets(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "event/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/event/ticket");

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

      // prestazioneList = jsonData;
      for(var e in jsonData){
        eventTicketList.add(
          EventTicket(
            id: e['event_ticket_id'],
            title: e['event_ticket_title'],
            price: e['event_ticket_price']?.toDouble(),
            additional: e['event_ticket_additional'],
            event: Event(
              title: e['event_title'],
              id: e['event_id'],
              description: e['event_description'],
              image: e['event_image'],
              begin_at: DateTime.tryParse(e['event_begin_at'])/*.toLocal()*/,
              end_at: DateTime.tryParse(e['event_end_at'])/*.add(Duration(minutes: ))*//*.toLocal()*/,
              business: Business(
                id: e['business_id'],
                email: e['business_email'],
                name: e['business_name'],
                room_id: e['business_room_id'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                phone: e['business_phone'],
                profile_image: e['business_profile_image'] ?? '',
                address: e['business_address'],
                description: e['business_description'],
                type_id: e['business_type_id'],
                // max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
              ),
            )
          )
        );
      }

      // eventList.sort((b, a) => a.begin_at!.compareTo(b.begin_at!));

      // for(EventTicket e in eventTicketList){
      //   print(e.title);
      // }

      // print('eventTicketListdfdf55');
      // print(eventTicketList);

      notifyListeners();
      return jsonData;
    }
  }

  Future deleteEvent(String? businessId, String? eventId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "event");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/event/$eventId");

    Map/*<String, String>*/ body = {
      'business_id': businessId,
      'event_id': eventId,
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

      for(var e in List.from(eventList)){
        // if(e['id'] == prestazioneId){
        if(e.id == eventId){
          eventList.remove(e);
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

  Future updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime beginAtDateTime1,
    required DateTime endAtDateTime1,
    required List<EventTicket> eventTicketsList,
    File? uploadImage,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/event/$eventId")
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

    Map<String, /*dynamic*/String> body = {
      'business_id': businessProvider.business!.id!,
      'title': title,
      'begin_at': beginAtDateTime1.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
      'end_at': endAtDateTime1.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
      'description': description,
      'tickets': jsonEncode(eventTicketsList),
    };
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
      for(var e in eventList){
        if(e.id == eventId){
          e.id = jsonData['id'];
          e.business_id = jsonData['business_id'];
          e.image = jsonData['image'];
          e.title = jsonData['title'];
          e.description = jsonData['description'];
          e.begin_at = DateTime.tryParse(jsonData['begin_at']);
          e.end_at = DateTime.tryParse(jsonData['end_at']);
          e.created_at = DateTime.now();
          e.is_valid = jsonData['is_valid'];
          e.previous = jsonData['previous'];
        }
      }

      eventList.sort((a, b) {
        // print('a.toString()');
        // print(a.title.toString());
        // print('b.toString()');
        // print(b.title.toString());
        // print('');
        return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
      });

      const SnackBar snackBar = SnackBar(
        content: Text(
          'Evento modificato!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      notifyListeners();

      Navigator.of(context).pop();
    }
    else {
      Fluttertoast.showToast(
        msg: response.statusCode.toString(),
        backgroundColor: Colors.grey[700],
      );
    }

    return response.statusCode;
  }

  Future createEvent({
    required String title,
    required String description,
    required DateTime beginAtDateTime1,
    required DateTime endAtDateTime1,
    required List<EventTicket> eventTicketsList,
    File? uploadImage,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/event")
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
          filename: imageName.split('image_picker').last,
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

    Map<String, /*dynamic*/String> body = {
      'business_id': businessProvider.business!.id!,
      'title': title,
      'begin_at': beginAtDateTime1.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
      'end_at': endAtDateTime1.subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString(),
      'description': description,
      'tickets': jsonEncode(eventTicketsList),
    };
    request.fields.addAll(body);

    var res = await request.send();

    // print(res.statusCode.toString());

    if(res.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      // await businessProvider.logout(context);
    }
    else if(res.statusCode == 200){
      // var jsonData = json.decode(response.body);
      var resData = await res.stream.bytesToString();
      dynamic jsonData = json.decode(resData);

      print('jsonDatadf5gdg5dg');
      print(jsonData);

      eventList.add(
        Event(
          id: jsonData['id'],
          business_id: jsonData['business_id'],
          is_valid: 1,
          image: jsonData['image'],
          title: jsonData['title'],
          description: jsonData['description'],
          created_at: DateTime.tryParse(jsonData['created_at']),
          begin_at: DateTime.tryParse(jsonData['begin_at'])/*.toLocal()*/,
          end_at: DateTime.tryParse(jsonData['end_at'])/*.add(Duration(minutes: ))*//*.toLocal()*/,
          business: businessProvider.business
        )
      );

      // for()

      const SnackBar snackBar = SnackBar(
        content: Text(
          'Evento creato!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      );
      snackbarKey.currentState?.showSnackBar(snackBar);
      notifyListeners();

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

}
