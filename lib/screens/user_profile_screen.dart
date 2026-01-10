import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/main.dart';
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
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_business_profile_screen.dart';
import 'package:nurebo_admin/screens/home_screen.dart';
import 'package:nurebo_admin/screens/post_full_screen.dart';
import 'package:nurebo_admin/screens/prestazione_list_screen.dart';
import 'package:nurebo_admin/screens/user_friends_list_screen.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:nurebo_admin/widgets/tab_bar_sliver_persistent_header_delegate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class UserProfileScreen extends StatefulWidget {
  // final User? user;
  final String userId;
  // final bool isTab;

  const UserProfileScreen({super.key, /*this.user,*/ /*required this.isTab,*/ required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late NumberFormat formatter;
  List<EventReservation> eventTicketList1 = [];
  List<Event?> eventTicketList = [];
  List<Booking> userBookingsList = [];
  List userFollowedList = [];
  List userFavoriteList = [];
  List<User> userFriendsList = [];
  Future a = Future(() {},), b = Future(() {},), c = Future(() {},), d = Future(() {}), e = Future(() {},), f = Future(() {}), g = Future(() {}), h = Future(() {}), l = Future(() {}), m = Future(() {}),/* n = Future(() {}),*/ o = Future(() {}), all = Future(() {});
  // late UserProvider userProvider;
  // late PrestazioneFavoriteProvider favoriteProvider;
  // late BusinessFavoriteProvider businessFavoriteProvider;
  late PostProvider postProvider;
  late SocketProvider socketProvider;
  List<Prestazione?> prestazioneList = [];
  // List<BookingPost> userPostList = [];
  List<BusinessPost> userPostList = [];
  List<Business?> businessList = [];
  // List myPostLikesList = [];
  // int? friendshipRequestStatus = -1;
  ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  late User user;


  Future getUserAppointments() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/booking/shared");

    Map<String, dynamic> body = {
      'user_id': user!.id,
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
                // begin_at: DateTime.parse(jsonData['begin_at']).toLocal(),
                // end_at: DateTime.parse(jsonData['begin_at']).add(Duration(minutes: jsonData['prestazione_duration'].toInt())).toLocal(),
                // created_at: DateTime.parse(jsonData['created_at']).toLocal(),
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

  Future getUserFollows() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user/only_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/business/save");

    Map<String, dynamic> body = {
      'user_id': user!.id,
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
    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/prestazione/like");

    Map<String, dynamic> body = {
      'user_id': user!.id,
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
    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/post");

    Map<String, dynamic> body = {
      'user_id': user!.id,
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
          // results.addAll(jsonData);
          // results.shuffle();
          userPostList.add(
              BusinessPost(
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
                //   user: User(
                //     id: e['user_id'],
                //     email: e['user_email'],
                //     username: e['user_username'],
                //     name: e['user_name'],
                //     phone_number: e['user_phone_number'],
                //     profile_image: e['user_profile_image'],
                //     description: e['user_description'],
                //   ),
                //   begin_at: DateTime.tryParse(e['begin_at']),
                //   end_at: DateTime.parse(e['begin_at']).add(Duration(minutes: e['prestazione_duration'].toInt())),
                //   created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
                // ),
                user: User(
                  profile_image: e['user_profile_image'] ?? '',
                  id: e['user_id'],
                  username: e['user_username'],
                  email: e['user_email'],
                  name: e['user_name'],
                  description: e['user_description'],
                ),
                comments: [],
                likes: [],
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
    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/reservation");

    Map<String, dynamic> body = {
      "user_id": user!.id
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
          eventTicketList1.add(
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
                      begin_at: DateTime.tryParse(e['begin_at' ?? '']),
                      end_at: DateTime.tryParse(e['end_at'] ?? '')/*.add(Duration(minutes: ))*/,
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
                user: user,
                created_at: DateTime.parse(e['created_at'])/*.add(Duration(hours: 2))*/,
              )
          );
        // });
      }

      //print("eventTicketList1 111:");
      //print(eventTicketList1.length);

      return jsonData;
    }
  }

  Future getUserFriends() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user_friendship/status");
    var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/friend");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/friend/request/${user!.id}");

    // Map<String, String?> queryParameters = {
    //   'user_id': Utils.user!.id,
    //   // 'recipient_id': user!.id,
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
      // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
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
          // if(e['user_id'] != Utils.user!.id && e['recipient_id'] == Utils.user!.id){
            user = User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            );
          // }
          // else {
          //   user = User(
          //     id: e['recipient_id'],
          //     email: e['recipient_email'],
          //     username: e['recipient_username'],
          //     name: e['recipient_name'],
          //     profile_image: e['recipient_profile_image'],
          //     description: e['recipient_description'],
          //   );
          // }

          print("g65bgg65g65g655");
          print(user.id);
          userFriendsList.add(user);
        }

        // userFriendsList.addAll(jsonData);

      //print('status');
      //print(status);
      return jsonData;
    }
  }

  Future getUserPostComments() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/business/post/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${user!.id}/comment");

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

      postProvider.userProfilePostComments.clear();

      for(var e in jsonData) {
        for (BusinessPost post in userPostList) {
          if(e['post_id'] == post.id){
            PostComment postComment = PostComment(
              id: e['id'],
              is_admin: e['is_admin'],
              created_at: DateTime.parse(e['created_at']),
              text: e['text'],
              businessPost: post,
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
            postProvider.userProfilePostComments.add(postComment);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  Future getUserPostLikes() async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${user!.id}/business/post/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${user!.id}/like");

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

      postProvider.userProfilePostLikes.clear();
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
            postProvider.userProfilePostLikes.add(postlike);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  Future<User?> getUser() async {
    // await UserPreferences.init();

    var url = Uri.parse("${Utils.httpServerUrl}user/${widget.userId}");

    // Map<String, dynamic> body = {
    //   'id': UserPreferences.getUserId(),
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
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      User user = User(
        id: jsonData[0]['id'],
        description: jsonData[0]['description'],
        profile_image: jsonData[0]['profile_image'] ?? '',
        // first_name: jsonData[0]['first_name'],
        name: jsonData[0]['name'],
        username: jsonData[0]['username'],
        phone: jsonData[0]['phone'],
        email: jsonData[0]['email'],
        email_notification: jsonData[0]['email_notification'],
        longitude: jsonData[0]['longitude']?.toDouble(),
        latitude: jsonData[0]['latitude']?.toDouble(),
      );
      
      this.user = user;
      
      return user;
      // return jsonData;
    }

    return null;
  }

  Future callFutureBuilderMethods() async {
    await getUser();
    await Future.wait([
      // a = getAllSingleEvent(),
      b = getUserAppointments(),
      d = getUserPosts(),
      e = getUserFollows(),
      f = getUserFavorites(),
      g = /*user!.id == Utils.user!.id ? socketProvider.getUserFriends() :*/ getUserFriends(),
      h = getUserPostComments(),
      l = getUserPostLikes(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    // userProvider = Provider.of<UserProvider>(context, listen: false);
    // favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: false);

    initializeDateFormatting();
    formatter = NumberFormat("00");

    // (o = getUser()).then((value) {
    //   print('ffg54h54fhfhf54');
    //   print(value);
    //
    //   // if(user!.id != Utils.user!.id){
    //     socketProvider.isUserAlreadyFriend(user!);
    //   // }
    //   socketProvider.friendshipRequestStatus = -1;

      // Future.wait([
        all = callFutureBuilderMethods()/*,
      ])*/;
    // });

    // /*a = */getAllSingleEvent();
    // /*b = */getUserAppointments();
  }

  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context, listen: true);
    // favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    // businessFavoriteProvider = Provider.of<BusinessFavoriteProvider>(context, listen: true);
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
            //               user: user,
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
        // future: Future.wait([/*a,*/ b, /*c,*/ d, e, f, g, ]),
        // future: Future.wait([all, o]),
        future: all,
        initialData: [],
        builder: (context, snapshot) {
          // if(snapshot.connectionState == ConnectionState.done) {
            // print('dd5g5g5gcv5');
            // //print(socketProvider.myAppointmentsList[0].prestazione.id.toString());
            // prestazioniList.add(socketProvider.myAppointmentsList[0].prestazione);

          if(snapshot.connectionState == ConnectionState.done){
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
            // //print('prestazioniList.length.toString()');
            // //print(prestazioneList.length.toString());

            eventTicketList.clear();
            for(int j = 0; j < eventTicketList1.length; j++){
              Event? eventTemp;
              bool isPresent = false;
              eventTemp = eventTicketList1[j].eventTicket!.event;
              for(int k = 0; k < eventTicketList.length; k++){
                // if(e1.id.toString() == prestazioneTemp.id.toString()){
                if(eventTicketList[k]!.id.toString() == eventTemp!.id.toString()){
                  isPresent = true;
                  // prestazioniList.add(e1);
                  // break;
                }
              }
              if(isPresent == false){
                eventTicketList.add(eventTemp);
                // break;
              }
            }
            // //print('eventTicketList.length.toString()');
            // //print(eventTicketList.length.toString());

            businessList.clear();
            // //print(socketProvider.myAppointmentsList[0].prestazione.id.toString());
            // prestazioniList.add(socketProvider.myAppointmentsList[0].prestazione);
            for(var e in userBookingsList){
              Business? businessTemp;
              bool isPresent = false;
              // //print(e.business.profile_image.toString());
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
            for(var e in eventTicketList1){
              Business? businessTemp;
              bool isPresent = false;
              // //print(e.business.profile_image.toString());
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

            // //print('businessList.length.toString()');
            // //print(businessList.length.toString());
            return DefaultTabController(
              length: 3,
              // length: 4,
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
                                          child: user!.profile_image != null && user!.profile_image != '' ? FutureImage(
                                            user!.profile_image!,
                                            /*userProvider.user!.profile_image != null && userProvider.user!.profile_image != '' ? FutureImage(
                                                userProvider.user!.profile_image!,*/
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            height: MediaQuery.of(context).size.width * 0.3,
                                          // ) : ClipRRect(
                                          //   borderRadius: BorderRadius.circular(8),
                                          //   child: Container(
                                          //     width: MediaQuery.of(context).size.width * 0.3,
                                          //     height: MediaQuery.of(context).size.width * 0.3,
                                          //     color: Colors.grey[300],
                                          //   ),
                                          // ),
                                          ) : Image.asset(
                                            // Icons.account_circle_rounded,
                                            // 'assets/image/default-profile-account-unknown.jpg',
                                            'assets/image/default-avatar-profile-icon.jpg',
                                            // color: Colors.grey[700],
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            height: MediaQuery.of(context).size.width * 0.3,
                                            // size: 45,
                                          )
                                        ),
                                      ),
                                      SizedBox(height: 0.0),
                                      Text(
                                        user!.name ?? '',
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
                                        // user.first_name /*+ " " + user.last_name*/,
                                        //allUsers[0].nome,
                                        user!.username == null || user!.username == '' ? '' : "@${user!.username!}",
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
                                              user!.description ?? '',
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
                                  height: user!.description == null || user!.description == '' ? 15.0 : 30
                              ),

                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    // Visibility(
                                    //   visible: Utils.user!.id == user!.id,
                                    //   // maintainSize: false,
                                    //   // maintainState: false,
                                    //   // maintainSemantics: false,
                                    //   // maintainInteractivity: false,
                                    //   // maintainAnimation: false,
                                    //   child: InkWell(
                                    //     onTap: (){
                                    //       //print(Utils.user!.id == user!.id);
                                    //       // Navigator.push(
                                    //       //     context,
                                    //       //     PageTransition(
                                    //       //         duration: const Duration(milliseconds: 500),
                                    //       //         alignment: Alignment.center,
                                    //       //         type: PageTransitionType.fade,
                                    //       //         child: FollowersScreen(
                                    //       //           user: user,
                                    //       //           followers: followers,
                                    //       //         )
                                    //       //     )
                                    //       // );
                                    //     },
                                    //     child: Column(
                                    //       children: [
                                    //         Text(
                                    //           Utils.user!.id == user!.id ? favoriteProvider.favoritesList.length.toString() : "",
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
                                        //           user: user,
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
                                                // user.numEventi >= 10000
                                                //   subscriptions.length.toString(),
                                                // user.numEventi >= 10000
                                                //     ? ((user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                //     : user.numEventi.toString(),
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
                                              // user: user!,
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
                                                // user.numEventi >= 10000
                                                //   subscriptions.length.toString(),
                                                // user.numEventi >= 10000
                                                //     ? ((user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                //     : user.numEventi.toString(),
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
                                        //           user: user,
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
                                                // user.numEventi >= 10000
                                                //   subscriptions.length.toString(),
                                                // user.numEventi >= 10000
                                                //     ? ((user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                //     : user.numEventi.toString(),
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
                                        //           user: user,
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
                                                // user.numEventi >= 10000
                                                //   subscriptions.length.toString(),
                                                // user.numEventi >= 10000
                                                //     ? ((user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                                //     : user.numEventi.toString(),
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
                                    //       //           user: user,
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
                                    //             //   userProvider.events1.length.toString(),                                    // user.numEventi >= 10000
                                    //             //   subscriptions.length.toString(),                                    // user.numEventi >= 10000
                                    //             //     ? ((user.numEventi/1000).toInt().truncate()).toString() + "mila"
                                    //             //     : user.numEventi.toString(),
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
                                    //   visible: Utils.user!.id == user!.id,
                                    //   child: InkWell(
                                    //     onTap: (){
                                    //       // Navigator.push(
                                    //       //     context,
                                    //       //     PageTransition(
                                    //       //         duration: const Duration(milliseconds: 500),
                                    //       //         alignment: Alignment.center,
                                    //       //         type: PageTransitionType.fade,
                                    //       //         child: FollowsScreen(
                                    //       //           user: user,
                                    //       //           follows: follows,
                                    //       //         )
                                    //       //     )
                                    //       // );
                                    //     },
                                    //     child: Column(
                                    //       children: [
                                    //         Text(
                                    //           Utils.user!.id == user!.id ? businessFavoriteProvider.savedBusinessList!.length.toString() : "",
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
                              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                              /*Utils.user!.id == user!.id ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Utils.isEventsEnabled
                                          ? MediaQuery.of(context).size.width * .4
                                          : MediaQuery.of(context).size.width * .8,
                                      height: 40,
                                      child: OutlinedButton(
                                        style: ButtonStyle(

                                          // elevation:,
                                        ),
                                        // OutlineButton(
                                        // shape: RoundedRectangleBorder(
                                        //     borderRadius: BorderRadius.all(Radius.circular(4))
                                        // ),
                                        onPressed: (){
                                          // Route route = MaterialPageRoute(builder: (context) => Activities());
                                          // Navigator.push(context, route);
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  duration: const Duration(milliseconds: 500),
                                                  alignment: Alignment.center,
                                                  type: PageTransitionType.fade,
                                                  child: UserBookingListScreen()
                                              )
                                          );
                                        },
                                        child: Text(
                                          'Prenotazioni',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(width: 25,),
                                    Visibility(
                                      visible: Utils.isEventsEnabled,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 25),
                                        // width: MediaQuery.of(context).size.width * .8,
                                        width: MediaQuery.of(context).size.width * .4,
                                        height: 40,
                                        child: OutlinedButton(
                                          style: ButtonStyle(

                                            // elevation:,
                                          ),
                                          // OutlineButton(
                                          // shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.all(Radius.circular(4))
                                          // ),
                                          onPressed: (){
                                            // Route route = MaterialPageRoute(builder: (context) => Activities());
                                            // Navigator.push(context, route);
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    duration: const Duration(milliseconds: 500),
                                                    alignment: Alignment.center,
                                                    type: PageTransitionType.fade,
                                                    child: UserEventReservationsScreen(
                                                      user: user,
                                                    )
                                                )
                                            );
                                          },
                                          child: Text(
                                            'Biglietti',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              color: Colors.grey[800]

                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ) :*/
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
                              width: MediaQuery.of(context).size.width,
                              child: TabBar(
                                // indicatorColor: Theme.of(context).colorScheme.onBackground,
                                indicatorColor: Colors.transparent,
                                // isScrollable: true,
                                isScrollable: false,
                                // indicatorColor: Colors.blue,
                                labelColor: Colors.blue,
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
                                  //                     eventTicketList.length.toString(),
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
                                                // backgroundColor: Colors.grey[300],
                                                // maxRadius: 11,
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
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1.66,
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                              ),
                              // itemCount: myAppointmentsList.length,
                              itemCount: prestazioneList.length,
                              itemBuilder: (context, i) {
                                // SingleEventReservation singleEventReservation = new SingleEventReservation(
                                //   // id: postProvider.posts[i]['post_id'].toInt(),
                                //   id: postProvider.posts[i]['post_id'],
                                //   description: postProvider.posts[i]['post_description'],
                                //   bookingTime: DateTime.parse(postProvider.posts[i]['post_created_at']),
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
                                          child: PrestazioneListScreen(
                                            // prestazione: new Prestazione(
                                            //   id: myAppointmentsList[i]['prestazione_id'],
                                            //   business: new Business(
                                            //     id: myAppointmentsList[i]['business_id'],
                                            //     name: myAppointmentsList[i]['business_name'],
                                            //     is_booking_business: myAppointmentsList[i]['business_type_id'],
                                            //     profile_image: myAppointmentsList[i]['business_image'],
                                            //     description: myAppointmentsList[i]['business_description'],
                                            //     address: myAppointmentsList[i]['business_address'],
                                            //     phone_number: myAppointmentsList[i]['business_phone_number'],
                                            //     max_contemporary_appointments: myAppointmentsList[i]['max_contemporary_appointments'],
                                            //   ),
                                            //   price: myAppointmentsList[i]['prestazione_price'],
                                            //   image: myAppointmentsList[i]['prestazione_image'],
                                            //   duration: myAppointmentsList[i]['prestazione_duration'],
                                            //   title: myAppointmentsList[i]['prestazione_title'],
                                            //   description: myAppointmentsList[i]['prestazione_description'],
                                            //   last_modification_at: DateTime.parse(myAppointmentsList[i]['prestazione_last_modification_at']),
                                            // ),

                                            // prestazione: prestazioneList[i],
                                          ),
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
                                          prestazioneList[i]!.image != null && prestazioneList[i]!.image != ''
                                              ? prestazioneList[i]!.image! : prestazioneList[i]!.business!.profile_image!,
                                          width: MediaQuery.of(context).size.width,
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
                                                    color: Colors.blue,
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

                          // eventTicketList.isEmpty ? ListView(
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
                          //     itemCount: eventTicketList.length,
                          //     itemBuilder: (context, i) {
                          //       // SingleEventReservation singleEventReservation = new SingleEventReservation(
                          //       //   // id: postProvider.posts[i]['post_id'].toInt(),
                          //       //   id: postProvider.posts[i]['post_id'],
                          //       //   description: postProvider.posts[i]['post_description'],
                          //       //   bookingTime: DateTime.parse(postProvider.posts[i]['post_created_at']),
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
                          //           Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                 duration: const Duration(milliseconds: 500),
                          //                 alignment: Alignment.center,
                          //                 type: PageTransitionType.fade,
                          //                 child: EventScreen(
                          //                   // prestazione: new Prestazione(
                          //                   //   id: myAppointmentsList[i]['prestazione_id'],
                          //                   //   business: new Business(
                          //                   //     id: myAppointmentsList[i]['business_id'],
                          //                   //     name: myAppointmentsList[i]['business_name'],
                          //                   //     is_booking_business: myAppointmentsList[i]['business_type_id'],
                          //                   //     profile_image: myAppointmentsList[i]['business_image'],
                          //                   //     description: myAppointmentsList[i]['business_description'],
                          //                   //     address: myAppointmentsList[i]['business_address'],
                          //                   //     phone_number: myAppointmentsList[i]['business_phone_number'],
                          //                   //     max_contemporary_appointments: myAppointmentsList[i]['max_contemporary_appointments'],
                          //                   //   ),
                          //                   //   price: myAppointmentsList[i]['prestazione_price'],
                          //                   //   image: myAppointmentsList[i]['prestazione_image'],
                          //                   //   duration: myAppointmentsList[i]['prestazione_duration'],
                          //                   //   title: myAppointmentsList[i]['prestazione_title'],
                          //                   //   description: myAppointmentsList[i]['prestazione_description'],
                          //                   //   last_modification_at: DateTime.parse(myAppointmentsList[i]['prestazione_last_modification_at']),
                          //                   // ),
                          //                   event: eventTicketList[i],
                          //                 ),
                          //               )
                          //           );
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
                          //                 eventTicketList[i]!.image != null && eventTicketList[i]!.image != ''
                          //                 ? eventTicketList[i]!.image! : eventTicketList[i]!.business!.profile_image!,
                          //                 width: MediaQuery.of(context).size.width,
                          //               ),
                          //               const DecoratedBox(
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
                          //                       eventTicketList[i]!.business!.name!,
                          //                       overflow: TextOverflow.ellipsis,
                          //                       maxLines: 1,
                          //                       // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                          //                       // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                          //                       gradient: LinearGradient(
                          //                           begin: Alignment.bottomLeft,
                          //                           end: Alignment.topRight,
                          //                           colors: [
                          //                             // Color(0xff8921aa),
                          //                             // Color(0xffDA44bb),
                          //
                          //                             Color(0xffFFA818),
                          //                             Color(0xffFFB75E),
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
                          //                       eventTicketList[i]!.title!,
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
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                // childAspectRatio: 1.66,
                                childAspectRatio: .5,
                                crossAxisCount: 2,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                              ),
                              // itemCount: myAppointmentsList.length,
                              itemCount: userPostList.length,
                              itemBuilder: (context, i) {
                                BusinessPost post = userPostList[i];
                                // print('postProvider.userProfilePostLikes.length');
                                // print(postProvider.userProfilePostLikes.length);
                                // print('postProvider.userProfilePostComments.length');
                                // print(postProvider.userProfilePostComments.length);

                                int postLikesCount = 0;
                                for(PostLike e in postProvider.userProfilePostLikes){
                                  // print(userPostList[i].id);
                                  // print(e.businessPost!.id);
                                  if(userPostList[i].id == e.businessPost!.id){
                                    postLikesCount++;
                                  }
                                }

                                int postCommentsCount = 0;
                                for(PostComment e in postProvider.userProfilePostComments){
                                  // print(userPostList[i].id);
                                  // print(e.businessPost!.id);
                                  if(userPostList[i].id == e.businessPost!.id){
                                    postCommentsCount++;
                                  }
                                }

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
                                              // isNetworkLoaded: true,
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
                                        //                 postProvider.isLikedPost ? Icons.favorite_outlined : Icons.favorite_border_outlined,
                                        //                 color: postProvider.isLikedPost ? Colors.red : Colors.grey[50],
                                        //                 // color: Colors.red[500],
                                        //                 // color: Colors.pink[300],
                                        //                 size: 15,
                                        //               ),
                                        //               SizedBox(width: 5,),
                                        //               Text(
                                        //                 // '27',
                                        //                 // /*postLikes*/postProvider.postLikes.length.toString(),
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
                                        //                   postProvider.comments!.length.toString(),
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
                                                top: MediaQuery.of(context).size.height * .07,
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
                                                      width: 45,
                                                      height: 120,
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
                                                                    /*isLiked ? Icons.favorite_outlined : */Icons.favorite_border_outlined,
                                                                    color: /*isLiked ? Colors.red : */Colors.grey[50],
                                                                    // color: Colors.red[500],
                                                                    // color: Colors.pink[300],
                                                                    size: 20,
                                                                  ),
                                                                  SizedBox(height: 5,),
                                                                  Text(
                                                                    // '27',
                                                                    //   userPostList[i].likes.length.toString(),
                                                                      postLikesCount.toString(),
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
                                                                    size: 20,
                                                                  ),
                                                                  SizedBox(height: 5,),
                                                                  Text(
                                                                    // '320',
                                                                    // bookingPostCommentNumber.toString(),
                                                                    //   postProvider.comments!.length.toString(),
                                                                    //   userPostList[i].comments.length.toString(),
                                                                      postCommentsCount.toString(),
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
                                          left: 0,
                                          right: 0,
                                          // width: MediaQuery.of(context).size.width * 0.34,
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Marquee(
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(20),
                                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                                          child: FutureImage(
                                                            post.user!.profile_image ?? '',
                                                            // post.booking!.user.profile_image ?? '',
                                                            width: 25,
                                                            height: 25,
                                                          ),
                                                        ),
                                                        SizedBox(width: 5,),
                                                        GradientText(
                                                          // post.business!.name ?? '',
                                                          // '@' + post.user!.username! ?? '',
                                                          post.user!.name ?? '',
                                                          // post.booking!.user.name ?? '',
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
                                                                // Colors.pinkAccent
                                                                Colors.white,
                                                                Colors.white,
                                                                // Color(0xffDA44bb)
                                                                // Color(0xfffd746c),
                                                                // Color(0xffff9068),
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
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Marquee(
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                                          child: FutureImage(
                                                            // post.prestazione!.image ?? '',
                                                            post.prestazione!.image != null && post.prestazione!.image != ''
                                                                ? post.prestazione!.image!
                                                                : post.business!.profile_image!,
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            GradientText(
                                                              // post.business!.name ?? '',
                                                              // post.booking!.prestazione!.title ?? '',
                                                              post.prestazione!.title ?? '',
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
                                                                    // Color(0xffDA44bb)
                                                                    // Color(0xfffd746c),
                                                                    // Color(0xffff9068),
                                                                    // Colors.yellow,
                                                                    Colors.yellow[600]!,
                                                                    Color(0xffFFA818),
                                                                    // Color(0xffF68A3D),
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
                                                            SizedBox(height: 2,),
                                                            GradientText(
                                                              // post.business!.name ?? '',
                                                              // post.booking!.prestazione!.title ?? '',
                                                              post.business!.name ?? '',
                                                              // 'A partire da € 60,00',
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                              gradient: Gradients. hotLinear,
                                                              // gradient: LinearGradient(
                                                              //     begin: Alignment.bottomLeft,
                                                              //     end: Alignment.topRight,
                                                              //     colors: [
                                                              //       // Color(0xff8921aa),
                                                              //       // Color(0xffDA44bb),
                                                              //       // Color(0xffDA44bb)
                                                              //       // Color(0xfffd746c),
                                                              //       // Color(0xffff9068),
                                                              //       Colors.yellow,
                                                              //       Colors.yellow,
                                                              //     ]
                                                              // ),
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
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                                  Visibility(
                                                    visible: post.description != null,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width * .4,
                                                      child: GradientText(
                                                        post.description ?? '',
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                        shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                        gradient: Gradients.haze,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 11
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: post.description != null && post.description != '' ? 12 : 0,),
                                                  Container(
                                                    // width: MediaQuery.of(context).size.width * .3,
                                                    child: Marquee(
                                                      child: Text(
                                                        // post.created_at!,
                                                        DateFormat.yMMMd('it_IT').format(post.created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                                            + ' alle ' + post.created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.grey[200],
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 11
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                  // item.is_single_event && item.single_event.begin_at != null
                                                  //     ? GradientText(
                                                  //   DateFormat.MMMMd('it_IT').format(item.single_event.begin_at),
                                                  //   maxLines: 2,
                                                  //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                  //   // gradient: Gradients.backToFuture,
                                                  //   gradient: Gradients.blush,
                                                  //   // gradient: LinearGradient(
                                                  //   //     begin: Alignment.bottomLeft,
                                                  //   //     end: Alignment.topRight,
                                                  //   //     colors: [
                                                  //   //       Color(0xff8921aa),
                                                  //   //       Color(0xffDA44bb),
                                                  //   //       // Color(0xffDA44bb)
                                                  //   //     ]
                                                  //   // ),
                                                  //   // gradient: LinearGradient(
                                                  //   //     begin: Alignment.bottomLeft,
                                                  //   //     end: Alignment.topRight,
                                                  //   //     colors: [
                                                  //   //       Color(0xff8921aa),
                                                  //   //       Color(0xffDA44bb),
                                                  //   //       // Color(0xffDA44bb)
                                                  //   //     ]
                                                  //   // ),
                                                  //
                                                  //   style: TextStyle(
                                                  //       color: Colors.blue,
                                                  //       fontWeight: FontWeight.w800,
                                                  //       fontSize: 16
                                                  //   ),
                                                  //   textAlign: TextAlign.left,
                                                  // )
                                                  //     : SizedBox(height: 0, width: 0,),
                                                  // SizedBox(height: 1,),
                                                  // GradientText(
                                                  //   // item.is_single_event && item.single_event.title != null
                                                  //   //     ? item.single_event.title
                                                  //   //     : item.prestazione.title != null
                                                  //   //     ? item.prestazione.title : '',
                                                  //   item.is_single_event
                                                  //       ? 'A partire da € 15,00'/* + NumberFormat.currency(
                                                  //                         // customPattern: '#,##',
                                                  //                           decimalDigits: 2,
                                                  //                           symbol: '',
                                                  //                           locale: 'IT_it'
                                                  //                       ).format(item.single_event.)*/
                                                  //       : 'Al prezzo di € ' + NumberFormat.currency(
                                                  //     // customPattern: '#,##',
                                                  //       decimalDigits: 2,
                                                  //       symbol: '',
                                                  //       locale: 'IT_it'
                                                  //   ).format(item.prestazione.price),
                                                  //   maxLines: 2,
                                                  //
                                                  //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                                  //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                                  //   // gradient: Gradients.backToFuture,
                                                  //   gradient: !item.is_single_event
                                                  //       ? Gradients.blush
                                                  //       : LinearGradient(
                                                  //       begin: Alignment.bottomLeft,
                                                  //       end: Alignment.topRight,
                                                  //       colors: [
                                                  //         Color(0xff8921aa),
                                                  //         Color(0xffDA44bb),
                                                  //         // Color(0xffDA44bb)
                                                  //       ]
                                                  //   ),
                                                  //   style: TextStyle(
                                                  //       color: Colors.blue,
                                                  //       fontWeight: FontWeight.w800,
                                                  //       fontSize: 15
                                                  //   ),
                                                  //   textAlign: TextAlign.left,
                                                  // ),
                                                  // Text(
                                                  //   'A partire da € 60,00',
                                                  //   style: new TextStyle(
                                                  //       fontWeight: FontWeight.w800,
                                                  //       fontSize: 15,
                                                  //
                                                  //       foreground: Paint()..shader = LinearGradient(
                                                  //         colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
                                                  //       ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))),
                                                  // )
                                                  // LinearGradient(
                                                  //   begin: Alignment.topLeft,
                                                  //   end: Alignment.bottomRight,
                                                  //   colors: gradientColors,
                                                  // ).createShader(
                                                  //     Rect.fromCircle(
                                                  //       center: Offset(fontSize, -200),
                                                  //       radius: fontSize / 3,
                                                  //     )
                                                  // );
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Positioned(
                                        //   bottom: 15,
                                        //   left: 15,
                                        //   width: MediaQuery.of(context).size.width * 0.4,
                                        //   child: Column(
                                        //     crossAxisAlignment: CrossAxisAlignment.start,
                                        //     children: [
                                        //       // GradientText(
                                        //       //   // eventTicketList[i]!.business!.name!,
                                        //       //   // userPostList[i].booking!.prestazione!.title!,
                                        //       //   // "${userPostList[i].booking!.prestazione!.duration} min",
                                        //       //   // "@${userPostList[i].booking!.user!.username}",
                                        //       //   "@${userPostList[i].user!.username}",
                                        //       //   // '€ ' + NumberFormat.currency(
                                        //       //   //     decimalDigits: 2,
                                        //       //   //     symbol: '',
                                        //       //   //     locale: 'IT_it'
                                        //       //   // ).format(userPostList[i].booking!.prestazione!.price),
                                        //       //   overflow: TextOverflow.ellipsis,
                                        //       //   maxLines: 1,
                                        //       //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                        //       //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                        //       //   gradient: LinearGradient(
                                        //       //       begin: Alignment.bottomLeft,
                                        //       //       end: Alignment.topRight,
                                        //       //       colors: [
                                        //       //         // Color(0xff8921aa),
                                        //       //         // Color(0xffDA44bb),
                                        //       //
                                        //       //         Color(0xffFFA818),
                                        //       //         Color(0xffFFB75E),
                                        //       //       ]
                                        //       //   ),
                                        //       //   // gradient: LinearGradient(
                                        //       //   //     begin: Alignment.bottomLeft,
                                        //       //   //     end: Alignment.topRight,
                                        //       //   //     colors: [
                                        //       //   //       Colors.blue[500],
                                        //       //   //       Color(0xffDA44bb),
                                        //       //   //
                                        //       //   //       Color(0xff8921aa),
                                        //       //   //     ]
                                        //       //   // ),
                                        //       //   style: TextStyle(
                                        //       //       color: Colors.blue[500],
                                        //       //       fontWeight: FontWeight.w700,
                                        //       //       // fontSize: 13
                                        //       //       fontSize: 12
                                        //       //   ),
                                        //       //   textAlign: TextAlign.left,
                                        //       // ),
                                        //       // SizedBox(height: 1,),
                                        //       Row(
                                        //         children: [
                                        //           ClipRRect(
                                        //             borderRadius: BorderRadius.circular(4),
                                        //             child: FutureImage(
                                        //               userPostList[i].prestazione!.image != null && userPostList[i].prestazione!.image != ''
                                        //                   ? userPostList[i].prestazione!.image!
                                        //                   : userPostList[i].business!.profile_image!,
                                        //               width: 25,
                                        //               height: 25,
                                        //             ),
                                        //           ),
                                        //           SizedBox(width: 4,),
                                        //           Container(
                                        //             width: MediaQuery.of(context).size.width * .3,
                                        //             child: Marquee(
                                        //               child: GradientText(
                                        //                 // eventTicketList[i]!.title!,
                                        //                 // userPostList[i].booking!.prestazione!.title!,
                                        //                 userPostList[i].prestazione!.title!,
                                        //                 maxLines: 2,
                                        //                 overflow: TextOverflow.ellipsis,
                                        //                 shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                        //                 gradient: Gradients.haze,
                                        //                 style: TextStyle(
                                        //                     color: Colors.white,
                                        //                     fontWeight: FontWeight.w700,
                                        //                     fontSize: 15
                                        //                 ),
                                        //                 textAlign: TextAlign.left,
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       // SizedBox(height: 5),
                                        //       // Container(
                                        //       //   width: MediaQuery.of(context).size.width * .25,
                                        //       //   child: /*Gradient*/Text(
                                        //       //     // eventTicketList[i]!.title!,
                                        //       //     userPostList[i].description! ?? '',
                                        //       //     maxLines: 3,
                                        //       //     overflow: TextOverflow.ellipsis,
                                        //       //     // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                        //       //     // gradient: Gradients.haze,
                                        //       //     style: TextStyle(
                                        //       //         color: Colors.grey[200],
                                        //       //         fontWeight: FontWeight.w700,
                                        //       //         fontSize: 12
                                        //       //     ),
                                        //       //     textAlign: TextAlign.left,
                                        //       //   ),
                                        //       // ),
                                        //       SizedBox(height: 10),
                                        //       Container(
                                        //         width: MediaQuery.of(context).size.width * .4,
                                        //         child: /*Gradient*/Text(
                                        //           // eventTicketList[i]!.title!,
                                        //           userPostList[i].description! ?? '',
                                        //           maxLines: 3,
                                        //           overflow: TextOverflow.ellipsis,
                                        //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                        //           // gradient: Gradients.haze,
                                        //           style: TextStyle(
                                        //               color: Colors.grey[200],
                                        //               fontWeight: FontWeight.w700,
                                        //               fontSize: 13
                                        //           ),
                                        //           textAlign: TextAlign.left,
                                        //         ),
                                        //       ),
                                        //       SizedBox(height: userPostList[i].description != null && userPostList[i].description != '' ? 10 : 0),
                                        //       Container(
                                        //         width: MediaQuery.of(context).size.width * .4,
                                        //         child: Marquee(
                                        //           child: Text(
                                        //             // eventTicketList[i]!.title!,
                                        //             // DateFormat.yMMMMd('it_IT').format(userPostList[i].booking!.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                        //             //     + ' alle ' + userPostList[i].booking!.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                        //             DateFormat.yMMMMd('it_IT').format(userPostList[i].created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                        //                 + ' alle ' + userPostList[i].created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                        //             maxLines: 1,
                                        //             overflow: TextOverflow.ellipsis,
                                        //             // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                        //             // gradient: Gradients.haze,
                                        //             style: TextStyle(
                                        //                 color: Colors.grey[300],
                                        //                 fontWeight: FontWeight.w700,
                                        //                 fontSize: 11
                                        //             ),
                                        //             textAlign: TextAlign.left,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),

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
                                // SingleEventReservation singleEventReservation = new SingleEventReservation(
                                //   // id: postProvider.posts[i]['post_id'].toInt(),
                                //   id: postProvider.posts[i]['post_id'],
                                //   description: postProvider.posts[i]['post_description'],
                                //   bookingTime: DateTime.parse(postProvider.posts[i]['post_created_at']),
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
                                            child: businessList[i]!.type_id == 1 ? BookingBusinessProfileScreen(
                                              business: businessList[i],
                                            ) : /*businessList[i]!.type_id == 2 ? EventBusinessProfileScreen(
                                              eventBusiness: businessList[i],
                                            ) :*/ SizedBox()
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
                                                      // Colors.blue[500],
                                                      // Color(0xffDA44bb),
                                                      //
                                                      // Color(0xff8921aa),
                                                      Color(0xffFFA818),
                                                      Color(0xffFFB75E),
                                                    ]
                                                ),
                                                style: TextStyle(
                                                    color: Colors.blue,
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
                                                  // gradient: LinearGradient(colors: [
                                                  //   Color(0xffFFA818),
                                                  //   Color(0xffFFB75E),
                                                  // ]),
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
            return SizedBox();
          }
          // }
          // else {
          //   return Center(child: CircularProgressIndicator());
          // }
        }
      ),
    );
  }
}
