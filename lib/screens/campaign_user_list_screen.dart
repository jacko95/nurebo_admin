import 'dart:convert';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign.dart';
import 'package:nurebo_admin/models/post_like.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/campaign_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/campaign_notification_screen.dart';
import 'package:nurebo_admin/screens/prestazione_detail_screen.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
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


class CampaignUserListScreen extends StatefulWidget {
  final BusinessCampaign businessCampaign;

  const CampaignUserListScreen({super.key, required this.businessCampaign, });

  @override
  _CampaignUserListScreenState createState() => _CampaignUserListScreenState();
}

class _CampaignUserListScreenState extends State<CampaignUserListScreen> {
  late BusinessProvider businessProvider;
  late CampaignProvider campaignProvider;
  Future a = Future((){}), b = Future((){});


  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    campaignProvider = Provider.of<CampaignProvider>(context, listen: false);

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());

    Future.wait([
      a = campaignProvider.getAllCampaignUsers(widget.businessCampaign, context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    campaignProvider = Provider.of<CampaignProvider>(context, listen: true);

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
      //       // "Prosegui  (2 disponibili)",
      //       // "Prosegui",
      //       "Invia",
      //       // "Avvia campagna",
      //       // 'Continua',
      //       style: TextStyle(
      //           fontSize: 16,
      //           fontWeight: FontWeight.w700
      //       ),
      //     ),
      //     onPressed: () async {
      //       // Navigator.push(
      //       //   context,
      //       //   PageTransition(
      //       //     duration: const Duration(milliseconds: 500),
      //       //     alignment: Alignment.center,
      //       //     type: PageTransitionType.fade,
      //       //     child: CampaignNotificationScreen(
      //       //       // campaignType: _selectedItemIndex,
      //       //       campaignType: campaignProvider.businessCampaignType,
      //       //     )
      //       //     // child: CampaignUserListScreen()
      //       //   )
      //       // );
      //       campaignProvider.sendCampaignNotification(
      //         businessCampaignType: campaignProvider.businessCampaignType,
      //         notificationTitle: campaignProvider.title ?? '',
      //         notificationBody: campaignProvider.body ?? '',
      //         uploadImage: campaignProvider.file,
      //         context: context,
      //       );
      //     },
      //   ),
      // ),
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
          'Utenti',
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
          child: FutureBuilder(
            // future: Future.wait([a]),
            future: a,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                return ListView(
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
                        itemCount: campaignProvider.userDeviceCampaignList.length,
                        // itemCount: campaignProvider.campaignUserPreviewList.length,
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
                                    // user: campaignProvider.campaignUserPreviewList[i]
                                    userId: campaignProvider.userDeviceCampaignList[i].user!.id!
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
                                    child: FutureImage(
                                      // campaignProvider.campaignUserPreviewList[i].profile_image,
                                      campaignProvider.userDeviceCampaignList[i].user!.profile_image,
                                      // colorBlendMode: BlendMode.darken,
                                      // colorBlendMode: BlendMode.hardLight,
                                      width: 45,
                                      height: 45,
                                      // filterQuality: FilterQuality.high,
                                      // placeholder: (context, url) => Center(
                                      //     child: CircularProgressIndicator()
                                      // ),
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
                                              // campaignProvider.campaignUserPreviewList[i].name ?? '',
                                              campaignProvider.userDeviceCampaignList[i].user!.name ?? '',
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    Color(0xff8921aa),
                                                    Color(0xffDA44bb)
                                                    // Colors.blue[700]!,
                                                    // Colors.red[400]!,
                                                    // Colors.red[600]!,
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
                                            // "@${campaignProvider.campaignUserPreviewList[i].username}",
                                            // "@${campaignProvider.userDeviceCampaignList[i].user!.username}",
                                            "${campaignProvider.userDeviceCampaignList[i].model!.substring(0, 3)}...${campaignProvider.userDeviceCampaignList[i].model!.substring(campaignProvider.userDeviceCampaignList[i].model!.length - 2)}",
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
                                  // Text(
                                  //   // timeAgo.format(
                                  //   //   campaignProvider.userCampaignList[i].!,
                                  //   //   locale: 'it'
                                  //   // ),
                                  //   campaignProvider.userList[i]. ?? '',
                                  //   style: TextStyle(
                                  //     // color: Colors.black.withOpacity(0.5),
                                  //       color: Colors.grey[600],
                                  //       fontSize: 13,
                                  //       fontWeight: FontWeight.w500
                                  //   ),
                                  // ),
                                  Visibility(
                                    visible: campaignProvider.userDeviceCampaignList[i].is_open == 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color:  Colors.green,
                                            border: Border.all(color: Colors.transparent),
                                            // border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
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
                );
              }
              else {
                return SizedBox();
              }
            }
          ),
        ),
        // ),
      ),
    );
  }
}
