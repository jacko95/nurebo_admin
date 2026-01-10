import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/booking_post.dart';
import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/event.dart';
import 'package:nurebo_admin/models/event_reservation.dart';
import 'package:nurebo_admin/models/event_reservation.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/event_ticket.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/post_like.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/screens/booking_business_detail_screen.dart';
import 'package:nurebo_admin/screens/booking_business_profile_screen.dart';
import 'package:nurebo_admin/screens/business_profile_screen.dart';
import 'package:nurebo_admin/screens/post_full_screen.dart';
import 'package:nurebo_admin/screens/user_friends_list_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/tab_bar_sliver_persistent_header_delegate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;


class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<EventReservation> eventReservationList1 = [];
  List<Event?> eventReservationList = [];
  List<Booking> userBookingsList = [];
  // UserProvider userProvider;
  // FavoriteProvider favoriteProvider;
  // SavedBusinessProvider savedBusinessProvider;
  // SocketProvider socketProvider;
  late PostProvider postProvider;
  List<Prestazione?> prestazioneList = [];
  List<Business?> businessList = [];
  // List<BookingPost> userPostList = [];
  List<BusinessPost> userPostList = [];
  int status = -1;
  List userFollowedList = [];
  List userFavoriteList = [];
  List<User> userFriendsList = [];
  Future a = Future(() {},), b = Future(() {},), c = Future(() {},), d = Future(() {}), e = Future(() {},), f = Future(() {}), g = Future(() {}), h = Future(() {}), l = Future(() {}), all = Future(() {});


  Future getUserFriends() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user_friendship/status");
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user.id}/friend");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request/${widget.user!.id}");

    // Map<String, String?> queryParameters = {
    //   'user_id': Utils.user!.id,
    //   // 'recipient_id': widget.user!.id,
    // };
    //
    // final uri = url.replace(
    //   queryParameters: queryParameters,
    // );

    // HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    // HttpHeaders.cacheControlHeader: 'no-cache',
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.acceptEncodingHeader: 'gzip, deflate, deflate',
      HttpHeaders.connectionHeader: 'keep-alive',
      'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
      'X-App-Version-Name': Utils.version_name,
      'X-App-Version-Number': Utils.version_id.toString(),
      'X-Client-Type': 'User-Mobile-App',
      HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
    };

    var response = await http.get(
      url,
      headers: headers,
    );

    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('jsonData5g555gv5b54b');
      print(jsonData);


      for(var e in jsonData){
        User user;
        if(e['user_id'] != widget.user!.id){
          user = User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            profile_image: e['user_profile_image'] ?? '',
            description: e['user_description'],
          );
        }
        else {
          user = User(
            id: e['recipient_id'],
            email: e['recipient_email'],
            username: e['recipient_username'],
            name: e['recipient_name'],
            profile_image: e['recipient_profile_image'],
            description: e['recipient_description'],
          );
        }
        userFriendsList.add(user);
      }

      // userFriendsList.addAll(jsonData);

      //print('status');
      //print(status);
      return jsonData;
    }
  }

  Future getUserFollows() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/save");

    Map<String, dynamic> body = {
      'user_id': widget.user!.id,
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
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDat5cc5cc5ahfhfhfg');
      // print(jsonData);
      //print("jsonData 222:");
      //print(jsonData.length);
      userFollowedList.addAll(jsonData);

      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future getUserFavorites() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/prestazione/like");

    Map<String, dynamic> body = {
      'user_id': widget.user!.id,
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
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDat5cc5cc5ahfhfhfg');
      // print(jsonData);
      //print("jsonData 222:");
      //print(jsonData.length);


      userFavoriteList.addAll(jsonData);

      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future getUserPosts() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/post");

    Map<String, dynamic> body = {
      'user_id': widget.user!.id,
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
          'X-Client-Type': 'User-Mobile-App',
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDat5cc5cc5ahfhfhfg');
      // print(jsonData);
      print("jsonDatf55cccvvv:");
      print(jsonData.length);

      for(var e in jsonData){
        // setState(() {
        // userBookingsList = jsonData;
        // results.addAll(jsonData);
        // results.shuffle();
        userPostList.add(
            // BookingPost(
            BusinessPost(
              id: e['post_id'],
              description: e['post_description'],
              image_url: e['post_image_url'],
              // is_admin: e['post_is_admin'],
              is_visible: e['post_is_visible'],
              likes: [],
              comments: [],
              created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              // booking: Booking(
              //   id: e['booking_id'],
              //   isCanceled: e['is_canceled'],
                prestazione: Prestazione(
                  id: e['prestazione_id'],
                  duration: e['prestazione_duration'],
                  image: e['prestazione_image'] ?? '',
                  is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                  price: e['prestazione_price']?.toDouble(),
                  price_min: e['prestazione_price_min']?.toDouble(),
                  price_max: e['prestazione_price_max']?.toDouble(),
                  title: e['prestazione_title'],
                  description: e['prestazione_description'] ?? '',
                  // business_id: e['prestazione_business_id'],
                  business: Business(
                      id: e['business_id'],
                      email: e['business_email'],
                      name: e['business_name'],
                      longitude: e['business_longitude'],
                      latitude: e['business_latitude'],
                      phone: e['business_phone'],
                      room_id: e['business_room_id'],
                      profile_image: e['business_profile_image'] ?? '',
                      address: e['business_address'],
                      description: e['business_description'],
                      type_id: e['business_type_id'],
                      max_contemporary_appointments: e['max_contemporary_appointments'],
                      category: Category(
                        id: e['category_id'],
                        image: e['category_image'],
                        name: e['category_name'],
                      )
                  ),
                ),
                business: Business(
                    id: e['business_id'],
                    email: e['business_email'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    phone: e['business_phone'],
                    profile_image: e['business_profile_image'] ?? '',
                    address: e['business_address'],
                    description: e['business_description'],
                    type_id: e['business_type_id'],
                    room_id: e['business_room_id'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
                // user: User(
                //   id: e['user_id'],
                //   email: e['user_email'],
                //   username: e['user_username'],
                //   name: e['user_name'],
                //   phone_number: e['user_phone_number'],
                //   profile_image: e['user_profile_image'],
                //   description: e['user_description'],
                // ),
              //   begin_at: DateTime.tryParse(e['begin_at']),
              //   end_at: DateTime.tryParse(e['begin_at'])!.add(Duration(minutes: e['prestazione_duration'].toInt())),
              //   created_at: DateTime.tryParse(e['created_at'])/*.add(Duration(hours: 2))*/,
              // ),
              user: User(
                profile_image: e['user_profile_image'] ?? '',
                id: e['user_id'],
                username: e['user_username'],
                email: e['user_email'],
                name: e['user_name'],
                description: e['user_description'],
              ),
            )
        );
        // });
      }

      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  // Future getUserAppointments() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
  //
  //   Map<String, dynamic> body = {
  //     'user_id': widget.user.id,
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
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //       }
  //   );
  //
  //   // print("ticketUsers response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('jsonDatahfhfhfg');
  //     print(jsonData);
  //     print("jsonData 222:");
  //     print(jsonData.length);
  //
  //     for(var e in jsonData){
  //       // setState(() {
  //         // userBookingsList = jsonData;
  //         // results.addAll(jsonData);
  //         // results.shuffle();
  //         userBookingsList.add(
  //             Booking(
  //               id: e['booking_id'],
  //               isCanceled: e['is_canceled'],
  //               // note: myAppointments[index]['note'],
  //               // user_id: myAppointments[index]['user_id'].toString(),
  //               prestazione: Prestazione(
  //                 duration: e['prestazione_duration'],
  //                 image: e['prestazione_image'],
  //                 id: e['prestazione_id'],
  //                 price: e['prestazione_price'].toDouble(),
  //                 title: e['prestazione_title'],
  //                 description: e['prestazione_description'],
  //                 // business_id: socketBody['business_id'],
  //                 business: Business(
  //                   id: e['business_id'],
  //                   name: e['business_name'],
  //                   longitude: e['business_longitude'],
  //                   latitude: e['business_latitude'],
  //                   type_id: e['business_type_id'],
  //                   room_id: e['business_room_id'],
  //                   // profile_image: e['business_image'],
  //                   profile_image: e['business_profile_image'] ?? '',
  //                   description: e['business_description'],
  //                   address: e['business_address'],
  //                   phone_number: e['business_phone_number'],
  //                   max_contemporary_appointments: e['max_contemporary_appointments'],
  //                 ),
  //               ),
  //               user: User(
  //                 id: e['user_id'],
  //                 email: e['user_email'],
  //                 username: e['user_username'],
  //                 name: e['user_name'],
  //                 phone_number: e['user_phone_number'],
  //                 profile_image: e['user_profile_image'],
  //                 description: e['user_description'],
  //               ),
  //               business: Business(
  //                 id: e['business_id'],
  //                 name: e['business_name'],
  //                 longitude: e['business_longitude'],
  //                 latitude: e['business_latitude'],
  //                 room_id: e['business_room_id'],
  //                 type_id: e['business_type_id'],
  //                 // profile_image: e['business_image'],
  //                 profile_image: e['business_profile_image'] ?? '',
  //                 description: e['business_description'],
  //                 address: e['business_address'],
  //                 phone_number: e['business_phone_number'],
  //                 max_contemporary_appointments: e['max_contemporary_appointments'],
  //               ),
  //               // begin_at: DateTime.tryParse(jsonData['begin_at']).toLocal(),
  //               // end_at: DateTime.tryParse(jsonData['begin_at']).add(Duration(minutes: jsonData['prestazione_duration'].toInt())).toLocal(),
  //               // created_at: DateTime.tryParse(jsonData['created_at']).toLocal(),
  //             )
  //         );
  //       // });
  //     }
  //
  //     // print("singleEventTicketCategories: ");
  //     // print(singleEventTicketCategories);
  //     // print('searchUserByUsername results.toString()');
  //     // print(results.toString());
  //     // print(jsonData);
  //     return jsonData;
  //   }
  // }
  //
  // Future getAllSingleEvent() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "event_reservation/user");
  //   var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user.id}/reservation/event");
  //
  //   Map<String, dynamic> body = {
  //     "user_id": widget.user.id
  //   };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     print('jsonData');
  //     print(jsonData);
  //     print("jsonData 111:");
  //     print(jsonData.length);
  //
  //     for(var e in jsonData){
  //       // setState(() {
  //         // eventReservationList1 = jsonData;
  //         eventReservationList1.add(
  //             EventReservation(
  //               id: e['id'],
  //               is_canceled: e['is_canceled'],
  //               is_validated: e['is_validated'],
  //               is_validated_at: e['is_validated_at'],
  //               // qr_code: jsonData['qr_code'],
  //               // note: myAppointments[index]['note'],
  //               // user_id: myAppointments[index]['user_id'].toString(),
  //               eventTicket: EventTicket(
  //                   id: e['event_ticket_id'],
  //                   title: e['event_ticket_title'],
  //                   price: e['event_ticket_price'].toDouble(),
  //                   additional: e['event_ticket_additional'],
  //                   event: Event(
  //                     title: e['event_title'],
  //                     id: e['event_id'],
  //                     description: e['event_description'],
  //                     image: e['event_image'],
  //                     begin_at: DateTime.tryParse(e['begin_at'])/*.toLocal()*/,
  //                     end_at: DateTime.tryParse(e['end_at'])/*.add(Duration(minutes: ))*//*.toLocal()*/,
  //                     business: Business(
  //                         id: e['business_id'],
  //                         email: e['business_email'],
  //                         name: e['business_name'],
  //                         room_id: e['business_room_id'],
  //                         longitude: e['business_longitude'],
  //                         latitude: e['business_latitude'],
  //                         phone_number: e['business_phone_number'],
  //                         profile_image: e['business_profile_image'] ?? '',
  //                         address: e['business_address'],
  //                         description: e['business_description'],
  //                         type_id: e['business_type_id'],
  //                         max_contemporary_appointments: e['max_contemporary_appointments'],
  //                         category: Category(
  //                           id: e['category_id'],
  //                           image: e['category_image'],
  //                           name: e['category_name'],
  //                         )
  //                     ),
  //                   )
  //               ),
  //               user: widget.user,
  //               created_at: DateTime.tryParse(e['created_at'])/*.toLocal()*//*.add(Duration(hours: 2))*/,
  //             )
  //         );
  //       // });
  //     }
  //
  //     print("eventReservationList1 111:");
  //     print(eventReservationList1.length);
  //
  //     return jsonData;
  //   }
  // }
  Future getUserAppointments() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/booking/shared");

    Map<String, dynamic> body = {
      'user_id': widget.user!.id,
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
          'X-Client-Type': 'User-Mobile-App',
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("ticketUsers response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDat5cc5cc5ahfhfhfg');
      // print(jsonData);
      //print("jsonData 222:");
      //print(jsonData.length);

      for(var e in jsonData){
        // setState(() {
        // userBookingsList = jsonData;
        // results.addAll(jsonData);
        // results.shuffle();
        userBookingsList.add(
            Booking(
              id: e['booking_id'],
              isCanceled: e['is_canceled'],
              // note: myAppointments[index]['note'],
              // user_id: myAppointments[index]['user_id'].toString(),
              prestazione: Prestazione(
                duration: e['prestazione_duration'],
                image: e['prestazione_image'],
                id: e['prestazione_id'],
                is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                price: e['prestazione_price']?.toDouble(),
                price_min: e['prestazione_price_min']?.toDouble(),
                price_max: e['prestazione_price_max']?.toDouble(),
                title: e['prestazione_title'],
                description: e['prestazione_description'],
                // business_id: socketBody['business_id'],
                business: Business(
                    id: e['business_id'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    type_id: e['business_type_id'],
                    // profile_image: e['business_image'],
                    profile_image: e['business_profile_image'] ?? '',
                    description: e['business_description'],
                    address: e['business_address'],
                    room_id: e['business_room_id'],
                    phone: e['business_phone'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                phone: e['user_phone'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              business: Business(
                id: e['business_id'],
                name: e['business_name'],
                room_id: e['business_room_id'],
                longitude: e['business_longitude'],
                latitude: e['business_latitude'],
                type_id: e['business_type_id'],
                // profile_image: e['business_image'],
                profile_image: e['business_profile_image'] ?? '',
                description: e['business_description'],
                address: e['business_address'],
                phone: e['business_phone'],
                max_contemporary_appointments: e['max_contemporary_appointments'],
                category: Category(
                  id: e['category_id'],
                  image: e['category_image'],
                  name: e['category_name'],
                )
              ),
              // begin_at: DateTime.tryParse(e['begin_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              // end_at: DateTime.tryParse(e?['begin_at'])!.add(Duration(minutes: e['prestazione_duration'].toInt())).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
              // created_at: DateTime.tryParse(e?['created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            )
        );
        // });
      }

      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);
      return jsonData;
    }
  }

  Future getAllSingleEvent() async {
    // var url = Uri.parse(Utils.httpServerUrl + "event_reservation/user");
    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/reservation");

    Map<String, dynamic> body = {
      "user_id": widget.user!.id
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
          'X-Client-Type': 'User-Mobile-App',
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //print('jsonData');
      //print(jsonData);
      //print("jsonData 111:");
      //print(jsonData.length);

      for(var e in jsonData){
        // setState(() {
        // eventTicketList1 = jsonData;
        eventReservationList1.add(
            EventReservation(
              id: e['id'],
              is_canceled: e['is_canceled'],
              is_validated: e['is_validated'],
              is_validated_at: DateTime.tryParse(e['is_validated_at'] ?? ''),
              // qr_code: jsonData['qr_code'],
              // note: myAppointments[index]['note'],
              // user_id: myAppointments[index]['user_id'].toString(),
              eventTicket: EventTicket(
                  id: e['event_ticket_id'],
                  title: e['event_ticket_title'],
                  price: e['event_ticket_price']?.toDouble(),
                  additional: e['event_ticket_additional'],
                  event: Event(
                    title: e['event_title'],
                    id: e['event_id'],
                    description: e['event_description'],
                    image: e['event_image'],
                    begin_at: DateTime.tryParse(e['begin_at'])/*.toLocal()*/,
                    end_at: DateTime.tryParse(e['end_at'])/*.add(Duration(minutes: ))*//*.toLocal()*/,
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
                        max_contemporary_appointments: e['max_contemporary_appointments'],
                        category: Category(
                          id: e['category_id'],
                          image: e['category_image'],
                          name: e['category_name'],
                        )
                    ),
                  )
              ),
              user: widget.user,
              created_at: DateTime.tryParse(e['created_at'])/*.toLocal()*//*.add(Duration(hours: 2))*/,
            )
        );
        // });
      }

      //print("eventTicketList1 111:");
      //print(eventTicketList1.length);

      return jsonData;
    }
  }

  // Future sendFriendshipRequest() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "user_friendship");
  //
  //   Map<String, dynamic> body = {
  //     'applicant_id': userProvider.user.id,
  //     'applicant_image': userProvider.user.profile_image,
  //     'applicant_name': userProvider.user.name,
  //     'applicant_username': userProvider.user.username,
  //     'user_id': widget.user.id,
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
  //   // print("ticketUsers response.statusCode:");
  //   // print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       status = 0;
  //     });
  //
  //     return jsonData;
  //   }
  // }

  // Future getFriendshipRequest() async {
  //   var url = Uri.parse(
  //     "${Utils.httpServerUrl}user_friendship/status"
  //   );
  //
  //   Map<String, String> queryParameters = {
  //     'applicant_id': userProvider.user.id,
  //     'user_id': widget.user.id,
  //   };
  //
  //   final uri = url.replace(
  //     queryParameters: queryParameters,
  //   );
  //
  //   // HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
  //   // HttpHeaders.cacheControlHeader: 'no-cache',
  //   Map<String, String> headers = {
  //     HttpHeaders.contentTypeHeader: 'application/json',
  //     HttpHeaders.acceptHeader: '*/*',
  //     HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br, deflate, br',
  //     HttpHeaders.connectionHeader: 'keep-alive',
  //   };
  //
  //   var response = await http.get(
  //     uri,
  //     headers: headers,
  //   );
  //
  //   print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     print('jsonDataiiiii');
  //     print(jsonData);
  //     if(jsonData.length > 0){
  //       print(jsonData[0]['status']);
  //       // status = int.tryParse(jsonData[0]['status']);
  //       setState(() {
  //         status = jsonData[0]['status'];
  //       });
  //     }
  //
  //     print('status');
  //     print(status);
  //     return jsonData;
  //   }
  // }

  Future getUserPostComments() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${widget.user!.id}/comment");

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
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

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('userBusinessPostCommentsList');
      print(jsonData.length);

      for(var e in jsonData) {
        for (BusinessPost post in userPostList) {
          if(e['post_id'] == post.id){
            PostComment postComment = PostComment(
              id: e['id'],
              is_admin: e['is_admin'],
              created_at: DateTime.parse(e['created_at']),
              text: e['text'],
              user: User(
                id: e['user_id'],
                description: e['user_description'],
                profile_image: e['user_profile_image'] ?? '',
                // first_name: comments[i]['first_name'],
                name: e['user_name'],
                // last_name: comments[i]['last_name'],
                // city: postProvider.posts[i]['city'],
                // nation: postProvider.posts[i]['nation'],
                username: e['username'],
                email: e['user_email'],
              ),
            );

            post.comments.add(postComment);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  Future getUserPostLikes() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${widget.user!.id}/like");

    // Map/*<String, String>*/ body = {
    //   // 'user_id': userProvider.user.id,
    //   'post_id': widget.businessPost!.id,
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

    // print("postcomment getall response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('userBusinessPostLikesList');
      print(jsonData.length);

      for(var e in jsonData) {
        for (BusinessPost post in userPostList) {
          if(e['post_id'] == post.id){
            PostLike postlike = PostLike(
              businessPost: BusinessPost(
                id: e['post_id'],
                description: e['post_description'],
                image_url: e['post_image_url'],
                // is_admin: e['post_is_admin'],
                // is_visible: e['post_is_visible'],
                created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                // booking: Booking(
                //   id: e['booking_id'],
                //   isCanceled: e['is_canceled'],
                //   // note: myAppointments[index]['note'],
                //   // user_id: myAppointments[index]['user_id'].toString(),
                prestazione: Prestazione(
                  id: e['prestazione_id'],
                  duration: e['prestazione_duration'],
                  image: e['prestazione_image'] ?? '',
                  is_price_range: (e['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                  price: e['prestazione_price']?.toDouble(),
                  price_min: e['prestazione_price_min']?.toDouble(),
                  price_max: e['prestazione_price_max']?.toDouble(),
                  title: e['prestazione_title'],
                  description: e['prestazione_description'] ?? '',
                  // business_id: e['prestazione_business_id'],
                  business: Business(
                      id: e['business_id'],
                      email: e['business_email'],
                      name: e['business_name'],
                      longitude: e['business_longitude'],
                      latitude: e['business_latitude'],
                      phone: e['business_phone'],
                      room_id: e['business_room_id'],
                      profile_image: e['business_profile_image'] ?? '',
                      address: e['business_address'],
                      description: e['business_description'],
                      type_id: e['business_type_id'],
                      max_contemporary_appointments: e['max_contemporary_appointments'],
                      category: Category(
                        id: e['category_id'],
                        image: e['category_image'],
                        name: e['category_name'],
                      )
                  ),
                ),
                business: Business(
                    id: e['business_id'],
                    email: e['business_email'],
                    name: e['business_name'],
                    longitude: e['business_longitude'],
                    latitude: e['business_latitude'],
                    phone: e['business_phone'],
                    profile_image: e['business_profile_image'] ?? '',
                    address: e['business_address'],
                    description: e['business_description'],
                    type_id: e['business_type_id'],
                    room_id: e['business_room_id'],
                    max_contemporary_appointments: e['max_contemporary_appointments'],
                    category: Category(
                      id: e['category_id'],
                      image: e['category_image'],
                      name: e['category_name'],
                    )
                ),
                user: User(
                  id: e['user_id'],
                  email: e['user_email'],
                  username: e['user_username'],
                  name: e['user_name'],
                  profile_image: e['user_profile_image'] ?? '',
                  description: e['user_description'],
                ),
                comments: [],
                likes: [],
              ),
              user: User(
                id: e['user_id'],
                email: e['user_email'],
                username: e['user_username'],
                name: e['user_name'],
                profile_image: e['user_profile_image'] ?? '',
                description: e['user_description'],
              ),
              created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            );

            post.likes.add(postlike);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  Future callFutureBuilderMethods() async {
    await Future.wait([
      // a = getAllSingleEvent(),
      b = getUserAppointments(),
      // c = getFriendshipRequest(),
      d = getUserPosts(),
      e = getUserFollows(),
      f = getUserFavorites(),
      g = getUserFriends(),
      h = getUserPostComments(),
      l = getUserPostLikes(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    // userProvider = Provider.of<UserProvider>(context, listen: false);
    // favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    // socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // savedBusinessProvider = Provider.of<SavedBusinessProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

    Future.wait([
    //   // a = getAllSingleEvent(),
    //   b = getUserAppointments(),
    //   // c = getFriendshipRequest(),
    //   d = getUserPosts(),
    //   e = getUserFollows(),
    //   f = getUserFavorites(),
    //   g = getUserFriends(),
      all = callFutureBuilderMethods(),
    ]);

    // /*a = */getAllSingleEvent();
    // /*b = */getUserAppointments();
  }

  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context, listen: true);
    // favoriteProvider = Provider.of<FavoriteProvider>(context, listen: true);
    // socketProvider = Provider.of<SocketProvider>(context, listen: true);
    // savedBusinessProvider = Provider.of<SavedBusinessProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.only(right: 0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                // size: 27,
                // color: Colors.white,
                color: Colors.grey[500],
              ),
              iconSize: 27,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          actions: <Widget>[
            // Padding(
            //   padding: EdgeInsets.only(right: 0),
            //   child: IconButton(
            //     icon: Icon(
            //       //Icons.local_activity_outlined,
            //       Icons.favorite_border_outlined,
            //       // color: Colors.white,
            //       color: Colors.grey[700],
            //     ),
            //     onPressed: () {
            //       /*Navigator.push(
            //           context,
            //           PageTransition(
            //             duration: const Duration(milliseconds: 900),
            //             alignment: Alignment.center,
            //             type: PageTransitionType.fade,
            //             child: LikedPostScreen(
            //               user: widget.user,
            //             )
            //           )
            //       );*/
            //     },
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(right: 0),
            //   child: IconButton(
            //     icon: Icon(
            //       //Icons.local_activity_outlined,
            //       Icons.bookmark_border_outlined,
            //       // color: Colors.white,
            //       color: Colors.grey[800],
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           PageTransition(
            //               duration: const Duration(milliseconds: 900),
            //               alignment: Alignment.center,
            //               type: PageTransitionType.fade,
            //               // child: SettingsScreen()
            //           )
            //       );
            //     },
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(right: 0),
            //   child: IconButton(
            //     icon: Icon(
            //       //Icons.local_activity_outlined,
            //       Icons.settings_outlined,
            //       // color: Colors.white,
            //       color: Colors.grey[700],
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         PageTransition(
            //           duration: const Duration(milliseconds: 900),
            //           alignment: Alignment.topRight,
            //           type: PageTransitionType.scale,
            //           child: SettingsScreen()
            //         )
            //       );
            //     },
            //   ),
            // ),
            // Transform(
            //   transform:  Matrix4.translationValues(-MediaQuery.of(context).size.width * 0.733, 0.0, 0.0),
            //   child: IconButton(
            //     onPressed: (){
            //       // Navigator.pop(context);
            //     },
            //     icon: Icon(
            //       Icons.settings,
            //       color: Colors.black,
            //       size: 27,
            //     ),
            //     color: Colors.black,
            //   ),
            // ),

            // Padding(
            //   padding: EdgeInsets.only(right: 5),
            //   child: IconButton(
            //       icon: Icon(
            //         Icons.shopping_cart_outlined,
            //         color: Colors.black,
            //       ),
            //       onPressed: (){
            //
            //       }),
            // )
          ],
        ),
      ),
      body: FutureBuilder/*<Object>*/(
        // future: Future.wait([a/*.then((value) => value!)*/, b/*.then((value) => value!)*/, c/*.then((value) => value!)*/, d]),
        future: all,
        initialData: [],
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            // print(socketProvider.myAppointmentsList[0].prestazione.id.toString());
            // prestazioniList.add(socketProvider.myAppointmentsList[0].prestazione);

            prestazioneList.clear();
            // for(var e in socketProvider.myAppointmentsList){
            for(int j = 0; j < userBookingsList.length; j++){
              Prestazione? prestazioneTemp;
              bool isPresent = false;
              // prestazioneTemp = e.prestazione;
              prestazioneTemp = userBookingsList[j].prestazione;
              // for(var e1 in prestazioneList){
              for(int k = 0; k < prestazioneList.length; k++){
                // if(e1.id.toString() == prestazioneTemp.id.toString()){
                if(prestazioneList[k]!.id.toString() == prestazioneTemp!.id.toString()){
                  isPresent = true;
                  // prestazioniList.add(e1);
                  // break;
                }
              }
              if(isPresent == false){
                prestazioneList.add(prestazioneTemp);
                // break;
              }
            }
            // print('prestazioniList.length.toString()');
            // print(prestazioneList.length.toString());

            eventReservationList.clear();
            for(int j = 0; j < eventReservationList1.length; j++){
              Event? eventTemp;
              bool isPresent = false;
              eventTemp = eventReservationList1[j].eventTicket!.event;
              for(int k = 0; k < eventReservationList.length; k++){
                // if(e1.id.toString() == prestazioneTemp.id.toString()){
                if(eventReservationList[k]!.id.toString() == eventTemp!.id.toString()){
                  isPresent = true;
                  // prestazioniList.add(e1);
                  // break;
                }
              }
              if(isPresent == false){
                eventReservationList.add(eventTemp);
                // break;
              }
            }
            // print('eventReservationList.length.toString()');
            // print(eventReservationList.length.toString());

            businessList.clear();
            // print(socketProvider.myAppointmentsList[0].prestazione.id.toString());
            // prestazioniList.add(socketProvider.myAppointmentsList[0].prestazione);
            for(var e in userBookingsList){
              Business? businessTemp;
              bool isPresent = false;
              // print(e.business.profile_image.toString());
              businessTemp = e.business;

              if(e.isCanceled == 0){
                for(var e1 in businessList){
                  if(e1!.id.toString() == businessTemp!.id.toString()){
                    isPresent = true;
                    // prestazioniList.add(e1);
                    // break;
                  }
                }
                if(isPresent == false){
                  businessList.add(businessTemp);
                  // break;
                }
              }
            }
            for(var e in eventReservationList1){
              Business? businessTemp;
              bool isPresent = false;
              // print(e.business.profile_image.toString());
              businessTemp = e.eventTicket!.event!.business;

              if(e.is_canceled == 0){
                for(var e1 in businessList){
                  if(e1!.id.toString() == businessTemp!.id.toString()){
                    isPresent = true;
                    // prestazioniList.add(e1);
                    // break;
                  }
                }
                if(isPresent == false){
                  businessList.add(businessTemp);
                  // break;
                }
              }
            }

            // print('businessList.length.toString()');
            // print(businessList.length.toString());
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                body: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          // child: HeaderAccountWidget(),
                          child: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(7.0),
                                          // child: CircleAvatar(
                                          //   radius: 70,
                                          //   backgroundImage: NetworkImage(
                                          //     allUsers[0].profileImageUrl,
                                          //   ),
                                          // ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            // child: Image(
                                            //   image: NetworkImage(
                                            //       userProvider.user.profile_image
                                            //     // allUsers[0].profileImageUrl,
                                            //   ),
                                            //   width: MediaQuery.of(context).size.width * 0.3,
                                            //   height: MediaQuery.of(context).size.width * 0.3,
                                            //   fit: BoxFit.cover,
                                            // ),
                                            child: widget.user.profile_image != null && widget.user.profile_image != '' ? FutureImage(
                                              // imageUrl: userProvider.user.profile_image != null && userProvider.user.profile_image != '' ? userProvider.user.profile_image : 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                                              widget.user.profile_image!,
                                              // colorBlendMode: BlendMode.hardLight,
                                              // width: MediaQuery.of(context).size.width,
                                              // filterQuality: FilterQuality.high,
                                              width: MediaQuery.of(context).size.width * 0.3,
                                              height: MediaQuery.of(context).size.width * 0.3,
                                              // placeholder: (context, url) => Center(
                                              //     child: CircularProgressIndicator()
                                              // ),
                                            ) : ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.3,
                                                height: MediaQuery.of(context).size.width * 0.3,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0.0),
                                        Text(
                                          widget.user.name ?? '',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.blue[500],
                                              // color: Colors.grey[900],
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w600
                                          ),
                                          softWrap: true,
                                        ),
                                        SizedBox(height: .0),
                                        Text(
                                          // nf.owner,
                                          // widget.user.first_name /*+ " " + user.last_name*/,
                                          //allUsers[0].nome,
                                          "@" + /*allUsers[0].username*/widget.user.username!,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.grey[500],
                                            // color: Colors.blue[500],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 11.5),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                                widget.user.description ?? '',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.grey[800],
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w500
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                                SizedBox(
                                    height: widget.user.description == null || widget.user.description == '' ? 20.0 : 40
                                ),

                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      // Visibility(
                                      //   visible: Utils.user!.id == widget.user!.id,
                                      //   // maintainSize: false,
                                      //   // maintainState: false,
                                      //   // maintainSemantics: false,
                                      //   // maintainInteractivity: false,
                                      //   // maintainAnimation: false,
                                      //   child: InkWell(
                                      //     onTap: (){
                                      //       //print(Utils.user!.id == widget.user!.id);
                                      //       // Navigator.push(
                                      //       //     context,
                                      //       //     PageTransition(
                                      //       //         duration: const Duration(milliseconds: 500),
                                      //       //         alignment: Alignment.center,
                                      //       //         type: PageTransitionType.fade,
                                      //       //         child: FollowersScreen(
                                      //       //           user: widget.user,
                                      //       //           followers: followers,
                                      //       //         )
                                      //       //     )
                                      //       // );
                                      //     },
                                      //     child: Column(
                                      //       children: [
                                      //         Text(
                                      //           Utils.user!.id == widget.user!.id ? favoriteProvider.favoritesList.length.toString() : "",
                                      //           // favoriteProvider.favoritesList.length.toString(),
                                      //           style: GoogleFonts.montserrat(
                                      //               fontSize: 18.0,
                                      //               color: Colors.blue,
                                      //               // color: Colors.grey[700],
                                      //               fontWeight: FontWeight.w600
                                      //           )
                                      //         ),
                                      //         Text(
                                      //             // 'Followers',
                                      //             'Preferiti',
                                      //             // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                      //             style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      InkWell(
                                        onTap: (){
                                          // Navigator.push(
                                          //     context,
                                          //     PageTransition(
                                          //         duration: const Duration(milliseconds: 500),
                                          //         alignment: Alignment.center,
                                          //         type: PageTransitionType.fade,
                                          //         child: SubscriptionsScreen(
                                          //           user: widget.user,
                                          //           subscriptions: subscriptions,
                                          //         )
                                          //     )
                                          // );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                // "52",
                                                  userBookingsList.length.toString(),
                                                  //   userProvider.events1.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //   subscriptions.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                  //     : widget.user.numEventi.toString(),
                                                  // style: GoogleFonts.montserrat(
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18.0,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w600
                                                  )
                                              ),
                                              Text(
                                                // 'Iscrizioni',
                                                  'Prenotazioni',
                                                  // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                  style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                              )
                                            ],
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
                                                  child: UserFriendsListScreen(
                                                    userFriends: userFriendsList,
                                                  )
                                              )
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                // "12",
                                                  userFriendsList.length.toString(),
                                                  //   businessFavoriteProvider.savedBusinessList!.length.toString(),
                                                  //   userFollowedList.length.toString(),
                                                  //   userProvider.events1.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //   subscriptions.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                  //     : widget.user.numEventi.toString(),
                                                  // style: GoogleFonts.montserrat(
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18.0,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w600
                                                  )
                                              ),
                                              Text(
                                                // 'Iscrizioni',
                                                  'Amici',
                                                  // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                  style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
                                          // Navigator.push(
                                          //     context,
                                          //     PageTransition(
                                          //         duration: const Duration(milliseconds: 500),
                                          //         alignment: Alignment.center,
                                          //         type: PageTransitionType.fade,
                                          //         child: SubscriptionsScreen(
                                          //           user: widget.user,
                                          //           subscriptions: subscriptions,
                                          //         )
                                          //     )
                                          // );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                // "52",
                                                //   businessFavoriteProvider.savedBusinessList!.length.toString(),
                                                  userFollowedList.length.toString(),
                                                  //   userProvider.events1.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //   subscriptions.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                  //     : widget.user.numEventi.toString(),
                                                  // style: GoogleFonts.montserrat(
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18.0,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w600
                                                  )
                                              ),
                                              Text(
                                                // 'Iscrizioni',
                                                  'Seguiti',
                                                  // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                  style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
                                          // Navigator.push(
                                          //     context,
                                          //     PageTransition(
                                          //         duration: const Duration(milliseconds: 500),
                                          //         alignment: Alignment.center,
                                          //         type: PageTransitionType.fade,
                                          //         child: SubscriptionsScreen(
                                          //           user: widget.user,
                                          //           subscriptions: subscriptions,
                                          //         )
                                          //     )
                                          // );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                // "52",
                                                //   favoriteProvider.favoritesList.length.toString(),
                                                  userFavoriteList.length.toString(),
                                                  //   userProvider.events1.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //   subscriptions.length.toString(),
                                                  // widget.user.numEventi >= 10000
                                                  //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                  //     : widget.user.numEventi.toString(),
                                                  // style: GoogleFonts.montserrat(
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18.0,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w600
                                                  )
                                              ),
                                              Text(
                                                // 'Iscrizioni',
                                                  'Preferiti',
                                                  // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                                  style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Visibility(
                                      //   visible: Utils.isEventsEnabled,
                                      //   maintainSize: false,
                                      //   maintainInteractivity: false,
                                      //   maintainAnimation: false,
                                      //   maintainSemantics: false,
                                      //   maintainState: false,
                                      //   replacement: SizedBox(),
                                      //   child: InkWell(
                                      //     onTap: (){
                                      //       // Navigator.push(
                                      //       //     context,
                                      //       //     PageTransition(
                                      //       //         duration: const Duration(milliseconds: 500),
                                      //       //         alignment: Alignment.center,
                                      //       //         type: PageTransitionType.fade,
                                      //       //         child: SubscriptionsScreen(
                                      //       //           user: widget.user,
                                      //       //           subscriptions: subscriptions,
                                      //       //         )
                                      //       //     )
                                      //       // );
                                      //     },
                                      //     child: Column(
                                      //       children: [
                                      //         Text(
                                      //           // "52",
                                      //           // socketProvider.eventTicketsList.length.toString(),
                                      //             eventTicketList1.length.toString(),
                                      //             //   userProvider.events1.length.toString(),                                    // widget.user.numEventi >= 10000
                                      //             //   subscriptions.length.toString(),                                    // widget.user.numEventi >= 10000
                                      //             //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                      //             //     : widget.user.numEventi.toString(),
                                      //             // style: GoogleFonts.montserrat(
                                      //             style: GoogleFonts.montserrat(
                                      //                 fontSize: 18.0,
                                      //                 color: Colors.blue,
                                      //                 fontWeight: FontWeight.w600
                                      //             )
                                      //         ),
                                      //         Text(
                                      //           // 'Iscrizioni',
                                      //             'Biglietti',
                                      //             // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                                      //             style: TextStyle(fontSize: 11.0, color: Colors.grey)
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      // Visibility(
                                      //   visible: Utils.user!.id == widget.user!.id,
                                      //   child: InkWell(
                                      //     onTap: (){
                                      //       // Navigator.push(
                                      //       //     context,
                                      //       //     PageTransition(
                                      //       //         duration: const Duration(milliseconds: 500),
                                      //       //         alignment: Alignment.center,
                                      //       //         type: PageTransitionType.fade,
                                      //       //         child: FollowsScreen(
                                      //       //           user: widget.user,
                                      //       //           follows: follows,
                                      //       //         )
                                      //       //     )
                                      //       // );
                                      //     },
                                      //     child: Column(
                                      //       children: [
                                      //         Text(
                                      //           Utils.user!.id == widget.user!.id ? businessFavoriteProvider.savedBusinessList!.length.toString() : "",
                                      //           // prestazioniList.length.toString(),
                                      //           // businessFavoriteProvider.savedBusinessList.length.toString(),
                                      //           // seguiti.toString(),
                                      //
                                      //           //   userProvider.seguiti.toString(),
                                      //
                                      //             // follows.length >= 10000
                                      //             //     ? ((follows.length/1000)./*toInt().*/truncate()).toString() + "mila"
                                      //             //     : follows.length.toString(),
                                      //             style: GoogleFonts.montserrat(
                                      //                 fontSize: 18.0, color: Colors.blue, fontWeight: FontWeight.w600
                                      //             )
                                      //         ),
                                      //         Text(
                                      //             // 'Seguiti',
                                      //             // 'Locali',
                                      //             'Salvati',
                                      //             // style: GoogleFonts.montserrat(
                                      //             style: TextStyle(
                                      //                 fontSize: 11.0,
                                      //                 color: Colors.grey
                                      //             )
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                                // SizedBox(height: 40),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Visibility(
                                //       visible: status == -1,
                                //       child: Container(
                                //         width: MediaQuery.of(context).size.width * .8,
                                //         // width: MediaQuery.of(context).size.width * .4,
                                //         height: 40,
                                //         child: OutlinedButton(
                                //           style: ButtonStyle(
                                //               backgroundColor: MaterialStateProperty.all(Colors.white)
                                //             // elevation:,
                                //           ),
                                //           // OutlineButton(
                                //           // shape: RoundedRectangleBorder(
                                //           //     borderRadius: BorderRadius.all(Radius.circular(4))
                                //           // ),
                                //           onPressed: () async {
                                //             // if(status == -1) {
                                //             //   await sendFriendshipRequest();
                                //             // }
                                //           },
                                //           child: Text(
                                //             'Richiedi amicizia',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.w600,
                                //                 color: Colors.grey[800]
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     // status == 0 ? SizedBox(width: 25,) : SizedBox(),
                                //     Visibility(
                                //       visible: status == 0,
                                //       child: Container(
                                //         width: MediaQuery.of(context).size.width * .8,
                                //         // width: MediaQuery.of(context).size.width * .4,
                                //         height: 40,
                                //         child: OutlinedButton(
                                //           style: ButtonStyle(
                                //             backgroundColor: MaterialStateProperty.all(status == -1 ? Colors.white : Colors.blue)
                                //             // elevation:,
                                //           ),
                                //           // OutlineButton(
                                //           // shape: RoundedRectangleBorder(
                                //           //     borderRadius: BorderRadius.all(Radius.circular(4))
                                //           // ),
                                //           onPressed: () async {
                                //             // if(status == -1) {
                                //             //   await sendFriendshipRequest();
                                //             // }
                                //           },
                                //           child: Text(
                                //             status == -1 ? 'Richiedi amicizia' : 'Richiesta inviata',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.w600,
                                //                 color: status == -1 ? Colors.grey[800] : Colors.grey[50]
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     // status == -1 ? SizedBox(width: 25,) : SizedBox(),
                                //     Visibility(
                                //       visible: status == 1,
                                //       child: Container(
                                //         // width: MediaQuery.of(context).size.width * .8,
                                //         width: MediaQuery.of(context).size.width * .4,
                                //         height: 40,
                                //         child: OutlinedButton(
                                //           style: ButtonStyle(
                                //
                                //             // elevation:,
                                //           ),
                                //           // OutlineButton(
                                //           // shape: RoundedRectangleBorder(
                                //           //     borderRadius: BorderRadius.all(Radius.circular(4))
                                //           // ),
                                //           onPressed: (){
                                //
                                //           },
                                //           child: Text(
                                //             'Amico',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.w600,
                                //                 color: Colors.grey[800]
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     status == 1 ? SizedBox(width: 25,) : SizedBox(),
                                //     Visibility(
                                //       visible: status == 1,
                                //       child: Container(
                                //         // width: MediaQuery.of(context).size.width * .8,
                                //         width: MediaQuery.of(context).size.width * .4,
                                //         height: 40,
                                //         child: OutlinedButton(
                                //           style: ButtonStyle(
                                //               backgroundColor: MaterialStateProperty.all(Colors.blue)
                                //             // elevation:,
                                //           ),
                                //           // OutlineButton(
                                //           // shape: RoundedRectangleBorder(
                                //           //     borderRadius: BorderRadius.all(Radius.circular(4))
                                //           // ),
                                //           onPressed: (){
                                //
                                //           },
                                //           child: Text(
                                //             'Chat',
                                //             style: TextStyle(
                                //                 fontWeight: FontWeight.w600,
                                //                 color: Colors.grey[50]
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     // status == -1 ? SizedBox(width: 25,) : SizedBox(),
                                //     // Visibility(
                                //     //   visible: Utils.isEventsEnabled,
                                //     //   child: Container(
                                //     //     // width: MediaQuery.of(context).size.width * .8,
                                //     //     width: MediaQuery.of(context).size.width * .4,
                                //     //     height: 40,
                                //     //     child: OutlinedButton(
                                //     //       style: ButtonStyle(
                                //     //
                                //     //         // elevation:,
                                //     //       ),
                                //     //       // OutlineButton(
                                //     //       // shape: RoundedRectangleBorder(
                                //     //       //     borderRadius: BorderRadius.all(Radius.circular(4))
                                //     //       // ),
                                //     //       onPressed: (){
                                //     //         // Route route = MaterialPageRoute(builder: (context) => Activities());
                                //     //         // Navigator.push(context, route);
                                //     //         Navigator.push(
                                //     //             context,
                                //     //             PageTransition(
                                //     //                 duration: const Duration(milliseconds: 500),
                                //     //                 alignment: Alignment.center,
                                //     //                 type: PageTransitionType.fade,
                                //     //                 child: UserEventTicketsScreen()
                                //     //             )
                                //     //         );
                                //     //       },
                                //     //       child: Text(
                                //     //         'Biglietti',
                                //     //         style: TextStyle(
                                //     //           fontWeight: FontWeight.w600,
                                //     //           color: Colors.grey[800]
                                //     //         ),
                                //     //       ),
                                //     //     ),
                                //     //   ),
                                //     // ),
                                //   ],
                                // ),
                                SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: TabBarSliverPersistentHeaderDelegate(
                            extent: 48,
                            child: Container(
                              height: 48,
                              // height: 70,
                              width: MediaQuery.of(context).size.width,
                              child: TabBar(
                                // indicatorColor: Theme.of(context).colorScheme.onBackground,
                                indicatorColor: Colors.transparent,
                                // isScrollable: true,
                                isScrollable: false,
                                // indicatorColor: Colors.blue,
                                labelColor: Colors.blue[500],
                                unselectedLabelColor: Colors.grey[500],
                                tabs: [
                                  // Tab(icon: Icon(Icons.grid_on),),
                                  // Tab(icon: Icon(Icons.person_outline),)
                                  Tab(
                                      child: Marquee(
                                          animationDuration: Duration(milliseconds: 1000),
                                          backDuration: Duration(milliseconds: 1000),
                                          // backwardAnimation: Curves.easeOutBack,
                                          child: Row(
                                            children: [
                                              Text(
                                                // 'Appuntamenti',
                                                'Prestazioni',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12
                                                ),
                                              ),
                                              SizedBox(width: 4,),
                                              CircleAvatar(
                                                // backgroundColor: Colors.grey[300],                                                maxRadius: 11,
                                                backgroundColor: Colors.blue[400],
                                                maxRadius: 12,
                                                child: Center(
                                                  child: Text(
                                                    // '13',
                                                    // myAppointmentsList.length.toString(),
                                                    prestazioneList.length.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 10.0,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700
                                                    )
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                  ),
                                  // Tab(
                                  //     child: Marquee(
                                  //         animationDuration: Duration(milliseconds: 1000),
                                  //         backDuration: Duration(milliseconds: 1000),
                                  //         // backwardAnimation: Curves.easeOutBack,
                                  //         child: Row(
                                  //           children: [
                                  //             Text(
                                  //               'Eventi',
                                  //               maxLines: 1,
                                  //               overflow: TextOverflow.ellipsis,
                                  //               style: TextStyle(
                                  //                   fontSize: 12
                                  //               ),
                                  //             ),
                                  //             SizedBox(width: 4,),
                                  //             CircleAvatar(
                                  //               // backgroundColor: Colors.grey[300],                                                maxRadius: 11,
                                  //               backgroundColor: Colors.blue[400],
                                  //               maxRadius: 12,
                                  //               child: Center(
                                  //                 child: Text(
                                  //                   // '13',
                                  //                     eventReservationList.length.toString(),
                                  //                     textAlign: TextAlign.center,
                                  //                     style: GoogleFonts.montserrat(
                                  //                         fontSize: 10.0,
                                  //                         color: Colors.white,
                                  //                         fontWeight: FontWeight.w700
                                  //                     )
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         )
                                  //     )
                                  // ),
                                  Tab(
                                      child: Marquee(
                                          animationDuration: Duration(milliseconds: 1000),
                                          backDuration: Duration(milliseconds: 1000),
                                          // backwardAnimation: Curves.easeOutBack,
                                          child: Row(
                                            children: [
                                              Text(
                                                'Post',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12
                                                ),
                                              ),
                                              SizedBox(width: 4,),
                                              CircleAvatar(
                                                // backgroundColor: Colors.grey[300],                                                maxRadius: 11,
                                                backgroundColor: Colors.blue[400],
                                                maxRadius: 12,
                                                child: Center(
                                                  child: Text(
                                                    // '13',
                                                      userPostList.length.toString(),
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.montserrat(
                                                          fontSize: 10.0,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                  ),
                                  Tab(
                                    child: Marquee(
                                      animationDuration: Duration(milliseconds: 1000),
                                      backDuration: Duration(milliseconds: 1000),
                                      // backwardAnimation: Curves.easeOutBack,
                                      child: Row(
                                        children: [
                                          const Text(
                                            // 'Appuntamenti',
                                            // 'Locali',
                                            'Visitati',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12
                                            ),
                                          ),
                                          SizedBox(width: 4,),
                                          CircleAvatar(
                                            // backgroundColor: Colors.grey[300],                                                maxRadius: 11,
                                            backgroundColor: Colors.blue[400],
                                            radius: 12,
                                            child: Center(
                                              child: Text(
                                                // '7',
                                                businessList.length.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10.0,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700
                                                )
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    )
                                  ),
                                ],
                              ),
                            )
                          ),
                        ),
                      ];
                    },
                    body: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: TabBarView(
                          children: [
                            prestazioneList.isEmpty ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * .035,),
                                Center(
                                  child: Image.asset(
                                    'assets/png/Saly-3.png',
                                    height: MediaQuery.of(context).size.height * .2,
                                    // width: MediaQuery.of(context).size.width * .7,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                Center(
                                  child: Text(
                                    // 'Non ci sono ancora notifiche...',
                                    "Non ci sono prestazioni",
                                    // 'Le mie prestazioni',
                                    style: TextStyle(
                                      // color: Colors.blue,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                              ],
                            ) : GridView.builder(
                                padding: EdgeInsets.all(2),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1.66,
                                    // childAspectRatio: 1,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                ),
                                // itemCount: myAppointmentsList.length,
                                itemCount: prestazioneList.length,
                                itemBuilder: (context, i) {
                                  // SingleEventTicket singleEventTicket = new SingleEventTicket(
                                  //   // id: postProvider.posts[i]['post_id'].toInt(),
                                  //   id: postProvider.posts[i]['post_id'],
                                  //   description: postProvider.posts[i]['post_description'],
                                  //   bookingTime: DateTime.tryParse(postProvider.posts[i]['post_created_at']),
                                  //   // exhibition_id: int.parse(postProvider.posts[i]['exhibition_id']),
                                  //   image_video: postProvider.posts[i]['image_video'],
                                  //   // user_id: int.parse(postProvider.posts[i]['user_id']),
                                  //   user_id: postProvider.posts[i]['user_id'].toInt(),
                                  //   title: postProvider.posts[i]['post_title'],
                                  // );
                                  // return Image.asset(
                                  //   'assets/sample/search_demo1.jpg',
                                  //   fit: BoxFit.cover,
                                  // );
                                  return InkWell(
                                    onTap: (){
                                      // Navigator.push(
                                      //     context,
                                      //     PageTransition(
                                      //       duration: const Duration(milliseconds: 500),
                                      //       alignment: Alignment.center,
                                      //       type: PageTransitionType.fade,
                                      //       child: PrestazioneScreen(
                                      //         // prestazione: new Prestazione(
                                      //         //   id: myAppointmentsList[i]['prestazione_id'],
                                      //         //   business: new Business(
                                      //         //     id: myAppointmentsList[i]['business_id'],
                                      //         //     name: myAppointmentsList[i]['business_name'],
                                      //         //     is_booking_business: myAppointmentsList[i]['business_type_id'],
                                      //         //     profile_image: myAppointmentsList[i]['business_image'],
                                      //         //     description: myAppointmentsList[i]['business_description'],
                                      //         //     address: myAppointmentsList[i]['business_address'],
                                      //         //     phone_number: myAppointmentsList[i]['business_phone_number'],
                                      //         //     max_contemporary_appointments: myAppointmentsList[i]['max_contemporary_appointments'],
                                      //         //   ),
                                      //         //   price: myAppointmentsList[i]['prestazione_price'],
                                      //         //   image: myAppointmentsList[i]['prestazione_image'],
                                      //         //   duration: myAppointmentsList[i]['prestazione_duration'],
                                      //         //   title: myAppointmentsList[i]['prestazione_title'],
                                      //         //   description: myAppointmentsList[i]['prestazione_description'],
                                      //         //   last_modification_at: DateTime.tryParse(myAppointmentsList[i]['prestazione_last_modification_at']),
                                      //         // ),
                                      //         prestazione: prestazioneList[i],
                                      //       ),
                                      //     )
                                      // );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      elevation: 8,
                                      child: Stack(
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        fit: StackFit.expand,
                                        children: [
                                          FutureImage(
                                            prestazioneList[i]!.image != null && prestazioneList[i]!.image != ''
                                                ? prestazioneList[i]!.image! : prestazioneList[i]!.business!.profile_image!,
                                            // colorBlendMode: BlendMode.hardLight,
                                            width: MediaQuery.of(context).size.width,
                                            // filterQuality: FilterQuality.high,
                                            // placeholder: (context, url) => Center(
                                            //     child: CircularProgressIndicator()
                                            // ),
                                          ),
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              // backgroundBlendMode: BlendMode.darken,
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomLeft,
                                                end: Alignment.topRight,
                                                colors: [
                                                  Colors.black,
                                                  // Colors.transparent,
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 15,
                                            left: 15,
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                GradientText(
                                                  prestazioneList[i]!.business!.name!,
                                                  // 'A partire da € 60,00',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.bottomLeft,
                                                      end: Alignment.topRight,
                                                      colors: [
                                                        // Color(0xff8921aa),
                                                        // Color(0xffDA44bb),

                                                        Color(0xffFFA818),
                                                        Color(0xffFFB75E),
                                                      ]
                                                  ),

                                                  // gradient: LinearGradient(
                                                  //     begin: Alignment.bottomLeft,
                                                  //     end: Alignment.topRight,
                                                  //     colors: [
                                                  //       Colors.blue[500],
                                                  //       Color(0xffDA44bb),
                                                  //
                                                  //       Color(0xff8921aa),
                                                  //     ]
                                                  // ),
                                                  style: TextStyle(
                                                      color: Colors.blue[500],
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 13
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                GradientText(
                                                  prestazioneList[i]!.title!,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  gradient: Gradients.haze,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 15
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ),

                            userPostList.isEmpty ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * .035,),
                                Center(
                                  child: Image.asset(
                                    'assets/png/Saly-3.png',
                                    height: MediaQuery.of(context).size.height * .2,
                                    // width: MediaQuery.of(context).size.width * .7,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                Center(
                                  child: Text(
                                    "Non ci sono post",
                                    // 'Le mie prestazioni',
                                    style: TextStyle(
                                      // color: Colors.blue,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                              ],
                            ) : GridView.builder(
                              padding: EdgeInsets.all(2),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  // childAspectRatio: 1.66,
                                  childAspectRatio: .6,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                ),
                              // itemCount: myAppointmentsList.length,
                              itemCount: userPostList.length,
                              itemBuilder: (context, i) {
                                return InkWell(
                                  onTap: (){
                                    // setState(() {
                                    //   socketProvider.setBottomBarVisibility(false);
                                    //   socketProvider.isBottomBarVisible = false;
                                    // });
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(milliseconds: 500),
                                            alignment: Alignment.center,
                                            type: PageTransitionType.fade,
                                            child: PostFullScreen(
                                              // memoryImage: imageCacheBusiness.getImageFromCache(userPostList[i].image_url!)!,
                                              businessPost: userPostList[i],
                                            )
                                        )
                                    );
                                    // socketProvider.setBottomBarVisibility(true);
                                  },
                                  child: Card(
                                    margin: EdgeInsets.all(2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 8,
                                    child: Stack(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      fit: StackFit.expand,
                                      children: [
                                        FutureImage(
                                          userPostList[i].image_url!,
                                          width: MediaQuery.of(context).size.width,
                                        ),
                                        const DecoratedBox(
                                          decoration: BoxDecoration(
                                            // backgroundBlendMode: BlendMode.darken,
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight,
                                              colors: [
                                                Colors.black,
                                                // Colors.transparent,
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Positioned(
                                        //   right: 5,
                                        //   top: MediaQuery.of(context).size.height * 0.06,
                                        //   child: Column(
                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                        //     // crossAxisAlignment: CrossAxisAlignment.end,
                                        //     children: [
                                        //       InkWell(
                                        //         onTap: () async {
                                        //           // if (postProvider.isLikedPost){
                                        //           //   setState(() {
                                        //           //     /*await*/ postProvider.unlikeBusinessPost(
                                        //           //         item.id,
                                        //           //         userProvider!.user!.id
                                        //           //     );
                                        //           //   });
                                        //           // }
                                        //           // else{
                                        //           //   setState(() {
                                        //           //     /*await*/ postProvider.likeBusinessPost(
                                        //           //       item.id,
                                        //           //       userProvider!.user!.id
                                        //           //     );
                                        //           //   });
                                        //           // }
                                        //         },
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.only(bottom: .0, top: 11, left: 6, right: 6),
                                        //           child: Row(
                                        //             children: [
                                        //               Icon(
                                        //                 // Icons.reply,
                                        //                 Icons.favorite_border_outlined,
                                        //                 color: Colors.grey[50],
                                        //                 // color: Colors.red[500],
                                        //                 // color: Colors.pink[300],
                                        //                 size: 15,
                                        //               ),
                                        //               SizedBox(width: 5,),
                                        //               Text(
                                        //                 // '27',
                                        //                 /*postLikes*/postProvider.postLikes.length.toString(),
                                        //                   overflow: TextOverflow.ellipsis,
                                        //                   style: GoogleFonts.lato(
                                        //                     fontWeight: FontWeight.w700,
                                        //                     color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                        //                     // color: Colors.red[500],
                                        //                     // color: Colors.pink[300],
                                        //                     fontSize: 12,
                                        //                   )
                                        //               )
                                        //             ],
                                        //           ),
                                        //         ),
                                        //       ),
                                        //       SizedBox(height: 5,),
                                        //       InkWell(
                                        //         onTap: () {
                                        //           // Navigator.push(
                                        //           //     context,
                                        //           //     PageTransition(
                                        //           //       duration: const Duration(
                                        //           //           milliseconds: 500
                                        //           //       ),
                                        //           //       alignment: Alignment.center,
                                        //           //       type: PageTransitionType.fade,
                                        //           //       child: PostCommentsScreen(
                                        //           //         isSingleEventPost: false,
                                        //           //         myUser: userProvider!.user,
                                        //           //         businessPost: BusinessPost(
                                        //           //           id: item.id,
                                        //           //         ),
                                        //           //       ),
                                        //           //     )
                                        //           // );
                                        //         },
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.only(bottom: 0, top: 11, left: 6, right: 6),
                                        //           child: Row(
                                        //             children: [
                                        //               Icon(
                                        //                 // Icons.mode_comment_outlined,
                                        //                 Icons.sms_outlined,
                                        //                 color: Colors.grey[50],
                                        //                 // color: Colors.blue[400],
                                        //                 size: 15,
                                        //               ),
                                        //               SizedBox(width: 5,),
                                        //               Text(
                                        //                 // '320',
                                        //                 // bookingPostCommentNumber.toString(),
                                        //                 //   postProvider.comments!.length.toString(),
                                        //                   postProvider.postComments.length.toString(),
                                        //                   overflow: TextOverflow.ellipsis,
                                        //                   style: GoogleFonts.lato(
                                        //                     fontWeight: FontWeight.w700,
                                        //                     color: Colors.white,
                                        //                     fontSize: 12,
                                        //                   )
                                        //               )
                                        //             ],
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        Positioned(
                                          right: 5,
                                          // top: 50,
                                          child: InkWell(
                                            // onTap: (){
                                            //   Navigator.push(
                                            //       context,
                                            //       PageTransition(
                                            //         duration: const Duration(
                                            //             milliseconds: 500
                                            //         ),
                                            //         alignment: Alignment.center,
                                            //         type: PageTransitionType.fade,
                                            //         child: PostFullScreen(
                                            //           businessPost: homeBusinessPostList[i],
                                            //           isNetworkLoaded: false,
                                            //         ),
                                            //       )
                                            //   );
                                            // },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: MediaQuery.of(context).size.height * .04,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaY: 30,
                                                      sigmaX: 30
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: 5, bottom: 15),
                                                    child: Container(
                                                      width: 50,
                                                      height: 130,
                                                      child: Column(
                                                        children: [
                                                          // InkWell(
                                                          //   onTap: () {
                                                          //     //print('isLikedPost');
                                                          //     //print(isLikedPost);
                                                          //     //print('review');
                                                          //     //print('andare in una listview in cui ci sono tutte le recensioni di quella prestazione');
                                                          //   },
                                                          //   child: Padding(
                                                          //     padding: const EdgeInsets.only(bottom: 11.0, top: 6, left: 6, right: 6),
                                                          //     child: Column(
                                                          //       children: [
                                                          //         // Icon(
                                                          //         //   Icons.star,
                                                          //         //   // color: Colors.grey[50],
                                                          //         //   color: Colors.yellow[500],
                                                          //         //   size: 25,
                                                          //         // ),
                                                          //         // SizedBox(height: 5,),
                                                          //         // Text(
                                                          //         //     '€\n25,50',
                                                          //         //     textAlign: TextAlign.center,
                                                          //         //     // overflow: TextOverflow.ellipsis,
                                                          //         //     style: GoogleFonts.roboto(
                                                          //         //       fontWeight: FontWeight.w800,
                                                          //         //       // color: Colors.grey[50],
                                                          //         //       color: Colors.white,
                                                          //         //       fontSize: 13,
                                                          //         //     )
                                                          //         // )
                                                          //       ],
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          InkWell(
                                                            // onTap: () async {
                                                            // if (postProvider.isLikedPost){
                                                            //   setState(() {
                                                            //     /*await*/ postProvider.unlikeBusinessPost(
                                                            //         homeBusinessPostList[i],
                                                            //         userProvider!.user!
                                                            //     );
                                                            //   });
                                                            // }
                                                            // else{
                                                            //   setState(() {
                                                            //     /*await*/ postProvider.likeBusinessPost(
                                                            //       // postProvider.postList[index].id,
                                                            //         homeBusinessPostList[i],
                                                            //         userProvider!.user!
                                                            //     );
                                                            //   });
                                                            // }
                                                            // },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 11.0, top: 11, left: 6, right: 6),
                                                              child: Column(
                                                                children: [
                                                                  Icon(
                                                                    // Icons.reply,
                                                                    /*postProvider.isLikedHomePost ? Icons.favorite_outlined :*/ Icons.favorite_border_outlined,
                                                                    color: /*postProvider.isLikedHomePost ? Colors.red :*/ Colors.grey[50],
                                                                    // color: Colors.red[500],
                                                                    // color: Colors.pink[300],
                                                                    size: 25,
                                                                  ),
                                                                  SizedBox(height: 5,),
                                                                  Text(
                                                                    // '27',
                                                                      userPostList[i].likes.length.toString(),
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: GoogleFonts.lato(
                                                                        fontWeight: FontWeight.w700,
                                                                        color: /*isLikedPost ? Colors.red[500] :*/ Colors.white,
                                                                        // color: Colors.red[500],
                                                                        // color: Colors.pink[300],
                                                                        fontSize: 12,
                                                                      )
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            // onTap: () {
                                                            // Navigator.push(
                                                            //     context,
                                                            //     PageTransition(
                                                            //       duration: const Duration(
                                                            //           milliseconds: 500
                                                            //       ),
                                                            //       alignment: Alignment.center,
                                                            //       type: PageTransitionType.fade,
                                                            //       child: PostCommentsScreen(
                                                            //           isSingleEventPost: false,
                                                            //           myUser: userProvider!.user!,
                                                            //           businessPost: homeBusinessPostList[i]
                                                            //       ),
                                                            //     )
                                                            // );
                                                            // },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 6, top: 11, left: 6, right: 6),
                                                              child: Column(
                                                                children: [
                                                                  Icon(
                                                                    // Icons.mode_comment_outlined,
                                                                    Icons.sms_outlined,
                                                                    color: Colors.grey[50],
                                                                    // color: Colors.blue[400],
                                                                    size: 25,
                                                                  ),
                                                                  SizedBox(height: 5,),
                                                                  Text(
                                                                    // '320',
                                                                    // bookingPostCommentNumber.toString(),
                                                                    //   postProvider.comments!.length.toString(),
                                                                      userPostList[i].comments.length.toString(),
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: GoogleFonts.lato(
                                                                        fontWeight: FontWeight.w700,
                                                                        color: Colors.white,
                                                                        fontSize: 12,
                                                                      )
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // child: Text(
                                                    //   // categories[i].name,
                                                    //   'category.name',
                                                    //   overflow: TextOverflow.ellipsis,
                                                    //   style: GoogleFonts.lato(
                                                    //     fontWeight: FontWeight.w700,
                                                    //     color: Colors.white,
                                                    //     fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 15,
                                          left: 15,
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // GradientText(
                                              //   // eventTicketList[i]!.business!.name!,
                                              //   // userPostList[i].booking!.prestazione!.title!,
                                              //   // "${userPostList[i].booking!.prestazione!.duration} min",
                                              //   // "@${userPostList[i].booking!.user!.username}",
                                              //   "@${userPostList[i].user!.username}",
                                              //   // '€ ' + NumberFormat.currency(
                                              //   //     decimalDigits: 2,
                                              //   //     symbol: '',
                                              //   //     locale: 'IT_it'
                                              //   // ).format(userPostList[i].booking!.prestazione!.price),
                                              //   overflow: TextOverflow.ellipsis,
                                              //   maxLines: 1,
                                              //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                              //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                              //   gradient: LinearGradient(
                                              //       begin: Alignment.bottomLeft,
                                              //       end: Alignment.topRight,
                                              //       colors: [
                                              //         // Color(0xff8921aa),
                                              //         // Color(0xffDA44bb),
                                              //
                                              //         Color(0xffFFA818),
                                              //         Color(0xffFFB75E),
                                              //       ]
                                              //   ),
                                              //   // gradient: LinearGradient(
                                              //   //     begin: Alignment.bottomLeft,
                                              //   //     end: Alignment.topRight,
                                              //   //     colors: [
                                              //   //       Colors.blue[500],
                                              //   //       Color(0xffDA44bb),
                                              //   //
                                              //   //       Color(0xff8921aa),
                                              //   //     ]
                                              //   // ),
                                              //   style: TextStyle(
                                              //       color: Colors.blue[500],
                                              //       fontWeight: FontWeight.w700,
                                              //       // fontSize: 13
                                              //       fontSize: 12
                                              //   ),
                                              //   textAlign: TextAlign.left,
                                              // ),
                                              // SizedBox(height: 1,),
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: FutureImage(
                                                      userPostList[i].prestazione!.image != null && userPostList[i].prestazione!.image != ''
                                                          ? userPostList[i].prestazione!.image!
                                                          : userPostList[i].business!.profile_image!,
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4,),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * .3,
                                                    child: Marquee(
                                                      child: GradientText(
                                                        // eventTicketList[i]!.title!,
                                                        // userPostList[i].booking!.prestazione!.title!,
                                                        userPostList[i].prestazione!.title!,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                        gradient: Gradients.haze,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // SizedBox(height: 5),
                                              // Container(
                                              //   width: MediaQuery.of(context).size.width * .25,
                                              //   child: /*Gradient*/Text(
                                              //     // eventTicketList[i]!.title!,
                                              //     userPostList[i].description! ?? '',
                                              //     maxLines: 3,
                                              //     overflow: TextOverflow.ellipsis,
                                              //     // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                              //     // gradient: Gradients.haze,
                                              //     style: TextStyle(
                                              //         color: Colors.grey[200],
                                              //         fontWeight: FontWeight.w700,
                                              //         fontSize: 12
                                              //     ),
                                              //     textAlign: TextAlign.left,
                                              //   ),
                                              // ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: MediaQuery.of(context).size.width * .4,
                                                child: /*Gradient*/Text(
                                                  // eventTicketList[i]!.title!,
                                                  userPostList[i].description! ?? '',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  // gradient: Gradients.haze,
                                                  style: TextStyle(
                                                      color: Colors.grey[200],
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 13
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              SizedBox(height: userPostList[i].description != null && userPostList[i].description != '' ? 10 : 0),
                                              Container(
                                                width: MediaQuery.of(context).size.width * .4,
                                                child: Marquee(
                                                  child: Text(
                                                    // eventTicketList[i]!.title!,
                                                    // DateFormat.yMMMMd('it_IT').format(userPostList[i].booking!.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                                    //     + ' alle ' + userPostList[i].booking!.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                                    DateFormat.yMMMMd('it_IT').format(userPostList[i].created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                                        + ' alle ' + userPostList[i].created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                    // gradient: Gradients.haze,
                                                    style: TextStyle(
                                                        color: Colors.grey[300],
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 11
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),

                            // eventReservationList.isEmpty ? ListView(
                            //   children: [
                            //     SizedBox(height: MediaQuery.of(context).size.height * .035,),
                            //     Center(
                            //       child: Image.asset(
                            //         'assets/png/Saly-3.png',
                            //         height: MediaQuery.of(context).size.height * .2,
                            //         // width: MediaQuery.of(context).size.width * .7,
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //     SizedBox(height: MediaQuery.of(context).size.height * .03,),
                            //     Center(
                            //       child: Text(
                            //         "Non ci sono eventi",
                            //         // 'Le mie prestazioni',
                            //         style: TextStyle(
                            //           // color: Colors.blue,
                            //             color: Colors.grey[500],
                            //             fontWeight: FontWeight.w700,
                            //             fontSize: 16
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ) : GridView.builder(
                            //     padding: EdgeInsets.all(2),
                            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            //       childAspectRatio: 1.66,
                            //       crossAxisCount: 2,
                            //       crossAxisSpacing: 0,
                            //       mainAxisSpacing: 0,
                            //     ),
                            //     // itemCount: myAppointmentsList.length,
                            //     itemCount: eventReservationList.length,
                            //     itemBuilder: (context, i) {
                            //       // SingleEventTicket singleEventTicket = new SingleEventTicket(
                            //       //   // id: postProvider.posts[i]['post_id'].toInt(),
                            //       //   id: postProvider.posts[i]['post_id'],
                            //       //   description: postProvider.posts[i]['post_description'],
                            //       //   bookingTime: DateTime.tryParse(postProvider.posts[i]['post_created_at']),
                            //       //   // exhibition_id: int.parse(postProvider.posts[i]['exhibition_id']),
                            //       //   image_video: postProvider.posts[i]['image_video'],
                            //       //   // user_id: int.parse(postProvider.posts[i]['user_id']),
                            //       //   user_id: postProvider.posts[i]['user_id'].toInt(),
                            //       //   title: postProvider.posts[i]['post_title'],
                            //       // );
                            //       // return Image.asset(
                            //       //   'assets/sample/search_demo1.jpg',
                            //       //   fit: BoxFit.cover,
                            //       // );
                            //       return InkWell(
                            //         onTap: (){
                            //           // Navigator.push(
                            //           //     context,
                            //           //     PageTransition(
                            //           //       duration: const Duration(milliseconds: 500),
                            //           //       alignment: Alignment.center,
                            //           //       type: PageTransitionType.fade,
                            //           //       child: EventScreen(
                            //           //         // prestazione: new Prestazione(
                            //           //         //   id: myAppointmentsList[i]['prestazione_id'],
                            //           //         //   business: new Business(
                            //           //         //     id: myAppointmentsList[i]['business_id'],
                            //           //         //     name: myAppointmentsList[i]['business_name'],
                            //           //         //     is_booking_business: myAppointmentsList[i]['business_type_id'],
                            //           //         //     profile_image: myAppointmentsList[i]['business_image'],
                            //           //         //     description: myAppointmentsList[i]['business_description'],
                            //           //         //     address: myAppointmentsList[i]['business_address'],
                            //           //         //     phone_number: myAppointmentsList[i]['business_phone_number'],
                            //           //         //     max_contemporary_appointments: myAppointmentsList[i]['max_contemporary_appointments'],
                            //           //         //   ),
                            //           //         //   price: myAppointmentsList[i]['prestazione_price'],
                            //           //         //   image: myAppointmentsList[i]['prestazione_image'],
                            //           //         //   duration: myAppointmentsList[i]['prestazione_duration'],
                            //           //         //   title: myAppointmentsList[i]['prestazione_title'],
                            //           //         //   description: myAppointmentsList[i]['prestazione_description'],
                            //           //         //   last_modification_at: DateTime.tryParse(myAppointmentsList[i]['prestazione_last_modification_at']),
                            //           //         // ),
                            //           //         event: eventReservationList[i],
                            //           //       ),
                            //           //     )
                            //           // );
                            //         },
                            //         child: Card(
                            //           margin: EdgeInsets.all(2),
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(10),
                            //           ),
                            //           clipBehavior: Clip.antiAliasWithSaveLayer,
                            //           elevation: 8,
                            //           child: Stack(
                            //             clipBehavior: Clip.antiAliasWithSaveLayer,
                            //             fit: StackFit.expand,
                            //             children: [
                            //               FutureImage(
                            //                 eventReservationList[i]!.image != null && eventReservationList[i]!.image != ''
                            //                     ? eventReservationList[i]!.image! : eventReservationList[i]!.business!.profile_image!,
                            //                 // colorBlendMode: BlendMode.hardLight,
                            //                 width: MediaQuery.of(context).size.width,
                            //                 // filterQuality: FilterQuality.high,
                            //                 // placeholder: (context, url) => Center(
                            //                 //     child: CircularProgressIndicator()
                            //                 // ),
                            //               ),
                            //               DecoratedBox(
                            //                 decoration: BoxDecoration(
                            //                   // backgroundBlendMode: BlendMode.darken,
                            //                   gradient: LinearGradient(
                            //                     begin: Alignment.bottomLeft,
                            //                     end: Alignment.topRight,
                            //                     colors: [
                            //                       Colors.black,
                            //                       // Colors.transparent,
                            //                       Colors.transparent,
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ),
                            //               Positioned(
                            //                 bottom: 15,
                            //                 left: 15,
                            //                 width: MediaQuery.of(context).size.width * 0.4,
                            //                 child: Column(
                            //                   crossAxisAlignment: CrossAxisAlignment.start,
                            //                   children: [
                            //                     GradientText(
                            //                       eventReservationList[i]!.business!.name!,
                            //                       overflow: TextOverflow.ellipsis,
                            //                       maxLines: 1,
                            //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                            //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                            //                       gradient: LinearGradient(
                            //                           begin: Alignment.bottomLeft,
                            //                           end: Alignment.topRight,
                            //                           colors: [
                            //                             Color(0xff8921aa),
                            //                             Color(0xffDA44bb),
                            //                             // Color(0xffDA44bb)
                            //                           ]
                            //                       ),
                            //                       // gradient: LinearGradient(
                            //                       //     begin: Alignment.bottomLeft,
                            //                       //     end: Alignment.topRight,
                            //                       //     colors: [
                            //                       //       Colors.blue[500],
                            //                       //       Color(0xffDA44bb),
                            //                       //
                            //                       //       Color(0xff8921aa),
                            //                       //     ]
                            //                       // ),
                            //                       style: TextStyle(
                            //                           color: Colors.blue,
                            //                           fontWeight: FontWeight.w700,
                            //                           fontSize: 13
                            //                       ),
                            //                       textAlign: TextAlign.left,
                            //                     ),
                            //                     GradientText(
                            //                       eventReservationList[i]!.title!,
                            //                       maxLines: 2,
                            //                       overflow: TextOverflow.ellipsis,
                            //                       shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                            //                       gradient: Gradients.haze,
                            //                       style: TextStyle(
                            //                           color: Colors.white,
                            //                           fontWeight: FontWeight.w700,
                            //                           fontSize: 15
                            //                       ),
                            //                       textAlign: TextAlign.left,
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       );
                            //     }
                            // ),

                            businessList.isEmpty ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * .035,),
                                Center(
                                  child: Image.asset(
                                    'assets/png/Saly-16.png',
                                    height: MediaQuery.of(context).size.height * .2,
                                    // width: MediaQuery.of(context).size.width * .7,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * .03,),
                                Center(
                                  child: Text(
                                    // 'Non ci sono ancora notifiche...',
                                    "Non ci sono locali visitati",
                                    // 'Le mie prestazioni',
                                    style: TextStyle(
                                      // color: Colors.blue,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                              ],
                            ) : GridView.builder(
                                padding: EdgeInsets.all(2),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 2
                                ),
                                // itemCount: 40,
                                // itemCount: myAppointmentsList.length,
                                itemCount: businessList.length,
                                itemBuilder: (context, i) {
                                  // SingleEventTicket singleEventTicket = new SingleEventTicket(
                                  //   // id: postProvider.posts[i]['post_id'].toInt(),
                                  //   id: postProvider.posts[i]['post_id'],
                                  //   description: postProvider.posts[i]['post_description'],
                                  //   bookingTime: DateTime.tryParse(postProvider.posts[i]['post_created_at']),
                                  //   // exhibition_id: int.parse(postProvider.posts[i]['exhibition_id']),
                                  //   image_video: postProvider.posts[i]['image_video'],
                                  //   // user_id: int.parse(postProvider.posts[i]['user_id']),
                                  //   user_id: postProvider.posts[i]['user_id'].toInt(),
                                  //   title: postProvider.posts[i]['post_title'],
                                  // );
                                  // return Image.asset(
                                  //   'assets/sample/search_demo1.jpg',
                                  //   fit: BoxFit.cover,
                                  // );

                                  return InkWell(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                            duration: const Duration(milliseconds: 500),
                                            alignment: Alignment.center,
                                            type: PageTransitionType.fade,
                                            child: BookingBusinessProfileScreen(
                                              business: businessList[i],
                                            )
                                          )
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      elevation: 8,
                                      child: Stack(
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        fit: StackFit.expand,
                                        children: [
                                          FutureImage(
                                            businessList[i]!.profile_image!,
                                            // colorBlendMode: BlendMode.hardLight,
                                            width: MediaQuery.of(context).size.width,
                                            // filterQuality: FilterQuality.high,
                                            // placeholder: (context, url) => Center(
                                            //     child: CircularProgressIndicator()
                                            // ),
                                          ),
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              // backgroundBlendMode: BlendMode.darken,
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomLeft,
                                                end: Alignment.topRight,
                                                colors: [
                                                  Colors.black,
                                                  // Colors.transparent,
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 15,
                                            left: 15,
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                GradientText(
                                                  businessList[i]!.name!,
                                                  // 'A partire da € 60,00',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                  // gradient: LinearGradient(
                                                  //     begin: Alignment.bottomLeft,
                                                  //     end: Alignment.topRight,
                                                  //     colors: [
                                                  //       Color(0xff8921aa),
                                                  //       Color(0xffDA44bb),
                                                  //       // Color(0xffDA44bb)
                                                  //     ]
                                                  // ),
                                                  // gradient: Gradients.haze,
                                                  gradient: LinearGradient(
                                                      begin: Alignment.bottomLeft,
                                                      end: Alignment.topRight,
                                                      colors: [
                                                        // Colors.blue[500]!,
                                                        // Color(0xffDA44bb),
                                                        //
                                                        // Color(0xff8921aa),
                                                        Color(0xffFFA818),
                                                        Color(0xffFFB75E),
                                                      ]
                                                  ),
                                                  style: TextStyle(
                                                      color: Colors.blue[500],
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 15
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context).size.width * .4,
                                                  child: GradientText(
                                                    businessList[i]!.address!,
                                                    maxLines: 4,
                                                    // overflow: TextOverflow.ellipsis,
                                                    shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                    gradient: Gradients.haze,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 13
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ),
                            /*GridView.builder(
                                padding: EdgeInsets.all(2),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 2
                                ),
                                itemCount: 40,
                                itemBuilder: (context, index) {
                                  return Image.asset('assets/sample/search_demo1.jpg', fit: BoxFit.cover,);
                                }
                            ),*/
                          ]
                      ),
                    ),
                ),
              ),
            );
          }
          else {
            return Center(child: CircularProgressIndicator(color: Colors.blue,),);
          }
        }
      ),
    );
  }
}
