import 'dart:convert';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/post_like.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/prestazione_detail_screen.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/signed_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:intl/date_symbol_data_local.dart';


class PostLikeListScreen extends StatefulWidget {
  final List<PostLike> postLikes;

  const PostLikeListScreen({super.key, required this.postLikes,});

  @override
  _PostLikeListScreenState createState() => _PostLikeListScreenState();
}

class _PostLikeListScreenState extends State<PostLikeListScreen> {
  late BusinessProvider businessProvider;
  // List prestazioneCategories = [];

  // Future getAllEventCategories(int singleEventId) async {
  //   var url = Uri.parse(Constants.httpServerUrl + "single_event_ticket/single_event");
  //   // var ticketCategoryProvider = Provider.of<TicketProvider>(context/*, listen: false*/);
  //
  //   Map/*<String, String>*/ body = {
  //     'single_event_id': singleEventId,
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
  //     setState(() {
  //       prestazioneCategories = jsonData.toList();
  //     });
  //
  //     print(jsonData);
  //     print(prestazioneCategories);
  //     return jsonData;
  //   }
  // }

  // Future getAllDateBusinessPrestazioni() async {
  //   var url = Uri.parse(Constants.httpServerUrl + "prestazione/booking_business");
  //
  //   Map<String, String> body = {
  //     // 'event_business_id': widget.eventBusiness.id,
  //     'business_id': '11',
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
  //     setState(() {
  //       prestazioneList = jsonData;
  //     });
  //     print(jsonData);
  //     return jsonData;
  //   }
  // }
  //
  // Future deletePrestazione(String prestazioneId) async {
  //   var url = Uri.parse(Constants.httpServerUrl + "event_business/single_event/delete");
  //
  //   Map/*<String, String>*/ body = {
  //     'business_id': '11',
  //     'prestazione_id': prestazioneId,
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
  //     //   eventBusinessEventsList = jsonData;
  //     // });
  //     print(jsonData);
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return RefreshIndicator(
      edgeOffset: 60,
      // strokeWidth: 5,
      // displacement: 200,
      // triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        // prestazioneProvider.deleteAll();
        // await prestazioneProvider.getAllBusinessPrestazioni(businessProvider.business!.id, context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue[500], //change your color here
          ),
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
          centerTitle: true,
          elevation: 0,
          // foregroundColor: Colors.blue,
          backgroundColor: Colors.white,
          // centerTitle: true,
          title: Text(
            'Like',
            style: TextStyle(
                color: Colors.blue[500],
                // color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                fontSize: 16
            ),
          ),
          actions: [
          ],
        ),
        body: SafeArea(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView(
              // shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: [
                ListView.separated(
                    padding: EdgeInsets.only(top: 0, bottom: 10),
                    separatorBuilder: (context, index) => Divider(
                      // color: Colors.black,
                      height: 10,
                      thickness: 1,
                      indent: 15,
                      endIndent: 15,
                    ),
                    shrinkWrap: true,
                    // physics: ClampingScrollPhysics(),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.postLikes.length,
                    itemBuilder: (context, i){
                      return InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () async {

                          Navigator.push(
                            context,
                            PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              child: UserProfileScreen(
                                userId: widget.postLikes[i].user!.id!
                              )
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: 20,
                            right: 15
                          ),
                          child: Row(
                            children: [
                              // prestazioneProvider.prestazioneList[i]['image'] == '' || prestazioneProvider.prestazioneList[i]['image'] == null ? ClipRRect(
                              ClipRRect(
                                // borderRadius: BorderRadius.circular(40),
                                // borderRadius: BorderRadius.circular(4),
                                borderRadius: BorderRadius.circular(50),
                                // child: Image.asset(
                                // child: Image.network(
                                //   businessProvider.business.profile_image,
                                //   // height: 38,
                                //   height: 45,
                                //   // width: 38,
                                //   width: 45,
                                //   fit: BoxFit.cover,
                                // ),
                                child: widget.postLikes[i].user!.profile_image != '' ? FutureImage(
                                  widget.postLikes[i].user!.profile_image,
                                  // colorBlendMode: BlendMode.darken,
                                  // colorBlendMode: BlendMode.hardLight,
                                  width: 45,
                                  height: 45,
                                  // filterQuality: FilterQuality.high,
                                  // placeholder: (context, url) => Center(
                                  //     child: CircularProgressIndicator()
                                  // ),
                                ) : Icon(
                                  Icons.account_circle_rounded,
                                  color: Colors.grey[300],
                                  size: 45,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Marquee(
                                        child: GradientText(
                                          widget.postLikes[i].user!.name ?? '',
                                          gradient: LinearGradient(
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight,
                                              colors: [
                                                // Color(0xff8921aa),
                                                // Color(0xffDA44bb)
                                                // Colors.blue[700]!,
                                                Colors.red[400]!,
                                                Colors.red[600]!,
                                              ]
                                          ),
                                          style: TextStyle(
                                            //   color: Colors.black,
                                              color: Colors.green[600],
                                              fontWeight: FontWeight.w600,
                                            fontSize: 15
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1,),
                                      Text(
                                        // discussionData[index].booking,
                                        // timeAgo.format(
                                        //     DateTime.tryParse(bookingList[index]['created_at']),
                                        //     locale: 'it'
                                        // ),
                                        // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                                        //   + ' alle ' +
                                        //   bookingList[index]['created_at'].toString().substring(11, 16),
                                        "@${widget.postLikes[i].user!.username}",
                                        style: TextStyle(
                                            // color: Colors.black.withOpacity(0.8),
                                            color: Colors.grey[800],
                                            // color: Colors.blue[600],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      SizedBox(height: 1,),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                timeAgo.format(
                                  widget.postLikes[i].created_at!,
                                  locale: 'it'
                                ),
                                style: TextStyle(
                                  // color: Colors.black.withOpacity(0.5),
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Divider(height: 5, thickness: 5,),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                SizedBox(height: 90,)
              ],
            ),
          ),
          // ),
        ),
      ),
    );
  }
}
