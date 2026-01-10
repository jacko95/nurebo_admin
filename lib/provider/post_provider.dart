import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/booking_post.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/post_like.dart';
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

class PostProvider extends ChangeNotifier {
  // List<Post> postList = [];
  List<BusinessPost> postList = [];
  List<User> userOrderList = [];
  static final ImageCacheBusiness cacheBusiness = ImageCacheBusiness();
  // List<BookingPost> postList = [];
  List<PostComment> postComments = [];
  List<PostLike> postLikes = [];
  // List businessPostLikes = [];
  // List businessPostComments = [];
  // bool isLikedPost = false;
  // List? comments = [];
  List<PostLike> userProfilePostLikes = [];
  List<PostComment> userProfilePostComments = [];
  List<PostLike> businessProfilePostLikes = [];
  List<PostComment> businessProfilePostComments = [];
  List<User> businessProfileUsersList = [];


  Future getAllBusinessClients(Business business) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${Utils.business_id}/post");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business.id}/booking/user");

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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   categoryList.addAll(jsonData);
      // });

      // postList = jsonData;
      // postList.addAll(jsonData);

      businessProfileUsersList.clear();
      for(var e in jsonData){
        businessProfileUsersList.add(
            User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              profile_image: e['user_profile_image'] ?? '',
              description: e['user_description'],
            )
        );
      }

      // print('postList555663');
      // print(postList);
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future getAllBusinessPostComments(Business business) async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/post/comment");

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

      /*postProvider.*/businessProfilePostComments.clear();

      for(var e in jsonData) {
        for (BusinessPost post in /*postProvider.businessProfilePostList*//*businessPostList*/postList) {
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
            /*postProvider.*/businessProfilePostComments.add(postComment);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  Future getAllBusinessPostLikes(Business business) async {
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.user!.id}/business/post/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}business/post/user/${widget.user!.id}/like");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/post/like");

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

      print('f9f89f9f8gh8h8h8h8n');
      print(jsonData.length);

      /*postProvider.*/businessProfilePostLikes.clear();
      for(var e in jsonData) {
        for (BusinessPost post in /*postProvider.businessProfilePostList*//*businessPostList*/postList) {
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
            /*postProvider.*/businessProfilePostLikes.add(postlike);
          }
        }
      }

      return jsonData;
    }
    return;
  }

  void deleteAll(){
    postList.clear();
    notifyListeners();
  }

  Future getAllBookingPostComments(String postId) async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_comment/post_id");
    // var url = Uri.parse("${Utils.httpServerUrl}booking/post/${widget.post!.id}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}booking/post/${postId}/comment");
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
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // comments = jsonData;
      postComments.clear();
      for(var e in jsonData){
        // print('ef5g6bb6b6666');
        // print(e);
        PostComment postcomment = PostComment(
          id: e['id'],
          text: e['text'],
          is_admin: e['is_admin'],
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            likes: [],
            comments: [],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
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
              profile_image: e['user_profile_image' ?? ''] ?? '',
              description: e['user_description'],
            ),
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

        postComments.add(
            postcomment
        );

      }
      // });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  Future getAllSingleEventPostComments(String postId) async {
    var url = Uri.parse(Utils.httpServerUrl + "single_event_post_comment/post_id");
    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      // 'post_id': widget.post!.id,
      'post_id': postId,
      // 'text': commentController.text,
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
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print("postcomment getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // comments = jsonData;
      postComments.clear();
      for(var e in jsonData){
        // print('ef5g6bb6b6666');
        // print(e);
        PostComment postcomment = PostComment(
          id: e['id'],
          text: e['text'],
          is_admin: e['is_admin'],
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            likes: [],
            comments: [],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
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
              profile_image: e['user_profile_image' ?? ''] ?? '',
              description: e['user_description'],
            ),
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

        postComments.add(
            postcomment
        );

      }
      // });
      // //print("singleEventReservationCategories: ");
      // //print(singleEventReservationCategories);
      // //print('searchUserByUsername results.toString()');
      // //print(results.toString());
      // //print(jsonData);

      notifyListeners();
      return jsonData;
    }
  }

  Future createBusinessPostComment(BusinessPost businessPost, String text) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/create");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessPost.business!.id}/post/${businessPost.id}/comment");
    // var userProvider = Provider.of<UserProvider>(context, listen: false);

    Map/*<String, String>*/ body = {
      // 'user_id': Utils.user!.id,
      'post_id': businessPost.id,
      'text': text,
      // 'text': commentController.text,
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
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    //print("postcomment create response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // //print(jsonData.toString());
      // //print(jsonData);
      // commentController.clear();
      // commentController.text = '';

      notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessPostComments(BusinessPost businessPost) async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/post_id");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
    // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${Utils.business_id}/post/${postId}/comment");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessPost.business!.id}/post/${businessPost!.id}/comment");
    // var userProvider = Provider.of<UserProvider>(context);

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

    //print("postcomment getall response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      //   comments = jsonData;
      postComments.clear();
      for(var e in jsonData){
        // print('ef5g6bb6b6666');
        // print(e);
        PostComment postcomment = PostComment(
          id: e['id'],
          text: e['text'],
          is_admin: e['is_admin'],
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            likes: [],
            comments: [],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
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
              profile_image: e['user_profile_image' ?? ''] ?? '',
              description: e['user_description'],
            ),
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

        postComments.add(
            postcomment
        );

        if(/*e.comments.where((element) => element.id == postcomment.id).isEmpty*/
        !(userProfilePostComments.any((element) => element.id == postcomment.id))/*!e1.comments.contains(postcomment)*/) {
          userProfilePostComments.add(postcomment);
        }

        if(/*e.comments.where((element) => element.id == postcomment.id).isEmpty*/
          !(businessProfilePostComments.any((element) => element.id == postcomment.id))/*!e1.comments.contains(postcomment)*/) {
          businessProfilePostComments.add(postcomment);
        }

      }

      // print('jsopostCommentsg5g5');
      // print(postComments.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future getBusinessPostLikes(BusinessPost businessPost) async {
    // businessPostLikes.clear();
    // isLikedPost = false;
    // var url = Uri.parse(Utils.httpServerUrl + "booking_post_like/post_id");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessPost.business!.id}/post/${businessPost.id}/like");
    // var userProvider = Provider.of<UserProvider>(context);

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

    // //print("likessss getall response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // setState(() {
      // /*postLikes*/businessPostLikes.addAll(jsonData);
      // bookingPostLikes = jsonData;
      // });
      postLikes.clear();
      for(var e in jsonData){
        PostLike postlike = PostLike(
          businessPost: BusinessPost(
            id: e['post_id'],
            description: e['post_description'],
            image_url: e['post_image_url'],
            // is_admin: e['post_is_admin'],
            // is_visible: e['post_is_visible'],
            likes: [],
            comments: [],
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

        postLikes.add(
            postlike
        );

      }

      return jsonData;
    }
  }

  Future getAllBusinessPost(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/post/is_visible");

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

      postList.clear();
      // prestazioneList = jsonData;
      for(var e in jsonData){
        postList.add(
          // Post(
          BusinessPost(
            id: e['post_id'],
            image_url: e['post_image_url'],
            // booking: Booking(
            //   id: e['booking_id'],
            //   isCanceled: e['is_canceled'],
            //   // is_guest: 0,
            //   business: businessProvider.business,
            //   // note: myAppointments[index]['note'],
            //   // user_id: myAppointments[index]['user_id'].toString(),
            //   prestazione: Prestazione(
            //     duration: e['prestazione_duration'],
            //     id: e['prestazione_id'],
            //     image: e['prestazione_image'],
            //     price: e['prestazione_price'].toDouble(),
            //     title: e['prestazione_title'],
            //     description: e['prestazione_description'],
            //     // business_id: e['business_id'],
            //     business: businessProvider.business
            //   ),
              // user: User(
              //   id: e['user_id'],
              //   email: e['user_email'],
              //   username: e['user_username'],
              //   name: e['user_name'],
              //   // phone_number: e['user_phone_number'],
              //   profile_image: e['user_profile_image'] ?? '',
              //   // description: appointments[i]['user_description'],
              // ),
            //   begin_at: DateTime.tryParse(e['begin_at'] ?? '')/*.toLocal()*/,
            //   end_at: DateTime.tryParse(e['begin_at'] ?? '')!.add(Duration(minutes: e['prestazione_duration'].toInt()))/*.toLocal()*/,
            //   created_at: DateTime.tryParse(e['created_at'] ?? '')/*.toLocal()*/,
            // ),
            likes: [],
            comments: [],
            user: User(
              id: e['user_id'],
              email: e['user_email'],
              username: e['user_username'],
              name: e['user_name'],
              phone: e['user_phone'],
              profile_image: e['user_profile_image'] ?? '',
              // description: appointments[i]['user_description'],
            ),
            prestazione: Prestazione(
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
            description: e['post_description'],
            created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
            business: businessProvider.business,
            // is_admin: e['post_is_admin'],
            is_visible: e['post_is_visible'],
          )
        );
      }

      // print('postList.length');
      // print(postList.length);

      notifyListeners();
      return jsonData;
    }
  }

  Future deletePost(String? businessId, String? postId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/post/$postId");

    Map/*<String, String>*/ body = {
      'business_id': businessId,
      'post_id': postId,
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

      for(var e in List.from(postList)){
        // if(e['id'] == prestazioneId){
        if(e.id == postId){
          postList.remove(e);
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

  Future<StreamedResponse> updatePost({
    required String businessId,
    required String postId,
    /*required*/ User? user,
    // /*required*/ Booking? booking,
    /*required*/ Prestazione? prestazione,
    // required String title,
    required String description,
    File? uploadImage,
    String? image,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    cacheBusiness.removeImageFromCache('${Utils.httpServerUrl}image?path=${image}');

    var request = http.MultipartRequest(
        'PUT',
        // Uri.parse(Utils.httpServerUrl + "prestazione")
        Uri.parse("${Utils.httpServerUrl}business/$businessId/post/$postId")
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
      'post_id': postId,
      'business_id': businessId,
      'prestazione_id': prestazione!.id ?? '',
      'user_id': user!.id!,
      // 'booking_id': booking!.id!,
      // 'title': title,
      'description': description,
      'image_url': image ?? '',
    }
    ..addAll(businessProvider.business!.toJson().map((key, value) => MapEntry(key, value != null ? value.toString() : '')))
    ..addAll(prestazione.toJson().map((key, value) => MapEntry(key, value != null ? value.toString() : '')));
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

      // cacheBusiness.removeImageFromCache(image!);
      // await cacheBusiness.addImageToCache(jsonData['image_url']);
      // cacheBusiness.getImageFromCache(jsonData['image_url']);

      for(var e in postList){
        if(e.id == postId){
          e.id = jsonData['id'];
          e.image_url = jsonData['image_url'];
          e.description = jsonData['description'];
          e.prestazione = prestazione;
          // e.booking = booking;
          e.user = user;
          // e.created_at = DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/;
          e.created_at = DateTime.tryParse(jsonData['created_at'])/*?.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/;
          // e.is_valid = jsonData['is_valid'];
          // e.previous_prestazione = jsonData['previous_prestazione'];
        }
      }

      // postList.sort((a, b) {
      //   // print('a.toString()');
      //   // print(a.title.toString());
      //   // print('b.toString()');
      //   // print(b.title.toString());
      //   // print('');
      //   return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
      // });

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

  Future createPost({
    required String businessId,
    /*required*/ User? user,
    /*required*/ Prestazione? prestazione,
    // /*required*/ Booking? booking,
    // required String title,
    required String description,
    File? uploadImage,
    required BuildContext context
  }) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    var request = http.MultipartRequest(
        'POST',
        // Uri.parse(Utils.httpServerUrl + "prestazione")
        Uri.parse("${Utils.httpServerUrl}business/$businessId/post")
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
      // 'booking_id': booking!.id!,
      'prestazione_id': prestazione!.id!,
      'user_id': user!.id!,
      // 'title': title,
      'description': description,
      // 'image': image ?? '',
    }
    ..addAll(businessProvider.business!.toJson().map((key, value) => MapEntry(key, value != null ? value.toString() : '')))
    ..addAll(prestazione.toJson().map((key, value) => MapEntry(key, value != null ? value.toString() : '')));
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

      postList.add(
        // Post(
        BusinessPost(
          id: jsonData['id'],
          image_url: jsonData['image_url'],
          description: jsonData['description'],
          created_at: DateTime.now().subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
          user: user,
          likes: [],
          comments: [],
          // booking: booking,
          business: businessProvider.business,
          prestazione: prestazione,
          // is_valid: jsonData['is_valid'].toInt(),
          // previous_prestazione: jsonData['previous_prestazione'],
        )
      );

      postList.sort((b, a) {
        // print('a.toString()');
        // print(a.title.toString());
        // print('b.toString()');
        // print(b.title.toString());
        // print('');
        return a.created_at!.compareTo(b.created_at!);
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
