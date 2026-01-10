import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

// import 'package:badges/badges.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/category.dart';
// import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/prestazione.dart';
// import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
// import 'package:nurebo_admin/utils/user_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/comment_card.dart';
// import 'package:nurebo_admin/widgets/comment_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
// import 'package:settings_ui/settings_ui.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;


class PostCommentsScreen extends StatefulWidget {
  // final email;
  // final username;
  // final id;
  // final User user;
  // final User? myUser;
  final Post? post;
  final BusinessPost? businessPost;
  final bool? isSingleEventPost;
  // VideoPlayerController _controller;
  // Future<void> _initializeVideoPlayerFuture;
  // TabController _tabController;
  // ScrollController _scrollController;
  // List postList = [];
  // final int height;
  // final int width;
  // final bool isLikedPost;
  // final bool isFavoritedPost;
  final List<PostComment> postComments;


  const PostCommentsScreen({super.key,this.post, /*this.myUser,*/ this.isSingleEventPost, this.businessPost, required this.postComments});

  @override
  _PostCommentsScreenState createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  TextEditingController commentController = TextEditingController();
  Future cab = Future(() {},), rebb = Future(() {},);
  // List<PostComment> postProvider.postComments = [];
  late PostProvider postProvider;


  // Future getBusinessPostComments() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/post_id");
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${Utils.user!.id}/business/${Utils.business_id}/post/${postId}/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${widget.businessPost!.business!.id}/post/${widget.businessPost!.id}/comment");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   // Map/*<String, String>*/ body = {
  //   //   // 'user_id': userProvider.user.id,
  //   //   'post_id': widget.businessPost!.id,
  //   //   // 'text': commentController.text,
  //   // };
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
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //       }
  //   );
  //
  //   //print("postcomment getall response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     //   comments = jsonData;
  //     postProvider.postComments.clear();
  //
  //     for(var e in jsonData){
  //       // print('ef5g6bb6b6666');
  //       // print(e);
  //       PostComment postcomment = PostComment(
  //         id: e['id'],
  //         text: e['text'],
  //         is_admin: e['is_admin'],
  //         businessPost: BusinessPost(
  //           id: e['post_id'],
  //           description: e['post_description'],
  //           image_url: e['post_image_url'],
  //           // is_admin: e['post_is_admin'],
  //           // is_visible: e['post_is_visible'],
  //           created_at: DateTime.tryParse(e['post_created_at'])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //           business: Business(
  //               id: e['business_id'],
  //               email: e['business_email'],
  //               name: e['business_name'],
  //               longitude: e['business_longitude'],
  //               latitude: e['business_latitude'],
  //               phone_number: e['business_phone_number'],
  //               profile_image: e['business_profile_image'] ?? '',
  //               address: e['business_address'],
  //               description: e['business_description'],
  //               type_id: e['business_type_id'],
  //               room_id: e['business_room_id'],
  //               max_contemporary_appointments: e['max_contemporary_appointments'],
  //               category: Category(
  //                 id: e['category_id'],
  //                 image: e['category_image'],
  //                 name: e['category_name'],
  //               )
  //           ),
  //           user: User(
  //             id: e['user_id'],
  //             email: e['user_email'],
  //             username: e['user_username'],
  //             name: e['user_name'],
  //             profile_image: e['user_profile_image' ?? ''] ?? '',
  //             description: e['user_description'],
  //           ),
  //         ),
  //         user: User(
  //           id: e['user_id'],
  //           email: e['user_email'],
  //           username: e['user_username'],
  //           name: e['user_name'],
  //           profile_image: e['user_profile_image'] ?? '',
  //           description: e['user_description'],
  //         ),
  //         created_at: DateTime.tryParse(e['created_at' ?? ''])!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
  //       );
  //
  //       postProvider.postComments.add(
  //         postcomment
  //       );
  //
  //     }
  //
  //     // print('jsopostProvider.postCommentsg5g5');
  //     // print(postProvider.postComments.length);
  //
  //     return jsonData;
  //   }
  // }

  // Future createBusinessPostComment() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "business_post_comment/create");
  //   // var url = Uri.parse("${Utils.httpServerUrl}user/${widget.myUser!.id}/business/${Utils.business_id}/post/${widget.businessPost!.id}/comment");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${widget.businessPost!.business!.id}/post/${widget.businessPost!.id}/comment");
  //   // var userProvider = Provider.of<UserProvider>(context, listen: false);
  //
  //   Map/*<String, String>*/ body = {
  //     // 'user_id': Utils.user!.id,
  //     'post_id': widget.businessPost!.id,
  //     'text': commentController.text,
  //     // 'text': commentController.text,
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
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'User-Mobile-App',
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
  //       }
  //   );
  //
  //   //print("postcomment create response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // //print(jsonData.toString());
  //     // //print(jsonData);
  //     // commentController.clear();
  //     // commentController.text = '';
  //
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // postProvider.postComments.addAll(widget.postProvider.postComments);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    print("widget.businessPost!.id998989");
    print(widget.businessPost!.id);

    // if(widget.businessPost != null){
    //   cab = postProvider.getAllBusinessPostComments(widget.businessPost!);
    // }
    // else{
    //   if(widget.isSingleEventPost!) {
    //     postProvider.getAllSingleEventPostComments(widget.post!.id!);
    //   } else {
    //     postProvider.getAllBookingPostComments(widget.post!.id!);
    //   }
    //   // getAllPostComments();
    // }

  }

  @override
  Widget build(BuildContext context) {
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        // backgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.blue[500],
          // size: 36,
        ),
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
            size: 16,
            // size: 20,
            color: Colors.grey[500],
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        // foregroundColor: Colors.blue,
        // title: Text(
        //   widget.businessPost != null
        //     ? widget.businessPost!.title!
        //     : widget.post!.title ?? '',
        //   style: TextStyle(
        //     color: Colors.blue
        //   ),
        // ),
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            shrinkWrap: true,
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Row(
              //   children: [
              //     Text(
              //       'Descrizione',
              //       style: TextStyle(
              //           color: Colors.blue,
              //           fontWeight: FontWeight.w600
              //       ),
              //     ),
              //     SizedBox(
              //       width: 15,
              //     ),
              //     CupertinoTextField(
              //       // suffix: Icon(
              //       //     Icons.keyboard_arrow_right
              //       // ),
              //       obscureText: false,
              //       controller: commentController,
              //       clearButtonMode: commentController.text != ''
              //           ? OverlayVisibilityMode.always
              //           : OverlayVisibilityMode.never,
              //       enabled: true,
              //
              //       decoration: BoxDecoration(color: Colors.white),
              //       textAlign: /*row.textAlign ??*/ TextAlign.left,
              //       placeholder: /*row.placeholder ??*/ "Inserire la descrizione dell'evento",
              //       placeholderStyle: TextStyle(
              //           fontSize: 15,
              //           color: CupertinoColors.placeholderText
              //       ),
              //       keyboardType: TextInputType.text,
              //       minLines: 1,
              //       maxLines: 8,
              //       // expands: true,
              //       style: TextStyle(
              //         fontSize: 15,
              //         color: Colors.grey[700],
              //       ),
              //       readOnly: false,
              //       onChanged: (value) {
              //         // if(_descriptionController.text == ''){
              //         //   setState(() {
              //         //     editableDescription = false;
              //         //   });
              //         // }
              //         // else{
              //         //   setState(() {
              //         //     editableDescription = true;
              //         //   });
              //         // }
              //       },
              //     ),
              //   ],
              // ),

              Column(
                children: [
                  // Divider(
                  //   color: Colors.grey[400],
                  //   height: 1,
                  //   // endIndent: 20,
                  //   // indent: 20,
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 5,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        margin: EdgeInsets.all(0),
                        // height: 58.0,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Text(
                              'Commento',
                              style: TextStyle(
                                // color: Colors.blue,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: CupertinoTextField(
                                // suffix: Icon(
                                //     Icons.keyboard_arrow_right
                                // ),
                                obscureText: false,
                                controller: commentController,
                                clearButtonMode: commentController.text != ''
                                    ? OverlayVisibilityMode.always
                                    : OverlayVisibilityMode.never,
                                enabled: true,
                                decoration: BoxDecoration(color: Colors.white),
                                textAlign: /*row.textAlign ??*/ TextAlign.left,
                                placeholder: /*row.placeholder ??*/ "Scrivere il commento",
                                placeholderStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: CupertinoColors.placeholderText
                                ),
                                keyboardType: TextInputType.text,
                                minLines: 1,
                                maxLines: 8,
                                // expands: true,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                readOnly: false,
                                onChanged: (value) {
                                  // if(commentController.text == ''){
                                  //   setState(() {
                                  //     editableDescription = false;
                                  //   });
                                  // }
                                  // else{
                                  //   setState(() {
                                  //     editableDescription = true;
                                  //   });
                                  // }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Divider(
                  //   color: Colors.grey[400],
                  //   height: 1,
                  //   // endIndent: 20,
                  //   // indent: 20,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          // left: MediaQuery.of(context).size.width * 0.4,
                          // right: MediaQuery.of(context).size.width * 0.4,
                            right: 15,
                            left: 15,
                            top: 0,
                            bottom: 10
                        ),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.blue),
                              // fixedSize: MaterialStateProperty.all(Size.fromWidth(40)),
                              // minimumSize: MaterialStateProperty.all(Size.fromHeight(30)),

                              // maximumSize: MaterialStateProperty.all(Size.fromHeight(30)),
                              // padding: MaterialStateProperty.all(
                              //     EdgeInsets.only(
                              //         left: 40,
                              //         right: 40
                              //  )
                              // ),
                            ),
                            onPressed: () async {
                              // if(UserPreferences.getIsLogged()!){
                                if(widget.businessPost != null && commentController.text.isNotEmpty) {
                                  await postProvider.createBusinessPostComment(widget.businessPost!, commentController.text);
                                  setState(() {
                                    /*cab =*/ postProvider.getBusinessPostComments(widget.businessPost!);
                                  });
                                  // postProvider.getAllSubscribedBusinessPostComments(widget.myUser.id.toString());
                                  // print(widget.businessPost!.id);

                                }
                                // else{
                                  // if(widget.isSingleEventPost) {
                                  //   await createSingleEventPostComment();
                                  //   setState(() {
                                  //     getAllSingleEventPostComments();
                                  //   });
                                  // } else{
                                  // if(widget.post != null){
                                  //   await createBookingPostComment();
                                  //   setState(() async {
                                  //     await getAllBookingPostComments();
                                  //   });
                                  // }
                                // }
                              // }
                              //   }
                              // }

                              // createPostComment();
                              // setState(() {
                              //   getAllPostComments();
                              // });
                              commentController.clear();
                            },
                            child: Text(
                              'Invia',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700
                              ),
                            )
                          // child: Icon(
                          //   Icons.add,
                          //   color: Colors.blue,
                          // ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 10, left: 15),
                child: Text(
                  // 'Commenti: ${postProvider.comments!.length}',
                  'Commenti: ${postProvider.postComments.length}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      // color: Colors.white
                      color: Colors.grey[700]
                    // color: Colors.blue[500]
                  ),
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                // itemCount: postProvider.comments!.length,
                itemCount: postProvider.postComments.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  //TODO: DISCERNERE TRA SINGLE EVENT POST COMMENT E DATE COMMENT

                  PostComment postComment = PostComment(
                    id: postProvider.postComments[i].id,
                    created_at: postProvider.postComments[i].created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                    text: postProvider.postComments[i].text,
                    is_admin: postProvider.postComments[i].is_admin,
                    businessPost: widget.businessPost,
                    user: User(
                      id: postProvider.postComments[i].user!.id,
                      description: postProvider.postComments[i].user!.description,
                      profile_image: postProvider.postComments[i].user!.profile_image,
                      name: postProvider.postComments[i].user!.name,
                      username: postProvider.postComments[i].user!.username,
                      email: postProvider.postComments[i].user!.email,
                    ),
                  );

                  // print('postComment.is_admin.toString()');
                  // print(postComment.is_admin.toString());
                  // print(postComment.id.toString());

                  // return partecipationNotification(context, i);
                  return CommentCard(
                    comment: postComment,
                  );
                  // return Column(
                  //   children: [
                  //     Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Row(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               shape: BoxShape.circle,
                  //               // backgroundBlendMode: ,
                  //               boxShadow: [
                  //                 BoxShadow(blurRadius: 0, color: Colors.black, spreadRadius: 1)
                  //               ],
                  //             ),
                  //             child: CircleAvatar(
                  //               radius: 20,
                  //               backgroundImage: CachedNetworkImageProvider(
                  //                   postProvider.comments[i]['profile_image'],
                  //                 // 'https://images.pexels.com/photos/2346754/pexels-photo-2346754.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
                  //               ),
                  //             ),
                  //           ),
                  //           Text(
                  //             postProvider.comments[i]['text'],
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Divider(
                  //       height: 0,
                  //       thickness: 2,
                  //       endIndent: 15,
                  //       indent: 15,
                  //     ),
                  //   ],
                  // );
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          )
        ),
      ),
    );
  }

  getImageWidthHeight(String imageUrl) async {
    File image = File(imageUrl); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    //print(decodedImage.width);
    //print(decodedImage.height);
  }

  Widget partecipationNotification(context, i) {
    return Container(
      color: Colors.grey[100],
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
            // child: Container(
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: NetworkImage(convs[i].profilePicture),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            // child: CircleAvatar(
            //   radius: 30,
            //   backgroundImage: NetworkImage(
            //     convs[i].profilePicture
            //   )
            // ),
            // child: Container(
            //   width: 70,
            //   height: 50,
            //   child: ImageCard(
            //     imageData: imageList[i],
            //   ),
            // ),
            child: Container(
              width: 55,
              height: 55,
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.network(
                  // postProvider.comments![i]['profile_image'],
                  postProvider.postComments[i].user!.profile_image,
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 10,
                //margin: EdgeInsets.all(10),
              ),
            ),
          ),
          Expanded(
            //alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      // postProvider.comments![i]['username'],
                      postProvider.postComments[i].user!.username!,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18.0,
                          // color: Colors.white
                          color: Colors.grey[700]
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, right: 17),
                    child: Text(
                      // postProvider.comments![i]['text'],
                      postProvider.postComments[i].text!,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                          // color: Colors.white
                          color: Colors.black
                      ),
                    ),
                  ),
                  // SizedBox(height: 4),
                  // Row(
                  //   children: [
                  //     Container(
                  //       child: Expanded(
                  //         child: RichText(
                  //           text: TextSpan(
                  //             // Note: Styles for TextSpans must be explicitly defined.
                  //             // Child text spans will inherit styles from parent
                  //             style: TextStyle(
                  //                 fontSize: 14.0,
                  //                 color: Colors.black
                  //               // color: Colors.white,
                  //             ),
                  //             children: <TextSpan>[
                  //               TextSpan(text: "Parteciperà all'evento "),
                  //               TextSpan(text: events[i].title,
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.w800
                  //                 ),
                  //               ),
                  //               TextSpan(text: " il " + events[i].data + " alle ore " +
                  //                   events[i].hour
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         // child: Text(
                  //         //   //"Feed me right now or else ... ",
                  //         //   "Parteciperà all'evento " + notifications[i].title +
                  //         //       " il " + notifications[i].date + " alle ore " +
                  //         //       notifications[i].hour + " al " + notifications[i].place
                  //         //   /*+ " organizzato da " + notifications[i].eventOrganizer*/,
                  //         //   maxLines: 2,
                  //         //   overflow: TextOverflow.ellipsis,
                  //         //   // softWrap: true,
                  //         //   style: TextStyle(
                  //         //     color: Colors.grey[600],
                  //         //   ),
                  //         // ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Column(
                  //   // mainAxisAlignment: MainAxisAlignment.end,
                  //   // crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.only(top: 5),
                  //       child: Text(
                  //         "Rimangono solo " + notifications[i].availablePlaces.toString() + " posti disponibili",
                  //         style: TextStyle(
                  //             color: Colors.blue[300],
                  //             fontWeight: FontWeight.w700
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //       vertical: 10.0, horizontal: 0.0),
                  //   child: LinearPercentIndicator(
                  //     padding: EdgeInsets.only(left: 4),
                  //     // alignment: MainAxisAlignment.center,
                  //     width: 210.0,
                  //     lineHeight: 5.0,
                  //     percent: notifications[i].availablePlaces/60,
                  //     progressColor: Colors.blue[300],
                  //     // backgroundColor: CupertinoColors.black,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(right: 15),
          //   // mainAxisAlignment: MainAxisAlignment.center,
          //   child:
          //     Text(
          //         "5:35 pm"
          //     )
          // ),
          // Padding(
          //   padding: EdgeInsets.only(right: 15, left: 20, ),
          //   child: Container(
          //     width: 12,
          //     height: 12,
          //     decoration: BoxDecoration(
          //       color: Colors.blue[300],
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          // Divider(height: 5, thickness: 5,),
        ],
      ),
    );
  }
}

