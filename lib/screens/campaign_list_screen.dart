import 'dart:convert';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign.dart';
import 'package:nurebo_admin/models/business_campaign_type.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/campaign_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/campaign_selection_screen.dart';
import 'package:nurebo_admin/screens/campaign_user_list_screen.dart';
import 'package:nurebo_admin/screens/prestazione_detail_screen.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/future_svg.dart';
import 'package:nurebo_admin/widgets/signed_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class CampaignListScreen extends StatefulWidget {

  const CampaignListScreen({super.key,});

  @override
  _CampaignListScreenState createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  // final formatter =  NumberFormat.decimalPattern().format(1234); // formatted number will be: 1,234
  late CampaignProvider campaignProvider;
  late BusinessProvider businessProvider;
  Future a = Future((){}), b = Future((){});


  @override
  void initState() {
    super.initState();
    campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());

    Future.wait([
      a = campaignProvider.getAllBusinessCampaign(context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    campaignProvider = Provider.of<CampaignProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue[500])
          ),
          child: Text(
            // "Aggiungi",
            "Nuova campagna",
            // 'Continua',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700
            ),
          ),
          onPressed: () async {
            Navigator.push(
                context,
                PageTransition(
                  duration: const Duration(milliseconds: 500),
                  alignment: Alignment.center,
                  type: PageTransitionType.fade,
                  // child: NotificationScreen(),
                  child: CampaignSelectionScreen()
                )
            );
          },
        ),
      ),
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
          // 'Prestazioni',
          // 'Listino Prezzi',
          'Campagne',
          style: TextStyle(
              color: Colors.blue[500],
              // color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 16
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: OutlinedButton(
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.white),
          //     ),
          //     onPressed: () {
          //       // ticketCategoryProvider.deleteAll();
          //       Navigator.push(
          //         context,
          //         PageTransition(
          //           duration: const Duration(milliseconds: 500),
          //           alignment: Alignment.center,
          //           type: PageTransitionType.fade,
          //           // child: NotificationScreen(),
          //           child: PrestazioneDetailScreen(
          //             prestazione: Prestazione(
          //               title: '',
          //               description: '',
          //             ),
          //             // eventBusiness: widget.bookingBusiness,
          //             isNewPrestazione: true,
          //           ),
          //         )
          //       );
          //     },
          //     child: Text(
          //       'Aggiungi',
          //       style: TextStyle(
          //         color: Colors.blue
          //       ),
          //     )
          //     // child: Icon(
          //     //   Icons.add,
          //     //   color: Colors.blue,
          //     // ),
          //   ),
          // )
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
                        itemCount: campaignProvider.businessCampaignList.length,
                        itemBuilder: (context, i){
                          return InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: () async {
                              BusinessCampaign businessCampaign = BusinessCampaign(
                                id: campaignProvider.businessCampaignList[i]['business_campaign_id'],
                                created_at: DateTime.tryParse(campaignProvider.businessCampaignList[i]['created_at'])!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                                business_campaign_type: BusinessCampaignType(
                                  id: campaignProvider.businessCampaignList[i]['business_campaign_type_id'],
                                  title: campaignProvider.businessCampaignList[i]['business_campaign_type_title'],
                                  description: campaignProvider.businessCampaignList[i]['business_campaign_type_description'],
                                  icon_size: campaignProvider.businessCampaignList[i]['business_campaign_type_icon_size']?.toDouble(),
                                  icon: campaignProvider.businessCampaignList[i]['business_campaign_type_icon_icon'],
                                )
                              );
                              // campaignProvider.businessCampaignType = BusinessCampaignType(
                              //   id: campaignProvider.businessCampaignList[i]['business_campaign_type_id'],
                              //   title: campaignProvider.businessCampaignList[i]['business_campaign_type_title'],
                              //   description: campaignProvider.businessCampaignList[i]['business_campaign_type_description'],
                              //   icon_size: campaignProvider.businessCampaignList[i]['business_campaign_type_icon_size'].toDouble(),
                              //   icon: campaignProvider.businessCampaignList[i]['business_campaign_type_icon_icon'],
                              // );

                              Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: CampaignUserListScreen(
                                    businessCampaign: businessCampaign,
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
                                  ClipRRect(
                                    // borderRadius: BorderRadius.circular(40),
                                    borderRadius: BorderRadius.circular(4),
                                    child: FutureSvg(
                                      // child: SignedImage(
                                      campaignProvider.businessCampaignList[i]['business_campaign_type_icon'],
                                      // colorBlendMode: BlendMode.darken,
                                      // colorBlendMode: BlendMode.hardLight,
                                      width: 30,
                                      height: 30,
                                      color: Colors.grey[500],
                                      // filterQuality: FilterQuality.high,
                                      // placeholder: (context, url) => Center(
                                      //     child: CircularProgressIndicator()
                                      // ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * .05),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Marquee(
                                            child: GradientText(
                                              campaignProvider.businessCampaignList[i]['business_campaign_type_title'],
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomLeft,
                                                  end: Alignment.topRight,
                                                  colors: [
                                                    // Color(0xff8921aa),
                                                    // Color(0xffDA44bb),
                                                    Colors.blue[500]!,
                                                    Colors.blue[500]!,
                                                    // Color(0xffDA44bb)
                                                  ]
                                              ),
                                              style: TextStyle(
                                                //   color: Colors.black,
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 3,),
                                          Text(
                                            // discussionData[index].booking,
                                            // timeAgo.format(
                                            //     DateTime.tryParse(bookingList[index]['created_at']),
                                            //     locale: 'it'
                                            // ),
                                            // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                                            //   + ' alle ' +
                                            //   bookingList[index]['created_at'].toString().substring(11, 16),
                                            campaignProvider.businessCampaignList[i]['business_campaign_type_description'],
                                            style: TextStyle(
                                              // color: Colors.black.withOpacity(0.8),
                                                color: Colors.grey[700],
                                                // color: Colors.blue[600],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(height: 1,),
                                          // prestazioneProvider.prestazioneList[i]['price'] != null && prestazioneProvider.prestazioneList[i]['price'] != '' ? Text(
                                          //   // timeAgo.format(
                                          //   //     DateTime.tryParse(bookingList[index]['begin_at']),
                                          //   //     locale: 'it'
                                          //   // ),
                                          //   // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['begin_at']))
                                          //   //     + ' alle ' +
                                          //   //     bookingList[index]['begin_at'].toString().substring(11, 16),
                                          //   '€ ' + NumberFormat.currency(
                                          //     // customPattern: '#,##',
                                          //     decimalDigits: 2,
                                          //     symbol: '',
                                          //     locale: 'IT_it',
                                          //     // symbol: '€'
                                          //   ).format(prestazioneProvider.prestazioneList[i]['price'].toDouble()),
                                          //   // bookingList[index]['prestazione_title'],
                                          //   style: TextStyle(
                                          //     // color: Colors.black.withOpacity(0.5),
                                          //       color: Colors.green[700],
                                          //       fontSize: 13,
                                          //       fontWeight: FontWeight.w500
                                          //   ),
                                          // ) : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Icon(
                                  //   Icons.more_vert_rounded,
                                  //   color: Colors.black.withOpacity(0.5),
                                  //   size: 18,
                                  // ),

                                  Text(
                                    timeAgo.format(
                                        DateTime.tryParse(campaignProvider.businessCampaignList[i]['created_at'])!,
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
