import 'dart:convert';
import 'dart:math';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/models/post_like.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/screens/post_full_screen.dart';
import 'package:nurebo_admin/screens/post_edit_screen.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class PostListScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  // final User? user;

  PostListScreen({Key? key,/* this.user*/});

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  // List myPrestazione = [];
  // var results;
  late PostProvider postProvider;
  late BusinessProvider businessProvider;
  Future a = Future((){}), all = Future((){});


  // Future getUserPrestazioneLiked() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
  //
  //   Map<String, dynamic> body = {
  //     // 'user_id': widget.user.id,
  //     'user_id': userProvider.user.id,
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
  //   //print("ticketUsers response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       myPrestazione = jsonData;
  //       // results.addAll(jsonData);
  //       // results.shuffle();
  //     });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     //print(jsonData);
  //     return jsonData;
  //   }
  // }

  Future callFutureBuilderMethods() async {
    await Future.wait([
      a = postProvider.getAllBusinessPost(businessProvider.business!.id, context),
      postProvider.getAllBusinessPostComments(businessProvider.business!),
      postProvider.getAllBusinessPostLikes(businessProvider.business!),
    ]);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

    // Future.wait([
      all = callFutureBuilderMethods()/*,
    ])*/;

    // getUserPrestazioneLiked();
    // print('g5f45fhhddh');
    // print(postProvider.postList.length);
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Container(
      //   margin: EdgeInsets.only(bottom: 10),
      //   width: MediaQuery.of(context).size.width * 0.9,
      //   height: 50,
      //   child: ElevatedButton(
      //     style: ButtonStyle(
      //         backgroundColor: MaterialStateProperty.all(Colors.blue[500])
      //     ),
      //     child: Text(
      //       "Aggiungi",
      //       // "Avvia campagna",
      //       // 'Continua',
      //       style: TextStyle(
      //           fontSize: 16,
      //           fontWeight: FontWeight.w700
      //       ),
      //     ),
      //     onPressed: () async {
      //       Navigator.push(
      //           context,
      //           PageTransition(
      //             duration: const Duration(milliseconds: 500),
      //             alignment: Alignment.center,
      //             type: PageTransitionType.fade,
      //             // child: NotificationScreen(),
      //             child: PostEditScreen(
      //               // post: Post(
      //               post: BusinessPost(
      //                 // title: '',
      //                 description: '',
      //               ),
      //               isNewPost: true,
      //             ),
      //           )
      //       );
      //     },
      //   ),
      // ),
      appBar: AppBar(
        titleSpacing: 0,
        // leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
            // size: 22,
            size: 16,
            color: Colors.grey[500],
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          // 'Salvati',
          'Post',
          // 'Le mie prestazioni',
          style: TextStyle(
              // color: Colors.blue[500],
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                // ticketCategoryProvider.deleteAll();
                Navigator.push(
                  context,
                  PageTransition(
                    duration: const Duration(milliseconds: 500),
                    alignment: Alignment.center,
                    type: PageTransitionType.fade,
                    // child: NotificationScreen(),
                    child: PostEditScreen(
                      // post: Post(
                      post: BusinessPost(
                        // title: '',
                        description: '',
                        likes: [],
                        comments: [],
                      ),
                      isNewPost: true,
                    ),
                  )
                );
              },
              // child: Text(
              //   'Aggiungi',
              //   style: TextStyle(
              //       color: Colors.blue
              //   ),
              // )
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder/*<Object>*/(
        // future: Future.wait([all]),
        future: all,
        builder: (context, snapshot) {
          // if(snapshot.connectionState == ConnectionState.done){
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: ListView(
                // physics: BouncingScrollPhysics(),
                children: [
                  StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                          top: 5,
                          left: 10,
                          right: 10,
                          bottom: 10
                      ),
                      crossAxisCount: 2,
                      staggeredTileBuilder: (i) => StaggeredTile.count(1, 2),
                      //shrinkWrap: true,
                      mainAxisSpacing: 0,
                      // physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 0,
                      itemCount: postProvider.postList.length,
                      itemBuilder: (context, i) {
                        // //print('favoriteProvider.myFavoritesList');
                        // for(var e in postProvider.postList){
                        // //print(e);
                        // }
                        // //print('favoriteProvider.myFavoritesList.length');
                        // //print(favoriteProvider.favoritesList.length);

                        // Post post = postProvider.postList[i];
                        BusinessPost post = postProvider.postList[i];
                        // Post post = Post(
                        // id: postProvider.postList[i]['prestazione_id'],
                        // duration: favoriteProvider.favoritesList[i]['prestazione_duration'],
                        // isValid: favoriteProvider.favoritesList[i]['is_valid'],
                        // image: favoriteProvider.favoritesList[i]['prestazione_image'],
                        // price: favoriteProvider.favoritesList[i]['prestazione_price'].toDouble(),
                        // title: postProvider.postList[i]['prestazione_title'],
                        // description: postProvider.postList[i]['prestazione_description'] ?? '',
                        // created_at: DateTime.tryParse(postProvider.postList[i]['created_at']),

                        // business_id: favoriteProvider.myFavoritesList[i]['business_id'],

                        // business: Business(
                        //     profile_image: favoriteProvider.favoritesList[i]e['business_profile_image'] ?? '',
                        //     id: favoriteProvider.favoritesList[i]['business_id'],
                        //     type_id: 1,
                        //     longitude: favoriteProvider.favoritesList[i]['business_longitude'],
                        //     latitude: favoriteProvider.favoritesList[i]['business_latitude'],
                        //     name: favoriteProvider.favoritesList[i]['business_name'],
                        //     email: favoriteProvider.favoritesList[i]['business_email'],
                        //     description: favoriteProvider.favoritesList[i]['business_description'],
                        //     address: favoriteProvider.favoritesList[i]['business_address'],
                        //     room_id: favoriteProvider.favoritesList[i]['business_room_id'],
                        //     phone_number: favoriteProvider.favoritesList[i]['business_phone_number'],
                        //     max_contemporary_appointments: favoriteProvider.favoritesList[i]['max_contemporary_appointments'],
                        //     category: Category(
                        //       id: favoriteProvider.favoritesList[i]['category_id'],
                        //       image: favoriteProvider.favoritesList[i]['category_image'],
                        //       name: favoriteProvider.favoritesList[i]['category_name'],
                        //     )
                        // ),
                        // );


                        int postLikesCount = 0;
                        for(PostLike e in postProvider.businessProfilePostLikes){
                          // print(userPostList[i].id);
                          // print(e.businessPost!.id);
                          if(post.id == e.businessPost!.id){
                            postLikesCount++;
                          }
                        }

                        int postCommentsCount = 0;
                        for(PostComment e in postProvider.businessProfilePostComments){
                          // print(userPostList[i].id);
                          // print(e.businessPost!.id);
                          if(post.id == e.businessPost!.id){
                            postCommentsCount++;
                          }
                        }

                        return InkWell(
                          onTap: (){
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  // child: PostCreateScreen(
                                  //   post: post,
                                  //   isNewPost: false,
                                  // ),
                                  child: PostFullScreen(
                                    businessPost: post,
                                  ),
                                )
                            );
                          },
                          child: Hero(
                            // tag: i,
                            tag: post.image_url != null && post.image_url != '' ? post : post.business!,
                            child: Card(
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
                                    post.image_url != null && post.image_url != '' ? post.image_url! : post.business!.profile_image!,
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
                                                    child: post.user!.profile_image != '' ? FutureImage(
                                                      post.user!.profile_image ?? '',
                                                      // post.booking!.user.profile_image ?? '',
                                                      width: 25,
                                                      height: 25,
                                                    ) : Icon(
                                                      Icons.account_circle_rounded,
                                                      color: Colors.grey[300],
                                                      size: 30,
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
                                                        : businessProvider.business!.profile_image!,
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
                                                             /* isLiked ? Icons.favorite_outlined :*/ Icons.favorite_border_outlined,
                                                              color: /*isLiked ? Colors.red :*/ Colors.grey[50],
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
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    // ImageCard(
                    //   imageData: imageList[index],
                    // ),
                  ),
                  SizedBox(height: 0,)
                ],
              ),
            );
          // }
          // else {
          //   return SizedBox();
          // }

        }
      ),

    );
  }
}
